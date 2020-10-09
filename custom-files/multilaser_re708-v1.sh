#!/bin/sh

anlix_bootup_defaults() {
	ifconfig wlan0 up
	iwpriv wlan0 set_mib xcap=35
	iwpriv wlan0 set_mib ther=0
	iwpriv wlan0 set_mib pwrlevelCCK_A=2c2c2c2c2c2c2c2c2c2d2d2d2d2d
	iwpriv wlan0 set_mib pwrlevelCCK_B=2929292b2b2b2b2b2b2b2b2b2b2b
	iwpriv wlan0 set_mib pwrlevelHT40_1S_A=2828282828282828282929292929
	iwpriv wlan0 set_mib pwrlevelHT40_1S_B=2525252727272727272727272727
	ifconfig wlan0 down

	ifconfig wlan1 up
	iwpriv wlan1 set_mib xcap=30
	iwpriv wlan1 set_mib ther=0
	iwpriv wlan1 set_mib pwrlevel5GHT40_1S_A=00000000000000000000000000000000000000000000000000000000000000000000001d1d1d1d1d1c1c1c1c1c1c1c1c1b1b1b1b1b1b1b1b1919191919191919181818181818181818181818181818181818181818181818181818181818181818181818181818181717171717171717171717171717171716161616161616161717171717171717171717171717171712121212121212121210101010101010100b0b0b0b0b0b0b0b060606060606060600000000000000000000000000000000000000
	iwpriv wlan1 set_mib pwrlevel5GHT40_1S_B=00000000000000000000000000000000000000000000000000000000000000000000001c1c1c1c1c1b1b1b1b1b1b1b1b1a1a1a1a1a1a1a1a181818181818181817171717171717171717171717171717171717171717171717171717171717171717171717171717161616161616161616161616161616161515151515151515161616161616161616161616161616161010101010101010100e0e0e0e0e0e0e0e0909090909090909040404040404040400000000000000000000000000000000000000
	ifconfig wlan1 down
}

get_custom_mac() {
	. /lib/functions/system.sh
	local _mac_address_tag=""
	local _p1

	_p1=$(mtd_get_mac_binary boot 131079 | awk '{print toupper($1)}')
	[ ! -z "$_p1" ] && _mac_address_tag=$_p1

	echo "$_mac_address_tag"
}

set_switch_bridge_mode_on_boot() {
	local _disable_lan_ports="$1"

	if [ "$_disable_lan_ports" = "y" ]
	then
		# eth0
		swconfig dev switch0 vlan 9 set ports ''
		# eth1
		swconfig dev switch0 vlan 8 set ports '4 6'
	else
		# eth0
		swconfig dev switch0 vlan 9 set ports ''
		# eth1
		swconfig dev switch0 vlan 8 set ports '0 1 2 3 4 6'
	fi
}

custom_switch_ports() {
	case $1 in 
		1) echo "switch0" ;;
		2) echo "4" ;;
		3) echo "0 1 2 3" ;;
	esac
}

custom_wifi_24_txpower(){
	echo "22"
}
