# rk3188-gpio-dump

rk3188-gpio-dump.sh is a script bash usefull to get gpio dumps from rk3188 on debian/Ubuntu based systems.

 
Before launching the script make sure that :

 - you have **[installed and configure ADB](#install-and-configure-adb)** on your computer

 - You have **installed wget and zip** on your computer (```sudo apt-get install wget zip```)

 - you have granted **[ROOT access](#root-your-device)** on your device

 - Your device is connected to your computer via USB and have **[USB DEBUG MODE](#enable-usb-debug-mode-on-your-device)** enabled         


## Basic usage

1- Download the script :

```mkdir rk3188-gpio-dump; cd rk3188-gpio-dump```

```wget "https://raw.githubusercontent.com/davy39/rk3188-gpio-dump/master/rk3188-gpio-dump.sh"```

2- Launch the script :

``` bash rk3188-gpio-dump.sh ```


3- Get your dumps and DMESG into the **dumps** folder and archived into **gpio-dump.zip**

4- Analyse your dumps  [TODO]

## Requirements

### Enable USB DEBUG MODE on your device

This is the method for last cyxtech cs918 stock rom. It may be similar for all JB roms.

- Go to **Settings**

- If you don't have access to **{} Developper options** menu : Go to **About device** > then click on **Build number** many times until you get access to developper session.

- Go to **Settings** > **{} Developper option** > enable **USB debugging**

- Go to **Settings** > **USB** and enable **Connect to PC** (notice that you'll **have to do it each time you reboot**)

Then when you'll connect the box to your PC via usb, you should get the notification **USB debugging connected**.

### Install and configure ADB

* _**Configure your system to detect rk3188 as an android device**_

Make sure you are in [USB DEBUG MODE](#enable-usb-debug-mode-on-your-device) on your device. 
If you connect your device to your PC via USB, and you type:

```sudo lsusb```

You should get a line with "ID 2207:0011" that correspond to your Rockchip SOC : 

> Bus 001 Device 088: ID 2207:0011

You have to add an udev rule :

```sudo nano /etc/udev/rules.d/99-android.rules```

Add this line to the file :

> SUBSYSTEM=="usb", ATTRS{idVendor}=="2207", ATTRS{idProduct}=="0011", SYMLINK+="android_adb", MODE="0666", OWNER="root"

* _**Install ADB on Debian/Ubuntu systems**_

``` sudo apt-get install -y android-tools-adb```

* _**Configure ADB to work with rk3188**_

```mkdir ~/.android```

```nano ~/.android/adb_usb.ini```

Add to the file :

> 0x2207

* _**Verify if ADB dectect the device**_

```adb devices```

You should get :

> List of devices attached

> XXXXXXXXXXX device


### Root your device

1 - Make sure that :
   
   - **your device is connected to your computer** and you've **[enabled USB DEBUG MODE](#enable-usb-debug-mode-on-your-device)**
   - You've **installed and properly configured ADB**


2 - Download the following files :

``` mkdir root-rk3188; cd root-rk3188```

``` wget "https://raw.githubusercontent.com/davy39/rk3188-gpio-dump/master/utils/root/busybox" ```

``` wget "https://raw.githubusercontent.com/davy39/rk3188-gpio-dump/master/utils/root/SuperSU.apk" ```

``` wget "https://raw.githubusercontent.com/davy39/rk3188-gpio-dump/master/utils/root/su" ```

``` wget "https://raw.githubusercontent.com/davy39/rk3188-gpio-dump/master/utils/root/root.sh" ```


3 - Launch the root.sh script and follow the instructions :

Don't forget te enable USB DEBUG MODE **each reboot** by going to >Settings >USB >Connect to PC

``` bash root.sh ```
