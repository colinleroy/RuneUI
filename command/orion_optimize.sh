#!/bin/bash
#
#  Copyright (C) 2013-2014 RuneAudio Team
#  http://www.runeaudio.com
#
#  RuneUI
#  copyright (C) 2013-2014 – Andrea Coiutti (aka ACX) & Simone De Gregori (aka Orion)
#
#  RuneOS
#  copyright (C) 2013-2014 – Simone De Gregori (aka Orion) & Carmelo San Giovanni (aka Um3ggh1U)
#
#  RuneAudio website and logo
#  copyright (C) 2013-2014 – ACX webdesign (Andrea Coiutti)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with RuneAudio; see the file COPYING.  If not, see
#  <http://www.gnu.org/licenses/gpl-3.0.txt>.
# 
#  file: command/orion_optimize.sh
#  version: 1.3
#  coder: Simone De Gregori
#
#####################################
ver="1.3"
####################
# common functions #
####################
mpdprio_nice () {
count=1
for pid in $(pgrep -w mpd); 
do
    if ((count == 3)) 
    then
        echo "### Set priority for: mpd-player thread ###";
        renice -15 $pid;
    fi
    if ((count == 4))  
    then
        echo "### Set priority for: mpd-output thread ###";
        renice -18 $pid;
    fi
    if ((count == 5))
    then
        echo "### Set priority for: mpd-decoder thread ###";
        renice -16 $pid;
    fi
count=$((count+1))
done
}

mpdprio_default () {
count=1
for pid in $(pgrep -w mpd); 
do
    if ((count == 3)) 
    then
        echo "### Set priority for: mpd-player thread ###";
        renice 20 $pid;
    fi
    if ((count == 4))  
    then
        echo "### Set priority for: mpd-output thread ###";
        renice 20 $pid;
    fi
    if ((count == 5))
    then
        echo "### Set priority for: mpd-decoder thread ###";
        renice 20 $pid;
    fi
count=$((count+1))
done
}

# set cifsd priority
cifsprio () {
local "${@}" 
if (( -n ${pid})) 
then 
echo "### Set priority for: cifsd ###"
renice ${prio} ${pid}
fi
}

