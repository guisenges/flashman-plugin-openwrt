#!/bin/sh

#
# WARNING! This file may be replaced depending on the selected target!
#

. /usr/share/flashman_init.conf
. /usr/share/functions.sh

MAC_LAST_CHARS=$(get_mac | awk -F: '{ print $5$6 }')
SSID_VALUE=$(uci get wireless.@wifi-iface[0].ssid)
ENCRYPTION_VALUE=$(uci get wireless.@wifi-iface[0].encryption)

# Wireless password cannot be empty or have less than 8 chars
if [ "$FLM_PASSWD" == "" ] || [ $(echo "$FLM_PASSWD" | wc -m) -lt 9 ]
then
  FLM_PASSWD=$(get_mac | sed -e "s/://g")
fi

# Configure WiFi default SSID and password
if { [ "$SSID_VALUE" = "OpenWrt" ] || [ "$SSID_VALUE" = "LEDE" ]; } && \
     [ "$ENCRYPTION_VALUE" != "psk2" ]
then
  if [ "$FLM_SSID_SUFFIX" == "none" ]
  then
    #none
    setssid="$FLM_SSID"
  else
    #lastmac
    setssid="$FLM_SSID$MAC_LAST_CHARS"
  fi

  uci set wireless.@wifi-device[0].type="mac80211"
  uci set wireless.@wifi-device[0].txpower="17"
  uci set wireless.@wifi-device[0].disabled="0"
  uci set wireless.@wifi-device[0].channel="$FLM_24_CHANNEL"
  uci set wireless.@wifi-device[0].hwmode="11n"
  uci set wireless.@wifi-device[0].country="BR"
  uci set wireless.@wifi-device[0].htmode="HT40"
  uci set wireless.@wifi-iface[0].ssid="$setssid"
  uci set wireless.@wifi-iface[0].encryption="psk2"
  uci set wireless.@wifi-iface[0].key="$FLM_PASSWD"

  # 5GHz
  if [ "$(uci -q get wireless.@wifi-iface[1])" ]
  then
    uci set wireless.@wifi-device[1].disabled="0"
    uci set wireless.@wifi-device[1].type="mac80211"
    uci set wireless.@wifi-device[1].channel="36"
    uci set wireless.@wifi-iface[1].ssid="$setssid"
    uci set wireless.@wifi-iface[1].encryption="psk2"
    uci set wireless.@wifi-iface[1].key="$FLM_PASSWD"
  fi
  uci commit wireless
fi

exit 0
