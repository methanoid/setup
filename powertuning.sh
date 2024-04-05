#!/bin/bash
#
# Powertop Auto Settings
#
# Shamelessly prepared thanks to this excellent page  https://hobo.house/2015/12/18/linux-laptop-power-usage-tuning-with-powertop/
#
echo '1500' > '/proc/sys/vm/dirty_writeback_centisecs';
echo '0' > '/proc/sys/kernel/nmi_watchdog';
echo 'auto' > '/sys/bus/i2c/devices/i2c-5/device/power/control';
echo 'auto' > '/sys/bus/i2c/devices/i2c-13/device/power/control';
#echo 'auto' > '/sys/bus/usb/devices/5-3.2.1/power/control';
echo 'auto' > '/sys/bus/i2c/devices/i2c-2/device/power/control';
#echo 'auto' > '/sys/bus/usb/devices/5-3.2.2/power/control';
echo 'auto' > '/sys/bus/i2c/devices/i2c-3/device/power/control';
echo 'auto' > '/sys/bus/i2c/devices/i2c-4/device/power/control';
echo 'auto' > '/sys/bus/i2c/devices/i2c-1/device/power/control';
echo 'auto' > '/sys/bus/i2c/devices/i2c-6/device/power/control';
echo 'auto' > '/sys/bus/i2c/devices/i2c-0/device/power/control';
echo 'auto' > '/sys/bus/i2c/devices/i2c-7/device/power/control';
echo 'auto' > '/sys/bus/i2c/devices/i2c-14/device/power/control';
echo 'auto' > '/sys/bus/i2c/devices/i2c-12/device/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:11:00.1/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:0b:00.1/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:18.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:09:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:03:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:18.5/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:0c:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:0c:00.0/ata1/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:0e:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:08.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:18.3/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:05.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:18.1/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:01.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:0b:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:11:00.3/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:14.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:14.3/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:11:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:18.2/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:0b:00.3/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:18.7/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:07.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:07:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:02.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:0d:00.0/ata3/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:18.6/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:0d:00.0/ata2/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:0d:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:18.4/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:04:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:04.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:0f:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:10:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:03.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:00.0/power/control';

# Wake status of the devices
echo 'enabled' > '/sys/class/net/wlp7s0/device/power/wakeup';
echo 'enabled' > '/sys/bus/usb/devices/usb5/power/wakeup';
echo 'enabled' > '/sys/bus/usb/devices/5-3.2.1/power/wakeup';
echo 'enabled' > '/sys/bus/usb/devices/usb3/power/wakeup';
echo 'enabled' > '/sys/bus/usb/devices/5-3/power/wakeup';
echo 'enabled' > '/sys/bus/usb/devices/5-3.2/power/wakeup';
echo 'enabled' > '/sys/bus/usb/devices/usb1/power/wakeup';
echo 'enabled' > '/sys/bus/usb/devices/3-2/power/wakeup';
echo 'enabled' > '/sys/bus/usb/devices/usb6/power/wakeup';
echo 'enabled' > '/sys/bus/usb/devices/usb4/power/wakeup';
echo 'enabled' > '/sys/bus/usb/devices/usb2/power/wakeup';
echo 'enabled' > '/sys/bus/usb/devices/1-2/power/wakeup';