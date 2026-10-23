#!/bin/bash
set -e

# Build configuration
# - CONFIG=debug|release  (default: debug)
# - UNIVERSAL=1           build a fat arm64+x86_64 binary (default: host arch only)
CONFIG="${CONFIG:-debug}"
UNIVERSAL="${UNIVERSAL:-0}"

for arg in "$@"; do
    case "$arg" in
        --universal) UNIVERSAL=1 ;;
        --release)   CONFIG="release" ;;
        --debug)     CONFIG="debug" ;;
    esac
done

# Paths
APP_NAME="Ya cap.app"
APP_DIR="build/$APP_NAME"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"
PLUGINS="$CONTENTS/PlugIns"

# Build binary
if [ "$UNIVERSAL" = "1" ]; then
    echo "Building Ya cap ($CONFIG, universal: arm64 + x86_64)..."
    swift build -c "$CONFIG" --arch arm64 --arch x86_64
    # SwiftPM emits the merged universal binary under .build/out/Products/<Config>/
    CONFIG_CAP="$(tr '[:lower:]' '[:upper:]' <<< "${CONFIG:0:1}")${CONFIG:1}"
    BUILD_BIN=".build/out/Products/$CONFIG_CAP/Ya cap"
    if [ ! -f "$BUILD_BIN" ]; then
        # Try old path for backwards compatibility
        BUILD_BIN=".build/apple/Products/$CONFIG_CAP/Ya cap"
    fi
    if [ ! -f "$BUILD_BIN" ]; then
        # Fallback: merge per-arch binaries with lipo
        ARM_BIN=".build/arm64-apple-macosx/$CONFIG/Ya cap"
        X86_BIN=".build/x86_64-apple-macosx/$CONFIG/Ya cap"
        if [ -f "$ARM_BIN" ] && [ -f "$X86_BIN" ]; then
            BUILD_BIN=".build/$CONFIG/Ya cap-universal"
            lipo -create -output "$BUILD_BIN" "$ARM_BIN" "$X86_BIN"
        else
            echo "error: universal binary not found at $BUILD_BIN and per-arch fallbacks missing" >&2
            exit 1
        fi
    fi
else
    echo "Building Ya cap ($CONFIG, host arch only)..."
    swift build -c "$CONFIG"
    BUILD_BIN=".build/$CONFIG/Ya cap"
fi

if [ ! -f "$BUILD_BIN" ]; then
    echo "error: app binary not found at $BUILD_BIN" >&2
    exit 1
fi


# Clean previous bundle
rm -rf "$APP_DIR"

# Create .app bundle structure
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Copy binary
cp "$BUILD_BIN" "$MACOS/Ya cap"

# Copy share extension bundle

# Copy Info.plist
cp "capcap/App/Info.plist" "$CONTENTS/Info.plist"
bash scripts/inject-build-metadata.sh "$CONTENTS/Info.plist"
APP_SHORT_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$CONTENTS/Info.plist")"
APP_BUNDLE_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$CONTENTS/Info.plist")"

# Copy app icon
cp "Resources/AppIcon.icns" "$RESOURCES/AppIcon.icns"

# Copy menu bar icon source. The SVG lives in design/ so tweaking it updates the
# app bundle on the next rebuild without touching Swift code.
cp "design/menuBarIcon.svg" "$RESOURCES/MenuBarIcon.svg"

