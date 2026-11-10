## AERA Recovery device tree for POCO X3 NFC (surya/karna)

## Existing device-tree features

The following checks are inherited from the source TWRP tree and have not yet
been verified in an AERA build.

<details><summary>Upstream TWRP checks: - Click to open</summary>
<p>

- [X] ADB
- [X] Decryption of /data (MIUI Android 12/Custom rom Android 12-13 FBEv1)
- [X] Screen brightness settings
- [X] Vibration support
- [X] Correct screenshot
- [X] Correct date/battery level/temperature
- [X] MTP
- [X] Flashing (opengapps, roms, images and so on)
- [X] Backup/Restore to internal/microSD
- [X] Backup/Restore to/from adb (https://gerrit.omnirom.org/#/c/15943/)
- [X] USB OTG
- [X] Fasbootd
- [X] Sideload (adb sideload update.zip)
- [X] Reboot to bootloader/recovery/system/fasbootd
- [X] F2FS/EXT4 Support, exFAT/NTFS where supported
- [ ] Wi-Fi (not working yet)

</p>
</details>

## Build with GitHub Actions

This tree targets AERA's Android 16 (`aera-16.0`) source. Its device-specific
settings are adapted from a TWRP 12.1 tree and have not yet been validated on
the phone.
Qualcomm FBE decryption is configured using the matching Surya recovery
settings (`BOARD_USES_QCOM_FBE_DECRYPTION` and the `qcom_decrypt` packages);
successful decryption still needs on-device validation.

The `AERA Recovery Build` workflow is manually triggered from the Actions tab.
It syncs AERA's manifest, builds `twrp_surya-aosp_current-eng`, and uploads
the recovery image as a workflow artifact.

The workflow requires a self-hosted Linux x86_64 runner labeled `self-hosted`,
`Linux`, and `X64`, with at least 32 GB RAM and 250 GB free disk space. Standard
GitHub-hosted runners do not have enough resources for the complete Android
source tree.

## Build directly on a VPS

Use an x86_64 Ubuntu 24.04 VPS with at least 24 GiB available RAM and 250 GiB
free disk space (32 GiB or more RAM and a 500 GiB disk are recommended). A
30 GB VPS can work; the script automatically limits parallel build jobs based
on available memory. Install Git, clone this tree, and run the included build
script as root or as a user with sudo access:

```
# Run as root:
apt-get update && apt-get install -y git
# Or, as a regular sudo-enabled user:
sudo apt-get update && sudo apt-get install -y git
git clone --branch main https://github.com/raideneii75/android_device_xiaomi_surya-AERA.git
cd android_device_xiaomi_surya-AERA
bash build_surya.sh
```

The script installs build dependencies, syncs AERA Android 16 and this device
tree, then builds the recovery. It defaults to `$HOME/android/aera-surya`.
To use a mounted large disk or override the automatically selected job count,
set:

```
AERA_BUILD_DIR=/mnt/android/aera-surya BUILD_JOBS=8 bash build_surya.sh
```

The script prints the recovery image path when the build succeeds. Test by
booting it temporarily before considering a flash:

```
fastboot boot /path/to/recovery.img
```

After a successful build, the script automatically uploads the recovery image
to GoFile and prints its download link. The share link can be accessed by
anyone who has it. To keep the image local and skip uploading, run:

```
GOFILE_UPLOAD=0 bash build_surya.sh
```

The tree uses a precompiled stock kernel. Validate display, touch, data
decryption, partition mounting, backup/restore, and flashing on the device
before treating the image as production-ready.

The recovery UI refresh target is set to 120 Hz to match the POCO X3 NFC
panel. If the rebuilt recovery still stutters or display stability gets worse,
capture `/tmp/recovery.log` and report whether the stutter affects animations,
touch response, or both; do not copy the Chiron KGSL-specific patches directly,
as they depend on that device's graphics stack.

The adaptive UI canvas is configured for the Surya's 1080 x 2400 display.
Legacy vertical offset overrides are intentionally left unset so they do not
shift or clip the native AERA interface.

Wi-Fi UI support is enabled, and the build script fetches AERA's required
Android 16 `wpa_supplicant_8` source if it is not already present. Wi-Fi still
requires the matching Surya kernel modules and firmware from the installed ROM;
the Peridot recovery's WLAN modules and WPSS startup sequence are device-specific
and must not be copied to Surya. Confirm the module names and firmware paths on
the target ROM before configuring module loading. The checked-in recovery
kernel identifies itself as 4.14.180, while the tested Android ROM reports
4.14.357-rethinking; recovery Wi-Fi needs a kernel with the matching WLAN
driver and firmware setup, not only the UI/supplicant option.

### Copyright
 ```
  /*
  *  Copyright (C) 2013-23 The TWRP
  *
  * This program is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation, either version 3 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  *
  */
  ```
