#!/usr/bin/env bash
set -eo pipefail

BUILD_DIR="${AERA_BUILD_DIR:-$HOME/android/aera-surya}"
BUILD_JOBS="${BUILD_JOBS:-}"
REPO_URL="https://github.com/AERA-Recovery/android_manifest.git"
DEVICE_TREE_URL="https://github.com/raideneii75/android_device_xiaomi_surya-AERA.git"
PRODUCT_OUT="$BUILD_DIR/out/target/product/surya"

if [[ "$(uname -s)" != "Linux" || "$(uname -m)" != "x86_64" ]]; then
    echo "Build on an x86_64 Linux VPS (Ubuntu 24.04 recommended)." >&2
    exit 1
fi

if [[ "$EUID" -eq 0 ]]; then
    SUDO=()
else
    if ! command -v sudo >/dev/null; then
        echo "Run this script as root or as a user with sudo access." >&2
        exit 1
    fi
    sudo -v
    SUDO=(sudo)
fi

mkdir -p "$BUILD_DIR"
available_memory_gib="$(awk '/MemAvailable/ {printf "%d", $2 / 1024 / 1024}' /proc/meminfo)"
available_disk_gib="$(df --output=avail -BG "$BUILD_DIR" | tail -n 1 | tr -dc '0-9')"

echo "Available memory: ${available_memory_gib} GiB"
echo "Available disk: ${available_disk_gib} GiB"
if (( available_memory_gib < 24 || available_disk_gib < 250 )); then
    echo "Need at least 24 GiB available memory and 250 GiB free disk." >&2
    exit 1
fi

if [[ -z "$BUILD_JOBS" ]]; then
    BUILD_JOBS=$((available_memory_gib / 5))
    cpu_count="$(nproc)"
    if (( BUILD_JOBS > cpu_count )); then
        BUILD_JOBS="$cpu_count"
    fi
    if (( BUILD_JOBS < 1 )); then
        BUILD_JOBS=1
    fi
fi
echo "Build jobs: $BUILD_JOBS"

if [[ ! -x "$HOME/bin/repo" ]]; then
    mkdir -p "$HOME/bin"
    curl --fail --location --retry 5 \
        https://storage.googleapis.com/git-repo-downloads/repo \
        --output "$HOME/bin/repo"
    chmod a+x "$HOME/bin/repo"
fi
export PATH="$HOME/bin:$PATH"

"${SUDO[@]}" apt-get update
"${SUDO[@]}" apt-get install -y \
    bc bison build-essential ccache curl flex g++-multilib gcc-multilib \
    git git-lfs gnupg gperf imagemagick lib32readline-dev lib32z1-dev \
    libelf-dev liblz4-tool libncurses-dev libssl-dev libxml2 libxml2-utils \
    lzop openjdk-21-jdk pngcrush python3 rsync squashfs-tools xsltproc \
    zip zlib1g-dev

cd "$BUILD_DIR"
if [[ ! -d .repo ]] && [[ -n "$(find . -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
    echo "$BUILD_DIR is not empty and has no initialized repo checkout." >&2
    echo "Choose another directory with AERA_BUILD_DIR." >&2
    exit 1
fi

manifest_file="$BUILD_DIR/.repo/manifests/twrp-default.xml"
if [[ -f "$manifest_file" ]]; then
    python3 - "$manifest_file" <<'PY'
from pathlib import Path
import re
import sys

manifest = Path(sys.argv[1])
contents = manifest.read_text()
contents = re.sub(
    r"^[ \t]*<include name=\"default\.xml\"/>\r?\n",
    "",
    contents,
    flags=re.MULTILINE,
)
manifest.write_text(contents)
PY
fi

repo init -u "$REPO_URL" -b aera-16.0 -m default.xml

mkdir -p .repo/local_manifests
cat > .repo/local_manifests/surya.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project path="device/xiaomi/surya"
           name="raideneii75/android_device_xiaomi_surya-AERA"
           remote="github"
           revision="main" />
</manifest>
EOF

repo sync -c --force-sync --no-clone-bundle --no-tags -j"$BUILD_JOBS"

if [[ ! -f external/wpa_supplicant_8/Android.bp ]]; then
    if [[ -e external/wpa_supplicant_8 ]]; then
        echo "external/wpa_supplicant_8 exists but has no Android.bp." >&2
        echo "Remove or repair that checkout before building WLAN support." >&2
        exit 1
    fi
    git clone --depth=1 --branch android16-s2-release \
        https://android.googlesource.com/platform/external/wpa_supplicant_8 \
        external/wpa_supplicant_8
fi

export AERA_BUILD_DEVICE=surya
source build/envsetup.sh
lunch twrp_surya-aosp_current-eng
mka adbd recoveryimage -j"$BUILD_JOBS"

recovery_image="$PRODUCT_OUT/recovery.img"
if [[ ! -s "$recovery_image" ]]; then
    recovery_image="$(find "$PRODUCT_OUT" -maxdepth 1 -type f \
        -name 'AERA*surya*.img' -print -quit)"
fi

if [[ -z "$recovery_image" || ! -s "$recovery_image" ]]; then
    echo "Build finished, but no recovery image was found in $PRODUCT_OUT." >&2
    find "$PRODUCT_OUT" -maxdepth 1 -type f -name '*.img' -print >&2 || true
    exit 1
fi

echo "Recovery image: $recovery_image"
ls -lh "$recovery_image"