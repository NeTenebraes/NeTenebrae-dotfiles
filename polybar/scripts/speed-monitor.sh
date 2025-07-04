#!/bin/sh

# Función para formatear bytes a un formato legible (KB/s, MB/s)
format_speed() {
    speed=$1
    if [ "$speed" -lt 1024 ]; then
        echo "${speed} B/s"
    elif [ "$speed" -lt 1048576 ]; then
        echo $(echo "scale=1; $speed/1024" | bc) "KB/s"
    else
        echo $(echo "scale=1; $speed/1048576" | bc) "MB/s"
    fi
}

# Bucle infinito para medir y mostrar la velocidad constantemente
while true; do
    # Detectamos la interfaz activa
    ACTIVE_IFACE=$(ip route | grep '^default' | awk '{print $5}')

    # Si no hay interfaz activa, mostramos el icono de desconectado y esperamos
    if [ -z "$ACTIVE_IFACE" ]; then
        echo "󰤮"
    else
        # Leemos los bytes de subida y bajada en el momento actual
        RX_BYTES_NOW=$(cat /sys/class/net/$ACTIVE_IFACE/statistics/rx_bytes)
        TX_BYTES_NOW=$(cat /sys/class/net/$ACTIVE_IFACE/statistics/tx_bytes)

        # Esperamos un segundo
        sleep 1

        # Volvemos a leer los bytes para calcular la diferencia
        RX_BYTES_LATER=$(cat /sys/class/net/$ACTIVE_IFACE/statistics/rx_bytes)
        TX_BYTES_LATER=$(cat /sys/class/net/$ACTIVE_IFACE/statistics/tx_bytes)

        # Calculamos la velocidad en bytes por segundo
        RX_SPEED=$((RX_BYTES_LATER - RX_BYTES_NOW))
        TX_SPEED=$((TX_BYTES_LATER - TX_BYTES_NOW))

        # Formateamos la velocidad a un formato legible
        RX_FORMATTED=$(format_speed $RX_SPEED)
        TX_FORMATTED=$(format_speed $TX_SPEED)

        # Imprimimos la línea final para Polybar
        echo "󰁅 $RX_FORMATTED  󰁝 $TX_FORMATTED"
    fi
done