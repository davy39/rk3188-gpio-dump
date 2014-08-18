#!/bin/bash

clear
adb shell mv /data/local/tmp /data/local/tmp.bak
adb shell ln -s /data /data/local/tmp
adb reboot
echo "Rebooting (1/3) - Continue (press enter) when device finishes rebooting. Make sure that you are in USB Debug Mode."
read

adb shell rm /data/local.prop > /dev/null
adb shell "echo \"ro.kernel.qemu=1\" > /data/local.prop"
adb reboot
echo "Rebooting (2/3) - Continue (press enter) when device finishes rebooting. Make sure that you are in USB Debug Mode."
read

# Check if device is rooted
root=`adb shell id | cut -c 7-10`
if [[ ${root} != "root" ]]
  then
    echo "There were a problem during Root process, please try again"
    exit 1
fi

adb remount
adb push su /system/bin/su
adb shell chown root.shell /system/bin/su
adb shell chmod 6755 /system/bin/su
adb push busybox /system/bin/busybox
adb shell chown root.shell /system/bin/busybox
adb shell chmod 0755 /system/bin/busybox
echo "Pushing SuperSU"
adb push SuperSU.apk /system/app/SuperSU.apk
adb shell chown root.root /system/app/SuperSU.apk
adb shell chmod 0644 /system/app/SuperSU.apk
echo "Removing changes except ROOT"

adb shell rm /data/local.prop
adb shell rm /data/local/tmp
adb shell mv /data/local/tmp.bak /data/local/tmp
adb reboot

echo "Rebooting (3/3) - Congratulations, Your device should now be Rooted"
