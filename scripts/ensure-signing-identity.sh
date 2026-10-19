#!/bin/bash
# Creates (once) a self-signed code-signing identity for local builds and makes
# it usable by codesign without any password prompt.
#
# Why this exists: macOS TCC keys Screen Recording / Accessibility grants off the
# code signature. Ad-hoc signing produces a new cdhash on every build, so each
# rebuild looks like a different app and permissions must be re-granted. A fixed
# self-signed certificate keeps the signature stable across rebuilds.
#
# Why it never prompts: the identity lives in its own keychain with a known
# password, auto-lock is disabled, and the private key is pre-authorized for
# /usr/bin/codesign via `-T` plus `set-key-partition-list`. The usual
# "codesign wants to access key in your keychain" dialog (and the
# errSecInternalComponent failure that follows when it is dismissed) comes from
# that authorization being missing.
#
# Idempotent: re-running is a no-op once the identity exists.
set -e

IDENTITY="${LOCAL_IDENTITY:-Ya cap Local Signing}"
KEYCHAIN="${LOCAL_KEYCHAIN:-$HOME/Library/Keychains/ya-cap-signing.keychain-db}"
KEYCHAIN_PASS="${LOCAL_KEYCHAIN_PASS:-ya-cap}"

unlock() {
    # An auto-locked keychain is the other common source of prompts.
    security set-keychain-settings "$KEYCHAIN" 2>/dev/null || true
    security unlock-keychain -p "$KEYCHAIN_PASS" "$KEYCHAIN"
}

# `security import` into a keychain that is not on the search list leaves the
# identity invisible to codesign, so add it. Rebuilding the list also drops
# stale entries (e.g. a deleted /private/tmp/*.keychain), which otherwise make
# every `security` call emit errors.
add_to_search_list() {
    local existing keep=()
    existing=$(security list-keychains -d user | tr -d '" ')
    while IFS= read -r kc; do
        [ -n "$kc" ] || continue
        [ -f "$kc" ] || continue
        [ "$kc" = "$KEYCHAIN" ] && continue
        keep+=("$kc")
    done <<< "$existing"
    security list-keychains -d user -s "${keep[@]}" "$KEYCHAIN"
}

if [ -f "$KEYCHAIN" ] && security find-certificate -c "$IDENTITY" "$KEYCHAIN" >/dev/null 2>&1; then
    unlock
    add_to_search_list
    echo "Local signing identity '$IDENTITY' already present."
    exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Always use the system LibreSSL rather than whatever `openssl` is first on PATH.
# A Homebrew OpenSSL 3 writes PKCS#12 files with modern defaults (PBES2 /
# AES-256-CBC) that `security import` cannot read — it fails with "MAC
# verification failed during PKCS12 import (wrong password?)" even though the
# password is correct. LibreSSL writes the legacy format macOS expects.
OPENSSL=/usr/bin/openssl

# A config file is used instead of `-addext` because LibreSSL does not support
# that flag.
{
    echo "[req]"
    echo "distinguished_name = dn"
    echo "x509_extensions    = v3"
    echo "prompt             = no"
    echo "[dn]"
    echo "CN = $IDENTITY"
    echo "[v3]"
    echo "basicConstraints = critical,CA:false"
    echo "keyUsage         = critical,digitalSignature"
    echo "extendedKeyUsage = critical,codeSigning"
} > "$TMP/cert.cnf"

"$OPENSSL" req -x509 -new -newkey rsa:2048 -nodes -sha256 -days 3650 \
    -config "$TMP/cert.cnf" -keyout "$TMP/key.pem" -out "$TMP/cert.pem" 2>/dev/null
"$OPENSSL" pkcs12 -export -name "$IDENTITY" \
    -inkey "$TMP/key.pem" -in "$TMP/cert.pem" \
    -out "$TMP/identity.p12" -passout "pass:$KEYCHAIN_PASS" 2>/dev/null

# Only create the keychain if it is missing — create-keychain on an existing
# file wipes whatever is already in it.
if [ ! -f "$KEYCHAIN" ]; then
    security create-keychain -p "$KEYCHAIN_PASS" "$KEYCHAIN"
fi
unlock

security import "$TMP/identity.p12" -k "$KEYCHAIN" \
    -P "$KEYCHAIN_PASS" -T /usr/bin/codesign -A >/dev/null
security set-key-partition-list -S apple-tool:,apple:,codesign: \
    -s -k "$KEYCHAIN_PASS" "$KEYCHAIN" >/dev/null 2>&1 || true
add_to_search_list

# The certificate stays untrusted (find-identity reports CSSMERR_TP_NOT_TRUSTED
# and "0 valid identities"), which is expected and harmless: trust governs
# verifying someone else's signature, not producing your own. codesign signs
# with it fine.
echo "Created local signing identity '$IDENTITY' in $KEYCHAIN."
