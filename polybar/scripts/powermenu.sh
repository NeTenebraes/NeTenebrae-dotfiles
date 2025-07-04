#!/bin/sh

# Opciones del menú con iconos de Nerd Fonts
opciones=" Apagar\n Reiniciar\n Cerrar Sesión\n Bloquear\n Suspender"

# Llama a Rofi para mostrar el menú
# El usuario elige una opción y la guardamos en la variable 'seleccion'
seleccion=$(echo -e "$opciones" | rofi -dmenu -p "Sistema")

# Usamos un 'case' para ejecutar un comando según la opción elegida
case "$seleccion" in
    *Apagar)
        systemctl poweroff
        ;;
    *Reiniciar)
        systemctl reboot
        ;;
    *Cerrar*)
        i3-msg exit
        ;;
    *Bloquear)
        i3lock-fancy
        ;;
    *Suspender)
        systemctl suspend
        ;;
esac