# adjust Kernel scheduler latency based on Architecture
modKschedLatency () {
    local "${@}"
    # RaspberryPi
    if (($((10#${hw})) == "1"))
    then
	    echo "RaspberryPi"
        echo ${s01} > /proc/sys/kernel/sched_latency_ns
        echo "sched_latency_ns = "${s01}
        sndusb_profile nrpacks=${u01}
        echo "USB nrpacks="${u01}
        echo -n performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    fi
    # CuBox
    if (($((10#${hw})) == "2"))
    then
	    echo "CuBox"
        echo ${s02} > /proc/sys/kernel/sched_latency_ns
        echo "sched_latency_ns = "${s02}
        sndusb_profile nrpacks=${u02}
        echo "USB nrpacks="${u02}
    fi
    # UDOO
    if (($((10#${hw})) == "3"))
    then
        echo "UDOO"
		echo ${s03} > /proc/sys/kernel/sched_latency_ns
        echo "sched_latency_ns = "${s03}
        sndusb_profile nrpacks=${u03}
        echo "USB nrpacks="${u03}
    fi
    # BeagleBoneBlack
    if (($((10#${hw})) == "4"))
    then
	    echo "BeagleBoneBlack"
        echo ${s04} > /proc/sys/kernel/sched_latency_ns
        echo "sched_latency_ns = "${s04}
        sndusb_profile nrpacks=${u04}
        echo "USB nrpacks="${u04}
    fi
    # Compulab Utilite
    if (($((10#${hw})) == "5"))
    then
	    echo "Utilite"
        echo ${s04} > /proc/sys/kernel/sched_latency_ns
        echo "sched_latency_ns = "${s04}
        sndusb_profile nrpacks=${u04}
        echo "USB nrpacks="${u04}
    fi
    # Cubietruck
    if (($((10#${hw})) == "6"))
    then
	    echo "Cubietruck"
        echo ${s06} > /proc/sys/kernel/sched_latency_ns
        echo "sched_latency_ns = "${s06}
        sndusb_profile nrpacks=${u06}
        echo "USB nrpacks="${u06}
    fi
    # Cubox-i
    if (($((10#${hw})) == "7"))
    then
		echo "Cubox-i"
        echo ${s07} > /proc/sys/kernel/sched_latency_ns
        echo "sched_latency_ns = "${s07}
        sndusb_profile nrpacks=${u07}
        echo "USB nrpacks="${u07}
    fi
    # RaspberryPi2/3
    if (($((10#${hw})) == "8")) 
    then
	    echo "RaspberryPi2/3"
        echo ${s08} > /proc/sys/kernel/sched_latency_ns
        echo "sched_latency_ns = "${s08}
        # sndusb_profile nrpacks=${u08}    nrpacks not supported anymore on newer kernels
        # echo "USB nrpacks="${u08}
    fi
    # ODROID C1
    if (($((10#${hw})) == "9"))
    then
	    echo "ODROIDC1"
        echo ${s09} > /proc/sys/kernel/sched_latency_ns
        echo "sched_latency_ns = "${s09}
        # sndusb_profile nrpacks=${u09}    nrpacks not supported anymore on newer kernels
        # echo "USB nrpacks="${u09}
    fi
    # ODROID C2
    if (($((10#${hw})) == "10")) 
    then
		echo "ODROIDC2"
        echo ${s10} > /proc/sys/kernel/sched_latency_ns
        echo "sched_latency_ns = "${s10}
        # sndusb_profile nrpacks=${u10}    nrpacks not supported anymore on newer kernels
        # echo "USB nrpacks="${u10}
    fi
}

sndusb_profile() {
local "${@}"
mpc pause > /dev/null 2>&1
sleep 0.3
modprobe -r snd-usb-audio
echo "options snd-usb-audio nrpacks=${nrpacks}" > /etc/modprobe.d/modprobe.conf
sleep 0.2
modprobe snd-usb-audio
sleep 0.5
#mpc play > /dev/null 2>&1
#mpc pause > /dev/null 2>&1
mpc play > /dev/null 2>&1
}

##################
# common startup #
##################
#if [ "$PID" != null  ]; then 
#echo "Set priority for: cifsd"
#renice -20 $PID
#fi
cifsprio pid=$(pidof cifsd)
echo "Set normal priority for: rune_SY_wrk"
renice 20 $(pgrep rune_SY_wrk)
echo "Set normal priority for: rune_PL_wrk"
renice 20 $(pgrep rune_PL_wrk)
echo "Set normal priority for: smbd"
renice 19 $(pidof smbd)
renice 19 $(pidof smb)
echo "Set normal priority for: nmbd"
renice 19 $(pidof nmbd)
renice 19 $(pidof nmb)

##################
# sound profiles #
##################

# default
if [ "$1" == "default" ]; then
ifconfig eth0 mtu 1500
ifconfig eth0 txqueuelen 1000
echo 60 > /proc/sys/vm/swappiness
modKschedLatency hw=$2 s01=6000000 s02=6000000 s03=6000000 s04=6000000 s05=6000000 s06=6000000 s07=6000000 s08=6000000 s09=6000000 s10=6000000 u01=8 u02=8 u03=8 u04=8 u05=8 u06=8 u07=8 u08=8 u09=8 u10=8
mpdprio_default
echo "DEFAULT sound signature profile"
fi

# default
if [ "$1" == "RuneAudio" ]; then
ifconfig eth0 mtu 1500
ifconfig eth0 txqueuelen 1000
echo 0 > /proc/sys/vm/swappiness
modKschedLatency hw=$2 s01=1500000 s02=4500000 s03=4500000 s04=4500000 s05=4500000 s06=4500000 s07=4500000 s08=4500000 s09=4500000 s10=4500000 u01=3 u02=3 u03=3 u04=3 u05=3 u06=3 u07=3 u08=3 u09=3 u10=3
mpdprio_nice
echo "RuneAudio  sound signature profile"
fi

# mod1
if [ "$1" == "ACX" ]; then
ifconfig eth0 mtu 1500
ifconfig eth0 txqueuelen 4000
echo 0 > /proc/sys/vm/swappiness
modKschedLatency hw=$2 s01=850000 s02=3500075 s03=3500075 s04=3500075 s05=3500075 s06=3500075 s07=3500075 s08=3500075 s09=3500075 s10=3500075 u01=2 u02=2 u03=2 u04=2 u05=2 u06=2 u07=2 u08=2 u09=2 u10=2
mpdprio_default
echo "(ACX) sound signature profile"
fi

# mod2
if [ "$1" == "Orion" ]; then
ifconfig eth0 mtu 1000
echo 20 > /proc/sys/vm/swappiness
modKschedLatency hw=$2 s01=500000 s02=500000 s03=500000 s04=1000000 s05=1000000 s06=1000000 s07=100000 s08=1000000 s09=1000000 s10=1000000 u01=1 u02=1 u03=1 u04=1 u05=1 u06=1 u07=1 u08=1 u09=1 u10=1
sleep 2
mpdprio_default
echo "(Orion) sound signature profile"
fi

# mod3
if [ "$1" == "OrionV2" ]; then
ifconfig eth0 mtu 1000
ifconfig eth0 txqueuelen 4000
echo 0 > /proc/sys/vm/swappiness
modKschedLatency hw=$2 s01=120000 s02=2000000 s03=2000000 s04=2000000 s05=2000000 s06=2000000 s07=2000000 s08=2000000 s09=2000000 s10=2000000 u01=2 u02=2 u03=2 u04=2 u05=2 u06=2 u07=2 u08=2 u09=2 u10=2
sleep 2
mpdprio_nice
echo "(OrionV2) sound signature profile"
fi

# mod4
if [ "$1" == "OrionV3_iqaudio" ]; then
ifconfig eth0 mtu 1000
ifconfig eth0 txqueuelen 4000
echo 0 > /proc/sys/vm/swappiness
#modKschedLatency hw=$2 s01=139950 s02=2000000 s03=2000000 s04=2000000 s05=2000000 s06=2000000 s07=2000000 s08=2000000 s09=2000000 s10=2000000 u01=2 u02=2 u03=2 u04=2 u05=2 u06=2 u07=2 u08=2 u09=2 u10=2 
if [ "$2" == "01" ]; then
    echo 1500000 > /proc/sys/kernel/sched_latency_ns
    echo 950000 > /proc/sys/kernel/sched_rt_period_us
    echo 950000 > /proc/sys/kernel/sched_rt_runtime_us
    echo 0 > /proc/sys/kernel/sched_autogroup_enabled
    echo 1 > /proc/sys/kernel/sched_rr_timeslice_ms
    echo 950000 > /proc/sys/kernel/sched_min_granularity_ns
    echo 1000000 > /proc/sys/kernel/sched_wakeup_granularity_ns
fi
sleep 2
mpdprio_nice
echo "(OrionV3 optimized for IQaudio Pi-DAC) sound signature profile"
fi

# mod5
if [ "$1" == "OrionV3_berrynosmini" ]; then
ifconfig eth0 mtu 1000
ifconfig eth0 txqueuelen 4000
echo 0 > /proc/sys/vm/swappiness
#modKschedLatency hw=$2 s01=139950 s02=2000000 s03=2000000 s04=2000000 s05=2000000 s06=2000000 s07=2000000 s08=2000000 s09=2000000 s10=2000000 u01=2 u02=2 u03=2 u04=2 u05=2 u06=2 u07=2 u08=2 u09=2 u10=2 
if [ "$2" == "01" ]; then
    echo 60 > /proc/sys/vm/swappiness
    echo 145655 > /proc/sys/kernel/sched_latency_ns
    echo 1 > /proc/sys/kernel/sched_rt_period_us
    echo 1 > /proc/sys/kernel/sched_rt_runtime_us
    echo 0 > /proc/sys/kernel/sched_autogroup_enabled
    echo 100 > /proc/sys/kernel/sched_rr_timeslice_ms
    echo 400000 > /proc/sys/kernel/sched_min_granularity_ns
    echo 1 > /proc/sys/kernel/sched_wakeup_granularity_ns
fi
sleep 2
mpdprio_nice
echo "(OrionV3 optimized for BerryNOS-mini I2S DAC) sound signature profile"
fi

# mod6
if [ "$1" == "Um3ggh1U" ]; then
ifconfig eth0 mtu 1500
ifconfig eth0 txqueuelen 1000
echo 0 > /proc/sys/vm/swappiness
modKschedLatency hw=$2 s01=500000 s02=3700000 s03=3700000 s04=3700000 s05=3700000 s06=3700000 s07=3700000 s08=3700000 s09=3700000 s10=3700000 u01=3 u02=3 u03=3 u04=3 u05=3 u06=3 u07=3 u08=3 u09=3 u10=3
mpdprio_default
echo "(Um3ggh1U) sound signature profile"
fi

# dev
if [ "$1" == "dev" ]; then
echo "flush DEV sound profile 'fake'"
fi

if [ "$1" == "" ]; then
echo "Orion Optimize Script v$ver" 
echo "Usage: $0 {default|RuneAudio|ACX|Orion|OrionV2|OrionV3_iqaudio|OrionV3_berrynosmini|Um3ggh1U} {architectureID}"
exit 1
fi
