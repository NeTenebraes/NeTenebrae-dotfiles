#!/bin/sh

# Comprueba si el Bluetooth está encendido buscando la línea "Powered: yes"
if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]; then
  # Si no la encuentra, el Bluetooth está apagado. Muestra icono gris/tachado.
  echo "%{F#6272A4}󰂲%{F-}"
else
  # Si está encendido, comprobamos si hay algún dispositivo conectado.
  if [ $(echo info | bluetoothctl | grep 'Device' | wc -c) -eq 0 ]; then
    # Si no hay dispositivos, muestra el icono azul de "encendido".
    echo "%{F#8BE9FD}󰂯%{F-}"
  else
    # Si hay al menos un dispositivo, muestra el icono verde de "conectado".
    echo "%{F#50FA7B}󰂱%{F-}"
  fi
fi # <-- ESTE 'fi' ERA EL QUE FALTABA PARA CERRAR EL PRIMER 'if'.