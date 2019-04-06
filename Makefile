export ARCHS = arm64
export TARGET = appletv:clang:10.1:10.1
GO_EASY_ON_ME = 1
export SYSROOT = $(THEOS)/sdks/AppleTVOS10.1.sdk
include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = SnapBack
SnapBack_FILES = main.m SBKAppDelegate.m SBKRootViewController.m UIBarButtonItem+blocks.m $(wildcard JGProgressHUD/*.m) Snappy/libsnappy.c
SnapBack_FRAMEWORKS = UIKit CoreGraphics IOKit
SnapBack_EXTRA_FRAMEWORKS = iAmGRoot
SnapBack_CFLAGS = -fobjc-arc
SnapBack_LDFLAGS += -FFrameworks/
SnapBack_CODESIGN_FLAGS = -Sent.xml

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall \"SnapBack\" && uicache" || true
