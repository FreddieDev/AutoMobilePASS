include $(THEOS)/makefiles/common.mk
export TARGET = iphone:11.2:10.0 # Add support for iOS 10 and upwards
export ARCHS = armv7 armv7s arm64 arm64e
export THEOS_DEVICE_PORT=22
# export THEOS_DEVICE_IP=10.0.0.12
export THEOS_DEVICE_IP=192.168.0.10

# Tweak
TWEAK_NAME = AutoMobilePASS
$(TWEAK_NAME)_FILES = $(wildcard *.xm)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc # ARC memory management instead of MRC to auto-cleanup UI if tweaks like SafeShutdown mess with SB
include $(THEOS_MAKE_PATH)/tweak.mk

export SYSROOT=$(THEOS)/sdks/iPhoneOS11.2.sdk
export SDKVERSION=11.2

SUBPROJECTS += AutoMobilePASSPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk


# Restart springboard after install
after-install::
	install.exec "sbreload"