#!/bin/sh

anlix_bootup_defaults() {
	ifconfig wlan0 up
	iwpriv wlan0 set_mib xcap=12
	iwpriv wlan0 set_mib ther=32
	iwpriv wlan0 set_mib pwrlevelCCK_A=2c2c2c2f2f2f2f2f2f3131313131
	iwpriv wlan0 set_mib pwrlevelCCK_B=2d2d2d3030303030302f2f2f2f2f
	iwpriv wlan0 set_mib pwrlevelHT40_1S_A=2a2a2a2929292929292a2a2a2a2a
	iwpriv wlan0 set_mib pwrlevelHT40_1S_B=2a2a2a2a2a2a2a2a2a2a2a2a2a2a
	iwpriv wlan0 set_mib pwrdiffHT20=1111111111111111111111111111
	iwpriv wlan0 set_mib pwrdiffOFDM=3333333333333333333333333333
	ifconfig wlan0 down

	ifconfig wlan1 up
	iwpriv wlan1 set_mib xcap=41
	iwpriv wlan1 set_mib ther=24
	iwpriv wlan1 set_mib pwrlevel5GHT40_1S_A=00000000000000000000000000000000000000000000000000000000000000000000002a2a2a2a2a2a2a282828282828272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292929292a2a2a2a2a2a2a2a2a2a2929292929292d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2c2c2c2c2c2c2c2c2c2c2c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e00000000000000000000000000000000000000
	iwpriv wlan1 set_mib pwrlevel5GHT40_1S_B=00000000000000000000000000000000000000000000000000000000000000000000002828282828282826262626262625252525252525252525252525252525292929292929292929292929292929292929292929292929292929292929292929292929292929292929282828282828272727272727272727272828282828282c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2b2b2b2b2b2b2b2b2b2b2b2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d00000000000000000000000000000000000000
	iwpriv wlan1 set_mib pwrdiff_5G_20BW1S_OFDM1T_A=00000000000000000000000000000000000000000000000000000000000000000000001313131313131313131313131324242424242424242424242424242424131313131313131313131313131313131313131313131313131313131313131313131313131313130202020202020202020202020202020202020202020202020202020202020202020202020202020203030303030303030313131313131313131313131313131313131313131313131300000000000000000000000000000000000000
	iwpriv wlan1 set_mib pwrdiff_5G_20BW1S_OFDM1T_B=00000000000000000000000000000000000000000000000000000000000000000000001313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313132525252525252525363636363636363636363636363636363636363636363636363636363636363602020202020202020213131313131313131313131313131313131313131313131300000000000000000000000000000000000000
	iwpriv wlan1 set_mib pwrdiff_5G_80BW1S_160BW1S_A=0000000000000000000000000000000000000000000000000000000000000000000000e0e0e0e0e0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d0d0d0d0d0d0d0b0b0b0b0b0b0b0b0a0a0a0a0a0a0a0a090909090909090909090909090909090e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000000000000000000000000000
	iwpriv wlan1 set_mib pwrdiff_5G_80BW1S_160BW1S_B=0000000000000000000000000000000000000000000000000000000000000000000000e0e0e0e0e0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0d0d0d0d0d0d0d0d0c0c0c0c0c0c0c0c0b0b0b0b0b0b0b0b0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000000000000000000000000000
	ifconfig wlan1 down
}

get_custom_mac() {
	. /lib/functions/system.sh
	local _mac_address_tag=""
	local _p1

	_p1=$(mtd_get_mac_binary config 19 | awk '{print toupper($1)}')
	[ ! -z "$_p1" ] && _mac_address_tag=$_p1

	echo "$_mac_address_tag"
}

set_bridge_on_boot() {
	echo "1"
}

is_realtek() {
	echo "1"
}

custom_switch_ports() {
	case $1 in
		1) echo "switch0" ;;
		2) echo "0" ;;
		3) echo "1 2 3 4" ;;
		4) echo "6" ;;
		5) echo "4" ;;
	esac
}