# Copy localization bundles (.lproj). The app loads these directly for its
# in-app language picker — see Localizer.swift.
for lproj in Resources/*.lproj; do
    [ -d "$lproj" ] || continue
    cp -R "$lproj" "$RESOURCES/"
done

# Copy SwiftPM resource bundles. PermissionFlow uses Bundle.module for its
# floating authorization panel strings; if this bundle is absent, Intel builds
# crash with a Swift assertion the first time the panel is shown.
BUILD_DIR="$(dirname "$BUILD_BIN")"
PERMISSION_FLOW_BUNDLE="$BUILD_DIR/capcap_PermissionFlow.bundle"
if [ ! -d "$PERMISSION_FLOW_BUNDLE" ]; then
    echo "error: missing SwiftPM resource bundle: $PERMISSION_FLOW_BUNDLE" >&2
    exit 1
fi
cp -R "$PERMISSION_FLOW_BUNDLE" "$RESOURCES/"

# Code signing
# -----------------------------------------------------------------------------
# Sign with a stable self-signed identity so the app's code-signing identity —
# and therefore its macOS TCC permission grants (Screen Recording /
# Accessibility) — stay the same across rebuilds. Ad-hoc signing produces a new
# cdhash every build, which makes each rebuild look like a different app to TCC
# and forces you to re-authorize it every time.
#
# scripts/ensure-signing-identity.sh creates the identity on first use and
# pre-authorizes its private key for /usr/bin/codesign, so signing never shows a
# keychain password prompt. It is idempotent.
#
# Override with the SIGN_IDENTITY env var to use a different certificate (e.g. a
# real Developer ID). If the identity cannot be created or used, the build falls
# back to ad-hoc signing: still launchable, but permissions need re-granting.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SIGN_IDENTITY="${SIGN_IDENTITY:-Ya cap Local Signing}"
if [ "$SIGN_IDENTITY" = "Ya cap Local Signing" ]; then
    bash "$SCRIPT_DIR/ensure-signing-identity.sh" || true
fi
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

# Drop a bundle path from the LaunchServices database. Any directory that has
# ever held a copy of the app stays registered even after the directory is gone,
# and Launchpad renders one icon per registration — that is where duplicate
# "Ya cap" icons come from. Staging copies must be unregistered before removal.
unregister_path() {
    [ -x "$LSREGISTER" ] || return 0
    "$LSREGISTER" -u "$1" >/dev/null 2>&1 || true
}

discard_stage() {
    local stage="$1"
    [ -d "$stage" ] || return 0
    unregister_path "$stage/$APP_NAME"
    rm -rf "$stage"
}

sign_bundles() {
    local identity="$1"
    # The project lives in iCloud Drive, which keeps re-attaching extended
    # attributes (com.apple.FinderInfo / com.apple.fileprovider.fpfs#P) that
    # codesign rejects as "resource fork, Finder information, or similar
    # detritus" and that cannot be cleared in place. Stage the bundle on local
    # disk, sign it there, then move the signed bundle back.
    local stage="/tmp/yacap-sign.$$"
    discard_stage "$stage"
    mkdir -p "$stage"
    ditto --noextattr --norsrc "$APP_DIR" "$stage/$APP_NAME"

    local s_contents="$stage/$APP_NAME/Contents"
    xattr -cr "$stage/$APP_NAME" 2>/dev/null || true
    find "$stage/$APP_NAME" -name '.DS_Store' -delete 2>/dev/null || true

    # Sign nested bundles bottom-up so the outer seal stays valid. Each step
    # returns explicitly on failure: this function runs inside an `if`
    # condition, where `set -e` is suspended, so without `|| return 1` a failed
    # codesign would be ignored and the ad-hoc fallback would never trigger.
    if [ -d "$s_contents/Resources/capcap_PermissionFlow.bundle" ]; then
        codesign --force --sign "$identity" \
            "$s_contents/Resources/capcap_PermissionFlow.bundle" || { discard_stage "$stage"; return 1; }
    fi
    codesign --force --entitlements "$SCRIPT_DIR/capcap.entitlements" \
        --sign "$identity" "$stage/$APP_NAME" || { discard_stage "$stage"; return 1; }
    codesign --verify --deep "$stage/$APP_NAME" || { discard_stage "$stage"; return 1; }

    rm -rf "$APP_DIR"
    ditto "$stage/$APP_NAME" "$APP_DIR"
    discard_stage "$stage"
}

if security find-identity -p codesigning 2>/dev/null | grep -qF "$SIGN_IDENTITY"; then
    echo "Signing with: $SIGN_IDENTITY"
    if ! sign_bundles "$SIGN_IDENTITY"; then
        # The identity exists but its private key may be unusable by codesign
        # (errSecInternalComponent happens when the key's ACL doesn't allow
        # /usr/bin/codesign, or the keychain can't be unlocked non-interactively).
        echo "warning: signing with '$SIGN_IDENTITY' failed — falling back to ad-hoc signing." >&2
        sign_bundles -
    fi
else
    echo "warning: '$SIGN_IDENTITY' not found in keychain — falling back to ad-hoc signing." >&2
    echo "warning: run scripts/ensure-signing-identity.sh to get stable TCC permissions." >&2
    sign_bundles -
fi

echo "✅ Built and signed $APP_DIR"
ARCHS=$(lipo -archs "$MACOS/Ya cap" 2>/dev/null || echo "unknown")
echo "   Architectures: $ARCHS"
echo ""
echo "To run:"
echo "  open build/$APP_NAME"
echo ""
echo "To install to /Applications:"
echo "  cp -r build/$APP_NAME /Applications/"
