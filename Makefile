GO_EASY_ON_ME = 1
THEOS_DEVICE_IP = 192.168.1.209
export ARCHS = arm64 arm64e
TARGET = iphone::10.3:11.2

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = SnapBack
SnapBack_FILES =  $(wildcard Source/*.m) $(wildcard JGProgressHUD/*.m) Snappy/libsnappy.c
SnapBack_FRAMEWORKS = UIKit CoreGraphics IOKit WebKit
SnapBack_EXTRA_FRAMEWORKS = iAmGRoot 
SnapBack_PRIVATE_FRAMEWORKS = Preferences
SnapBack_CFLAGS = -fobjc-arc
SnapBack_LDFLAGS += -FFrameworks/
SnapBack_CODESIGN_FLAGS = -Sent.xml

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall \"SnapBack\" && uicache" || true
