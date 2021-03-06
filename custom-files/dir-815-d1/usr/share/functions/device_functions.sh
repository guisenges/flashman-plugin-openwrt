#!/bin/sh

is_5ghz_capable() {
  # true
  echo "1"
}

get_wifi_device_stats() {
  local _dev_mac="$1"
  local _dev_info
  local _wifi_stats=""
  local _retstatus
  local _cmd_res
  local _wifi_itf="wlan0"
  local _ap_freq="2.4"

  _cmd_res=$(command -v iw)
  _retstatus=$?

  if [ $_retstatus -eq 0 ]
  then
    _dev_info="$(iw dev $_wifi_itf station get $_dev_mac 2> /dev/null)"
    _retstatus=$?

    if [ $_retstatus -ne 0 ]
    then
      _wifi_itf="wlan1"
      _ap_freq="5.0"
      _dev_info="$(iw dev $_wifi_itf station get $_dev_mac 2> /dev/null)"
      _retstatus=$?
    fi

    if [ $_retstatus -eq 0 ]
    then
      local _dev_txbitrate="$(echo "$_dev_info" | grep 'tx bitrate:' | \
                              awk '{print $3}')"
      local _dev_rxbitrate="$(echo "$_dev_info" | grep 'rx bitrate:' | \
                              awk '{print $3}')"
      local _dev_mcs="$(echo "$_dev_info" | grep 'tx bitrate:' | \
                        awk '{print $5}')"
      local _dev_signal="$(echo "$_dev_info" | grep 'signal:' | \
                           awk '{print $2}' | awk -F. '{print $1}')"
      local _ap_noise="$(iwinfo $_wifi_itf info | grep 'Noise:' | \
                         awk '{print $5}' | awk -F. '{print $1}')"
      local _dev_txbytes="$(echo "$_dev_info" | grep 'tx bytes:' | \
                            awk '{print $3}')"
      local _dev_rxbytes="$(echo "$_dev_info" | grep 'rx bytes:' | \
                            awk '{print $3}')"
      local _dev_txpackets="$(echo "$_dev_info" | grep 'tx packets:' | \
                              awk '{print $3}')"
      local _dev_rxpackets="$(echo "$_dev_info" | grep 'rx packets:' | \
                              awk '{print $3}')"

      # Calculate SNR
      local _dev_snr="$(($_dev_signal - $_ap_noise))"

      _wifi_stats="$_dev_txbitrate $_dev_rxbitrate $_dev_signal"
      _wifi_stats="$_wifi_stats $_dev_snr $_ap_freq"

      if [ "$_dev_mcs" == "VHT-MCS" ]
      then
        # N or AC
        _wifi_stats="$_wifi_stats AC"
      else
        # G Mode
        _wifi_stats="$_wifi_stats N"
      fi
      # Traffic data
      _wifi_stats="$_wifi_stats $_dev_txbytes $_dev_rxbytes"
      _wifi_stats="$_wifi_stats $_dev_txpackets $_dev_rxpackets"

      echo "$_wifi_stats"
    else
      echo "0.0 0.0 0.0 0.0 0 Z 0 0 0 0"
    fi
  else
    echo "0.0 0.0 0.0 0.0 0 Z 0 0 0 0"
  fi
}

is_device_wireless() {
  local _dev_mac="$1"
  local _dev_info
  local _retstatus
  local _cmd_res
  local _wifi_itf="wlan0"

  _cmd_res=$(command -v iw)
  _retstatus=$?

  if [ $_retstatus -eq 0 ]
  then
    _dev_info="$(iw dev $_wifi_itf station get $_dev_mac 2> /dev/null)"
    _retstatus=$?

    if [ $_retstatus -ne 0 ]
    then
      _wifi_itf="wlan1"
      _dev_info="$(iw dev $_wifi_itf station get $_dev_mac 2> /dev/null)"
      _retstatus=$?
    fi

    if [ $_retstatus -eq 0 ]
    then
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

led_on() {
  if [ -f "$1"/brightness ]
  then
    if [ -f "$1"/max_brightness ]
    then
      cat "$1"/max_brightness > "$1"/brightness
    else
      echo "255" > "$1"/brightness
    fi
  fi
}

led_off() {
  if [ -f "$1"/trigger ]
  then
    echo "none" > "$1"/trigger
    echo "0" > "$1"/brightness
  fi
}

reset_leds() {
  for trigger_path in $(ls -d /sys/class/leds/*)
  do
    led_off "$trigger_path"
  done

  /etc/init.d/led restart > /dev/null

  for system_led in /sys/class/leds/*system*
  do
    led_on "$system_led"
  done

  # reset hardware lan ports if any
  for lan_led in /sys/class/leds/*lan*
  do
    if [ -f "$lan_led"/enable_hw_mode ]
    then
      echo 1 > "$lan_led"/enable_hw_mode
    fi
  done

  # reset hardware wan port if any
  for wan_led in /sys/class/leds/*wan*
  do
    if [ -f "$wan_led"/enable_hw_mode ]
    then
      echo 1 > "$wan_led"/enable_hw_mode
    fi
  done
}

blink_leds() {
  local _do_restart=$1

  if [ $_do_restart -eq 0 ]
  then
    ledsoff=$(ls -d /sys/class/leds/*)
    for trigger_path in $ledsoff
    do
      echo "timer" > "$trigger_path"/trigger
    done
  fi
}

get_mac() {
  local _mac_address_tag=""
  local _p1

  _p1=$(awk '{print toupper($1)}' /sys/class/net/eth1/address)
  if [ ! -z "$_p1" ]
  then
    _mac_address_tag=$_p1
  fi

  echo "$_mac_address_tag"
}

# Possible values: empty, 10, 100 or 100
get_wan_negotiated_speed() {
  swconfig dev switch0 port 4 get link | \
  awk '{print $3}' | awk -F: '{print $2}' | awk -Fbase '{print $1}'
}

# Possible values: empty, half or full
get_wan_negotiated_duplex() {
  swconfig dev switch0 port 4 get link | \
  awk '{print $4}' | awk -F- '{print $1}'
}

get_lan_dev_negotiated_speed() {
  local _speed="0"
  local _switch="switch0"
  local _vlan="9"
  local _retstatus

  for _port in $(swconfig dev $_switch vlan $_vlan get ports)
  do
    # Check if it's not a bridge port
    echo "$_port" | grep -q "6"
    _retstatus=$?
    if [ $_retstatus -eq 1 ]
    then
      local _speed_tmp="$(swconfig dev $_switch port $_port get link | \
                          awk -F: '{print $4}' | awk -F 'baseT' '{print $1}')"
      if [ "$_speed_tmp" != "" ]
      then
        if [ "$_speed" != "0" ]
        then
          if [ "$_speed" != "$_speed_tmp" ]
          then
            # Different values. Return 0 since we cannot know the correct value
            _speed="0"
          fi
        else
          # First assignment
          _speed="$_speed_tmp"
        fi
      fi
    fi
  done

  echo "$_speed"
}

# Enable/disable ethernet connection on LAN physical ports when in bridge mode
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

# Needs reboot to validate switch config
needs_reboot_bridge_mode() {
  reboot
}
