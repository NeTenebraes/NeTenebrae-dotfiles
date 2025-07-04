#!/bin/sh

# Audio Control Hub by Gemini (for NeTenebrae)
# Location: Cali, Colombia - Time: Thursday, June 26, 2025

# --- Funciones Auxiliares ---

# Obtiene el estado y volumen del sink por defecto
get_sink_status() {
    if pactl get-sink-mute @DEFAULT_SINK@ | grep -q 'yes'; then
        echo "󰝟 Muted"
    else
        echo "󰕾  "$(pactl get-sink-volume @DEFAULT_SINK@ | grep 'Volume:' | head -n1 | awk '{print $5}')
    fi
}

# Alterna el mute del sink por defecto
toggle_sink_mute() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle
}

# Alterna el mute del source por defecto
toggle_source_mute() {
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
}

# --- Generación del Menú ---

# Genera la lista de opciones para Rofi
generate_menu() {
    # Estado y controles principales
    echo "$(get_sink_status)"
    echo "󰝟 Mute/Unmute Output"
    echo "󰍭 Mute/Unmute Input"
    echo "-----------[ Outputs ]-----------"

    # Listar Sinks (Salidas)
    default_sink=$(pactl info | grep 'Default Sink' | awk '{print $3}')
    pactl list short sinks | while read -r line; do
        name=$(echo "$line" | awk '{print $2}')
        description=$(pactl list sinks | grep -A 5 "Name: $name" | grep "Description:" | sed 's/^[[:space:]]*Description: //')
        icon=""
        echo "$description" | grep -q -i "hdmi" && icon="󰡂"
        echo "$description" | grep -q -i "headphones" && icon="󰋋"
        echo "$description" | grep -q -i "speakers" && icon="󰓃"

        if [ "$name" = "$default_sink" ]; then
            echo "✓ $icon $description"
        else
            echo "  $icon $description"
        fi
    done

    echo "-----------[ Inputs ]------------"
    # Listar Sources (Entradas)
    default_source=$(pactl info | grep 'Default Source' | awk '{print $3}')
    pactl list short sources | while read -r line; do
        name=$(echo "$line" | awk '{print $2}')
        description=$(pactl list sources | grep -A 5 "Name: $name" | grep "Description:" | sed 's/^[[:space:]]*Description: //')
        if echo "$description" | grep -qv "Monitor of"; then
            icon="󰍬"
            if [ "$name" = "$default_source" ]; then
                echo "✓ $icon $description"
            else
                echo "  $icon $description"
            fi
        fi
    done

    echo "--------[ App Volumes ]--------"
    # Listar Sink-Inputs (Aplicaciones)
    pactl list short sink-inputs | while read -r line; do
        index=$(echo "$line" | awk '{print $1}')
        app_name=$(pactl list sink-inputs | grep -A 5 "Sink Input #$index" | grep "application.name" | sed 's/.*= "\(.*\)"/\1/')
        is_muted=$(pactl list sink-inputs | grep -A 5 "Sink Input #$index" | grep "Mute:" | awk '{print $2}')

        if [ "$is_muted" = "yes" ]; then
            echo " Mute $app_name"
        else
            echo " Unmute $app_name"
        fi
    done

    echo "-------------------------------"
    echo " Open Full Mixer"
}

# --- Lógica Principal ---

# Muestra Rofi y captura la selección
choice=$(generate_menu | rofi -dmenu -i -p "Audio Control Hub")

# Si no se eligió nada, salir
[ -z "$choice" ] && exit 0

# Ejecutar acciones basadas en la elección
case "$choice" in
    *"Mute/Unmute Output"*)
        toggle_sink_mute
        ;;
    *"Mute/Unmute Input"*)
        toggle_source_mute
        ;;
    *"Open Full Mixer"*)
        pavucontrol &
        ;;
    *"Mute "*) # Para silenciar una app específica
        index=$(pactl list short sink-inputs | grep "$(echo $choice | sed 's/Mute //')" | awk '{print $1}')
        [ -n "$index" ] && pactl set-sink-input-mute "$index" toggle
        ;;
    *"Unmute "*) # Para activar el sonido de una app específica
        index=$(pactl list short sink-inputs | grep "$(echo $choice | sed 's/Unmute //')" | awk '{print $1}')
        [ -n "$index" ] && pactl set-sink-input-mute "$index" toggle
        ;;
    *) # Para cambiar dispositivos de salida o entrada
        name_part=$(echo "$choice" | sed -e 's/✓ //' -e 's/  //' -e 's/󰋋 //' -e 's/󰓃 //' -e 's/ //' -e 's/󰡂 //' -e 's/󰍬 //')
        sink_name=$(pactl list short sinks | grep "$name_part" | awk '{print $2}')
        source_name=$(pactl list short sources | grep "$name_part" | awk '{print $2}')

        if [ -n "$sink_name" ]; then
            pactl set-default-sink "$sink_name"
        elif [ -n "$source_name" ]; then
            pactl set-default-source "$source_name"
        fi
        ;;
esac