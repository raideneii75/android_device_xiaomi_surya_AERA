#
# Copyright 2018 The Android Open Source Project
# Copyright 2014-2024 The Team Win LLC
#
# SPDX-License-Identifier: Apache-2.0
#

# Broken rules
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_MISSING_REQUIRED_MODULES := true

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := sm6150
TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := true

# Platform
TARGET_BOARD_PLATFORM := sm6150
TARGET_BOARD_PLATFORM_GPU := qcom-adreno618
QCOM_BOARD_PLATFORMS += sm6150

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a76

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a55

# Enable CPUSets
ENABLE_CPUSETS := true
ENABLE_SCHEDBOOST := true

# Kernel
BOARD_KERNEL_CMDLINE := \
	androidboot.hardware=qcom \
	androidboot.memcg=1 \
	lpm_levels.sleep_disabled=1 \
	msm_rtb.filter=0x237 \
	service_locator.enable=1 \
	androidboot.usbcontroller=a600000.dwc3 \
	swiotlb=2048 \
	androidboot.boot_devices=soc/1d84000.ufshc \
	androidboot.selinux=permissive

BOARD_KERNEL_IMAGE_NAME    := Image
BOARD_KERNEL_PAGESIZE      := 4096
BOARD_BOOT_HEADER_VERSION  := 2
BOARD_KERNEL_BASE          := 0x00000000
BOARD_KERNEL_TAGS_OFFSET   := 0x00000100
BOARD_KERNEL_OFFSET        := 0x00008000
BOARD_KERNEL_SECOND_OFFSET := 0x00000000
BOARD_RAMDISK_OFFSET       := 0x01000000
BOARD_DTB_OFFSET           := 0x01f00000
TARGET_KERNEL_ARCH := arm64
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/recovery_dtbo
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt/dtb
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_INCLUDE_DTB_IN_BOOTIMG := true

BOARD_MKBOOTIMG_ARGS += \
	--base $(BOARD_KERNEL_BASE) \
	--pagesize $(BOARD_KERNEL_PAGESIZE) \
	--ramdisk_offset $(BOARD_RAMDISK_OFFSET) \
	--tags_offset $(BOARD_KERNEL_TAGS_OFFSET) \
	--kernel_offset $(BOARD_KERNEL_OFFSET) \
	--second_offset $(BOARD_KERNEL_SECOND_OFFSET) \
	--dtb_offset $(BOARD_DTB_OFFSET) \
	--header_version $(BOARD_BOOT_HEADER_VERSION)

# Avb
BOARD_AVB_ENABLE := true
BOARD_AVB_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_BOOTIMAGE_PARTITION_SIZE := 134217728
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 134217728

# Dynamic Partitions
BOARD_SUPER_PARTITION_SIZE := 8589934592
BOARD_SUPER_PARTITION_GROUPS := main
BOARD_MAIN_SIZE := 8585740288 # (BOARD_SUPER_PARTITION_SIZE - 4194304) 4MiB
BOARD_MAIN_PARTITION_LIST := \
	system \
	system_ext \
	vendor \
	product

# File systems
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

# Workaround for error copying vendor files to recovery ramdisk
BOARD_PARTITION_LIST := $(call to-upper, $(BOARD_MAIN_PARTITION_LIST))
$(foreach p, $(BOARD_PARTITION_LIST), $(eval BOARD_$(p)IMAGE_FILE_SYSTEM_TYPE := ext4))
$(foreach p, $(BOARD_PARTITION_LIST), $(eval TARGET_COPY_OUT_$(p) := $(call to-lower, $(p))))

# Extras props
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# Crypto
PLATFORM_VERSION := 99.87.36
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
AERA_INCLUDE_CRYPTO := true
AERA_INCLUDE_CRYPTO_FBE := true
AERA_INCLUDE_FBE_METADATA_DECRYPT := true
BOARD_USES_QCOM_FBE_DECRYPTION := true
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

# Recovery
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
BOARD_HAS_LARGE_FILESYSTEM := true

# AERA recovery configuration
AERA_THEME := portrait_hdpi
AERA_UI_ADAPTIVE_RESOLUTION := true
AERA_SCREEN_H := 2400
RECOVERY_SDCARD_ON_DATA := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TARGET_USE_CUSTOM_LUN_FILE_PATH := /config/usb_gadget/g1/functions/mass_storage.0/lun.%d/file
AERA_EXCLUDE_DEFAULT_USB_INIT := true
AERA_INCLUDE_NTFS_3G := true
AERA_BRIGHTNESS_PATH := /sys/class/backlight/panel0-backlight/brightness
AERA_MAX_BRIGHTNESS := 4095
AERA_DEFAULT_BRIGHTNESS := 1200
TARGET_USES_MKE2FS := true
AERA_NO_SCREEN_BLANK := true
AERA_EXCLUDE_APEX := true
AERA_USE_TOOLBOX := true
AERA_SUPPORT_INPUT_1_2_HAPTICS := true

# The path to a temperature sensor
AERA_CUSTOM_CPU_TEMP_PATH := "/sys/devices/virtual/thermal/thermal_zone19/temp"

# Recovery logging
TARGET_USES_LOGD := true
AERA_INCLUDE_LOGCAT := true

AERA_QCOM_ATS_OFFSET := 1643101352000

# Recovery tools
AERA_INCLUDE_RESETPROP := true
AERA_INCLUDE_REPACKTOOLS := true
AERA_INCLUDE_LPDUMP := true
AERA_INCLUDE_LPTOOLS := true
AERA_INCLUDE_PYTHON := true

AERA_PREPARE_DATA_MEDIA_EARLY := true
# Match the Surya panel's 120 Hz mode for smoother recovery UI updates.
AERA_FRAMERATE := 120

# Surya is A-only (dynamic partitions without slots). AOSP defaults
# AB_OTA_UPDATER to true when unset, which breaks super-partition mapping and
# keeps /vendor from mounting, so the ROM's crypto props are never copied.
AB_OTA_UPDATER := false
