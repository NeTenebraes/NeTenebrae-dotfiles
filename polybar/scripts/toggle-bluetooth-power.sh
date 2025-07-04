#!/bin/sh

if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]; then
  # Si está apagado, lo enciende.
  bluetoothctl power on
else
  # Si está encendido, lo apaga.
  bluetoothctl power off
fi