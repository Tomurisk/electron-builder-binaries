#!/usr/bin/env bash
set -ex

# Harden curl by default
alias curl='curl --fail --tlsv1.2 --proto "=https" --proto-redir "=https"'

# Issues with FreeType (works, but list of warnings), in any case 1) we need to bundle also Net framework as part of wine home 2) no need to ia32+x64, to reduce size, the only arch should be used
# So, for now our existing wine 2.0.3 is used on macOS

rm -rf /tmp/wine-stage
mkdir -p /tmp/wine-stage/wine
cd /tmp/wine-stage/wine

WINE_VERSION=4.0.1
SHA256="8a4c6896226533e83bb763a7d3d90e9423a021343b10c72acb709829eeeee7f2"
WINE="portable-winehq-stable-$WINE_VERSION-osx64.tar.gz"
curl -L "https://dl.winehq.org/wine-builds/macosx/pool/$WINE" -o "$WINE"

# Compute actual checksum
ACTUAL_SHA256=$(sha256sum "$WINE" | awk '{print $1}')

# Compare
if [ "$ACTUAL_SHA256" != "$SHA256" ]; then
    echo "Checksum mismatch!"
    echo "Expected: $SHA256"
    echo "Actual:   $ACTUAL_SHA256"
fi

cd usr

unlink bin/wine

# prepare wine home
WINEPREFIX=/tmp/wine-stage/wine/usr/wine-home WINEARCH=win64 ./bin/wineboot --init

rm -rf share/man
rm -rf share/doc
rm -rf share/gtk-doc
rm -rf include

rm -rf wine-home/drive_c/windows/Installer
rm -rf wine-home/drive_c/windows/Microsoft.NET
rm -rf wine-home/drive_c/windows/mono
rm -rf wine-home/drive_c/windows/system32/gecko
rm -rf wine-home/drive_c/windows/syswow64/gecko
rm -rf wine-home/drive_c/windows/logs
rm -rf wine-home/drive_c/windows/inf