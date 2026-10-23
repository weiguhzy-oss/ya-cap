#!/usr/bin/env bash
# Create a draggable macOS DMG from an existing .app bundle.
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "usage: $0 <path-to-app> <output-dmg> [volume-name]" >&2
    exit 64
fi

APP_PATH="$1"
OUTPUT_DMG="$2"
VOLNAME="${3:-capcap}"

if [ ! -d "$APP_PATH" ]; then
    echo "error: app bundle not found: $APP_PATH" >&2
    exit 1
fi

APP_BUNDLE="$(basename "$APP_PATH")"
if [[ "$APP_BUNDLE" != *.app ]]; then
    echo "error: expected a .app bundle, got: $APP_PATH" >&2
    exit 1
fi

OUTPUT_DIR="$(dirname "$OUTPUT_DMG")"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/capcap-dmg.XXXXXX")"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

# Both the staging copy and the mounted DMG volume get added to the
# LaunchServices database, and each registration persists after the path is
# gone — Launchpad then shows one extra "Ya cap" icon per leftover entry.
# Unregister them explicitly on the way out.
cleanup() {
    if [ -x "$LSREGISTER" ]; then
        "$LSREGISTER" -u "$STAGE/$APP_BUNDLE" >/dev/null 2>&1 || true
        "$LSREGISTER" -u "/Volumes/$VOLNAME/$APP_BUNDLE" >/dev/null 2>&1 || true
    fi
    rm -rf "$STAGE"
}
trap cleanup EXIT

mkdir -p "$OUTPUT_DIR"
# The project lives in iCloud Drive, which keeps re-attaching extended
# attributes (com.apple.FinderInfo / com.apple.fileprovider.fpfs#P) to the
# built bundle. `cp -R` carries them into the DMG, where codesign then rejects
# the app as "resource fork, Finder information, or similar detritus". ditto
# with --noextattr strips them while staging, the same way scripts/bundle.sh
# does before signing.
ditto --noextattr --norsrc "$APP_PATH" "$STAGE/$APP_BUNDLE"
xattr -cr "$STAGE/$APP_BUNDLE" 2>/dev/null || true
ln -s /Applications "$STAGE/Applications"

# A stripped bundle must still carry a valid signature. Catching it here keeps
# a broken DMG from reaching users.
if ! codesign --verify --deep --strict "$STAGE/$APP_BUNDLE"; then
    echo "error: staged bundle fails signature verification" >&2
    exit 1
fi

rm -f "$OUTPUT_DMG"
hdiutil create \
    -volname "$VOLNAME" \
    -srcfolder "$STAGE" \
    -ov \
    -format UDZO \
    -fs HFS+ \
    "$OUTPUT_DMG" >/dev/null
