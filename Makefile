TARGET 	= SnapBack
PORT	= 2222
IP	= 127.0.0.1

.PHONY: all clean

build:
	xcodebuild ARCHS=arm64 clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphoneos -configuration Debug

stage:
	mkdir -p build/latest/Applications/
	mkdir -p build/latest/var/tmp/
	#mkdir -p "build/latest/var/mobile/Library/Application Support/Installer"
	mkdir -p build/latest/DEBIAN/
	cp -R ./control build/latest/DEBIAN/
	cp -R ./postinst build/latest/DEBIAN/
	cp -R build/Debug-iphoneos/$(TARGET).app build/latest/Applications/
	#cp -R ./Installer.db build/latest/var/tmp/
	ldid -Sent.plist build/latest/Applications/$(TARGET).app/$(TARGET)

package: stage
	dpkg-deb -bZxz build/latest/ ./$(TARGET)_latest.deb
	rm -rf build/latest

install: stage
	scp -P $(PORT) -r build/latest/Applications/$(TARGET).app root@$(IP):/Applications
	ssh -p $(PORT) root@$(IP) 'uicache && killall SnapBack; chown root /Applications/SnapBack.app/SnapBack; chmod 6777 /Applications/SnapBack.app/SnapBack'

install-package:
	scp -P $(PORT) -r $(TARGET)_latest.deb root@$(IP):/tmp/$(TARGET)_latest.deb
	ssh -p $(PORT) root@$(IP) dpkg -i /tmp/$(TARGET)_latest.deb

ldid:
	rm -rf ././$(TARGET)_Rootless.app
	cp -R build/Products/Debug-iphoneos/$(TARGET).app ./$(TARGET)_Rootless.app
	cp ./ldid2 ./$(TARGET)_Rootless.app
	chown 0:0 ./$(TARGET)_Rootless.app/$(TARGET)
	chmod +s ./$(TARGET)_Rootless.app/$(TARGET)
	chmod a+x ./$(TARGET)_Rootless.app/ldid2
	ldid2 -Sent.plist ./$(TARGET)_Rootless.app/Installer

do: build package install-package

do-no-build: package install-package

clean:
	rm -rf build
