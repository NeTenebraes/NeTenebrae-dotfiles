#!/bin/sh


# --- Configuración ---

# Un archivo temporal para guardar el estado (qué interfaz estamos viendo)

STATE_FILE="/tmp/polybar_net_cycler_state"

# Un array con los nombres de los módulos que queremos ciclar

INTERFACES=("eth" "wlan" "usb")


# --- Lógica del Script ---

# Si no existe el archivo de estado, lo creamos y ponemos en 0

[ ! -f "$STATE_FILE" ] && echo 0 > "$STATE_FILE"


# Si el script fue llamado con el argumento '--click'

if [ "$1" = "--click" ]; then

# Leemos el índice actual, le sumamos 1, y usamos el módulo (%) para que cicle

current_index=$(cat "$STATE_FILE")

next_index=$(((current_index + 1) % ${#INTERFACES[@]}))

echo "$next_index" > "$STATE_FILE"

fi


# Leemos el índice actual para saber qué mostrar

current_index=$(cat "$STATE_FILE")

current_interface=${INTERFACES[$current_index]}


# Obtenemos el icono y la IP para la interfaz actual

case "$current_interface" in

"eth")

icon="󰈀"

ip=$(ip -4 addr show enp5s0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

;;

"wlan")

icon="󰤨"

ip=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

;;

"usb")

icon=""

ip=$(ip -4 addr show enp0s29u1u2 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

;;

esac


# Si no hay IP, mostramos "N/A"

if [ -z "$ip" ]; then

ip="N/A"

fi


# Imprimimos la salida para Polybar

echo "$icon $ip" 