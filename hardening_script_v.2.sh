#!/bin/bash

# =========================================================
# Script de Hardening Conservador para Ubuntu Studio 20.04
# Autor: Gemini
# Descripción: Aplica endurecimiento de red y kernel
#              de forma segura, minimizando el riesgo de
#              afectar la funcionalidad del sistema.
# =========================================================

# --- 1. Copia de seguridad de la configuración actual ---
echo "Realizando una copia de seguridad de sysctl.conf..."
cp /etc/sysctl.conf /etc/sysctl.conf.bak
if [ $? -ne 0 ]; then
    echo "Error: No se pudo crear la copia de seguridad. Abortando."
    exit 1
fi

# --- 2. Aplicar endurecimiento de red y kernel a través de sysctl ---
echo "Aplicando configuraciones de hardening de kernel..."

# Crear un archivo de configuración para el endurecimiento.
# Las configuraciones aquí se enfocan en la seguridad de la red.
cat <<EOF > /etc/sysctl.d/99-custom-hardening.conf
# Deshabilitar la respuesta a peticiones de ping ICMP broadcast para prevenir ataques de smurf
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Habilitar la protección contra SYN-cookies para mitigar ataques de SYN-flood
net.ipv4.tcp_syncookies = 1

# Deshabilitar el reenvío de paquetes IP. Esto previene que el host actúe como un router.
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Deshabilitar la redirección de rutas ICMP. Esto puede ser usado para engañar a los hosts.
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Protección contra spoofing (filtrado de ruta de origen)
# 1: Habilitado (recomendado).
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Deshabilitar la carga de nuevos espacios de nombres de usuarios sin privilegios.
kernel.unprivileged_userns_clone = 0

# Ignorar peticiones ICMP de broadcast/multicast (generalmente seguras)
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Proteger contra la redirección de la ruta ICMP
net.ipv4.conf.all.secure_redirects = 0

# Evitar ataques de denegación de servicio (DoS) ajustando los límites de paquetes
net.core.netdev_max_backlog = 2000
net.core.somaxconn = 2048

# Limitar el uso de recursos para prevenir ataques DoS
net.ipv4.tcp_max_syn_backlog = 2048
EOF

# Cargar las nuevas configuraciones
sysctl --system

echo "Hardening completado. Por favor, reinicia tu sistema para que los cambios surtan efecto."
