#!/bin/bash


#Function to obtain GPIO dumps via adb
dump_gpio () { 
               gpio_nr=159
               end=287
               while [ "$gpio_nr" -lt "$end" ]
               do
                   let "gpio_nr +=1"
                   gpio_num=$gpio_nr
                   gpio_off=`dc -e "$gpio_num  160 - p"`
                   gpio_bank=`dc -e "$gpio_off 32 / 32 % p"`
                   gpio_goff=`dc -e "$gpio_off 32 % 8 / 4 % p"`
                   gpio_off=`dc -e "$gpio_off 32 % 8 % p"`
                   gpio_goff=`echo -n $gpio_goff | sed -e 's/0/A/' -e 's/1/B/' -e 's/2/C/' -e 's/3/D/'`
                   echo -n "$gpio_num: RK30_PIN$gpio_bank"_"P$gpio_goff$gpio_off = "
                   adb shell /data/local/tmp/gpio get $gpio_num 
               done
             }
clear

#### Begining of the script
echo -e "############## RK3188 WIFI / BLUETOOTH GPIO DUMP FOR DEBIAN/UBUNTU ##############\n\n\n"
echo "Note that your device have to be rooted and be in USB Debug Mode"
echo "If that means nothing to you, have a look at :"
echo -e "\nhttps://github.com/davy39/rk3188-gpio-dump\n\n"
echo "Press ENTER to start"
echo -e "Press CTR+C to exit\n\n"
read

echo -e "\nInitialisation...\n"
# Check adb installation
adb_check=`dpkg -l | awk {'print $2'} | grep --regexp=^android-tools-adb$`
if [[ $adb_check != "android-tools-adb" ]] 
  then
    echo "adb is not installed. Please install it by running :"
    echo "sudo apt-get install android-tools-adb"
    exit 1
fi

# Check zip installation
adb_zip=`dpkg -l | awk {'print $2'} | grep --regexp=^zip$`
if [[ $adb_zip != "zip" ]] 
  then
    echo "zip is not installed. Please install it by running :"
    echo "sudo apt-get install zip"
    exit 1
fi


# Check if device detected
device_found=`adb devices | tail -2 | head -1 | cut -f 1 | sed 's/ *$//g'`
if [[ ${device_found} == "List of devices attached" ]]
  then
    echo "adb cannot detect your device"
    echo "Please verify your installation"
    exit 1
fi

# Check if device is rooted
root=`adb shell id | cut -c 7-10`
if [[ ${root} != "root" ]]
  then
    echo "Your device seems not to be rooted"
    exit 1
fi

# Check if utils have been downloaded

if [ ! -d "utils" ]
  then
    mkdir utils
    echo "First use. Downloading gpio dump module and binary..."
    wget "https://raw.githubusercontent.com/davy39/rk3188-gpio-dump/master/utils/user-gpio-drv.ko" -O "utils/user-gpio-drv.ko" 
    wget "https://raw.githubusercontent.com/davy39/rk3188-gpio-dump/master/utils/gpio" -O "utils/gpio"
  else
    if [[ ! -f "utils/user-gpio-drv.ko" ]]
      then
        echo "Downloading module user-gpio-drv.ko..."
        wget "https://raw.githubusercontent.com/davy39/rk3188-gpio-dump/master/utils/user-gpio-drv.ko" -O "utils/user-gpio-drv.ko" 
    fi
    if [[ ! -f "utils/gpio" ]]
      then
        echo "Downloading gpio binary..."
        wget "https://raw.githubusercontent.com/davy39/rk3188-gpio-dump/master/utils/gpio" -O "utils/gpio"
    fi
fi

echo -e "\n\n====== Install GPIO tools ======"

lsmod_found=`adb shell lsmod | grep "user_gpio_drv" | cut -d' ' -f1`
if [[ $lsmod_found != "user_gpio_drv" ]]
  then
    echo "Load gpio module..."
    adb push utils/user-gpio-drv.ko /data/local/tmp/
    adb shell insmod /data/local/tmp/user-gpio-drv.ko
  else
    echo "gpio module already loaded"
fi

echo "Push gpio binary"
adb push utils/gpio /data/local/tmp/
adb shell chmod 0777 /data/local/tmp/gpio


echo -e "\n\n====== Get Stock DMESG ======"

echo "Turn ON bluetooth"
adb shell service call bluetooth_manager 6  >/dev/null

echo "Turn ON wifi"
adb shell svc wifi enable

echo "Write stock dmesg in \"gpio_dmesg_stock.txt\"..."
sleep 10
if [ ! -d "dumps" ]
  then
    mkdir dumps
fi
adb shell /data/local/tmp/gpio dump gpio > /dev/null
adb shell dmesg > dumps/gpio_dmesg_stock.txt


echo -e "\n\n====== Get GPIO dumps for wifi OFF and Bluetooth OFF ======"

echo "Turn OFF wifi"
adb shell svc wifi disable

echo "Turn OFF bluetooth" 
adb shell service call bluetooth_manager 8 >/dev/null

echo "Write GPIO dump in w0b0..."
sleep 5
dump_gpio > dumps/w0b0


echo -e "\n\n====== Get GPIO dumps for wifi ON and Bluetooth OFF ======"

echo "Turn ON wifi"
adb shell svc wifi enable

echo "Writte GPIO dump in w1b0..."
sleep 5
dump_gpio > dumps/w1b0


echo -e "\n\n====== Get GPIO dumps for wifi ON and Bluetooth ON ======"

echo "Turn ON bluetooth"
adb shell service call bluetooth_manager 6 >/dev/null

echo "Write GPIO dump in w1b1..."
sleep 5
dump_gpio > dumps/w1b1


echo -e "\n\n====== Get GPIO dumps for wifi OFF and Bluetooth ON ======"

echo "Turn OFF wifi"
adb shell svc wifi disable

echo "Write GPIO dump in w0b1..."
sleep 5
dump_gpio > dumps/w0b1

echo -e "\n\n====== Create ZIP archive : gpio.zip ======"
zip -9 -y -r -q gpio-dump.zip dumps
echo -e "GPIO dump completed. You can send gpio-dump.zip to kernel developpers\n\n"