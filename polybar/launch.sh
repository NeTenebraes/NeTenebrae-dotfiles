#!/usr/bin/env bash

# Terminate already running Polybar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done

# Define el archivo de log para Polybar
LOG_FILE="/tmp/polybar_$(date +%Y%m%d_%H%M%S).log" # Crea un archivo de log con timestamp

# Lanza la barra principal (top) y redirige toda la salida al archivo de log
echo "--- Lanzando Polybar 'main' ---" >> "$LOG_FILE"
polybar -c ~/.config/polybar/config.ini main >> "$LOG_FILE" 2>&1 &
disown

# Lanza la barra inferior y redirige toda la salida al mismo archivo de log
echo "--- Lanzando Polybar 'bottom_bar' ---" >> "$LOG_FILE"
polybar -c ~/.config/polybar/config.ini bottom_bar >> "$LOG_FILE" 2>&1 &
disown

echo "Polybar bars launched. Check logs in: $LOG_FILE"