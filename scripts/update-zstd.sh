#!/usr/bin/env bash
set -ex

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

rm -rf /tmp/zstd
mkdir /tmp/zstd
cd /tmp/zstd

HASHES="
5a232e5273c3259d696450e49ea7a73c249c6f3e6dd693fac0ba8426cee96b62  zstd-win64.zip
6367a7b7a2743209180decca23b5ec4208b1adcee323c2b19240fc865e216984  zstd-win32.zip
"

download_and_verify() {
    local url="$1"
    local file="$2"

    echo "Downloading $file"
    curl -L "$url" -o "$file"

    local actual
    actual=$(sha256sum "$file" | awk '{print $1}')

    local expected
    expected=$(echo "$HASHES" | awk -v file="$file" '$2 == file {print $1}')

    if [ "$actual" != "$expected" ]; then
        echo "Checksum mismatch!"
        echo "Expected: $expected"
        echo "Actual:   $actual"
        exit 1
    fi
}

download_and_verify \
  "https://github.com/facebook/zstd/releases/download/v1.5.0/zstd-v1.5.0-win64.zip" \
  "zstd-win64.zip"

unzip zstd-win64.zip
cp zstd-v1.5.0-win64/zstd.exe "$BASEDIR/zstd/win-x64/zstd.exe"

download_and_verify \
  "https://github.com/facebook/zstd/releases/download/v1.5.0/zstd-v1.5.0-win32.zip" \
  "zstd-win32.zip"

unzip zstd-win32.zip
cp zstd-v1.5.0-win32/zstd.exe "$BASEDIR/zstd/win-ia32/zstd.exe"

# build on macOS
git clone --depth 1 --branch v1.5.0 https://github.com/facebook/zstd.git
cd zstd
make -j5
cp programs/zstd "$BASEDIR/zstd/mac/zstd"

cd /tmp/
rm -rf /tmp/zstd