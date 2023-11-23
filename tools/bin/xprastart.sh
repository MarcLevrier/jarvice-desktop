#!/usr/bin/env bash

# ------------------------
# Check VirtualGL presence
# ------------------------

. /etc/JARVICE/vglinfo.sh
if [ ! -x /usr/bin/vglrun ]; then
	    export VGL_DISPLAY=""
    fi

cd

#if [ -d /etc/X11/fontpath.d ]; then
#    FP="-fp catalogue:/etc/X11/fontpath.d,built-ins"
#fi

# RealVNC server case
#    echo "Enabling RealVNC server for VNC service"
#    sudo cp -f /etc/NAE/help-real.html /etc/NAE/help.html
#    mkdir -p ~/.vnc/config.d
#    chmod 700 ~/.vnc/config.d
#    cp -f /usr/lib/JARVICE/tools/etc/realvnc.key ~/.vnc/private.key
#    chmod 600 ~/.vnc/private.key
#
#    VNCPASSWD=$(cat /etc/JARVICE/vncpasswd-RealVNC)
#    cat <<EOF >~/.vnc/config.d/Xvnc
#Password=$VNCPASSWD
#EOF
#    touch ~/.vnc/config.d/.Xvnc-v5-marker
#    vncserver -geometry "$VNC_GEOMETRY" -StartUI=1 -EnableAutoUpdateChecks=0 \
#        -ConnNotifyTimeout=0 \
#        -AllowHttp=0 -Encryption PreferOn -Authentication VncAuth \
#        -DisableAddNewClient -EnableRemotePrinting=0 -dpi 100 \
#        -SecurityTypes RA2:256+,RA2,RA2ne,VeNCrypt,TLSVnc,VncAuth $FP :1

# TigerVNC case
# Install Tiger from local tarball or package
# /usr/local/lib/nimbix_desktop/install-tiger.sh

# Start the Tiger server
# vncserver -geometry "$VNC_GEOMETRY" -rfbauth /etc/JARVICE/vncpasswd \
#     -dpi 100 -SecurityTypes=VeNCrypt,TLSVnc,VncAuth :1

export DISPLAY=:1
export LANG=en_US.UTF-8
export TERM=xterm
export VGL_READBACK=sync

# ---------------------------------------------------------------------------
# This section starts Xpra (which automatically spawns an HTML5 / web server)
# Disable TLS authent for testing using --ssl-server-verify-mode=none
#
# Client-side usage:
# - Attach Xpra client CLI using 'xpra attach ssl://public.ip:5903/'
# - Attach from a web browser supporting HTML5 using 'https://public.ip:443/'
# TODO: check if 5903 is OK (5901|2 seem to be for *VNC)
# ---------------------------------------------------------------------------

#xpra start --bind-tcp=0.0.0.0:5903 ${DISPLAY} --daemon=no -dbus-control=no -dbus-launch=no > /tmp/xpra.log 2>&1
    # --ssl-cert=/etc/JARVICE/cert.pem --bind-tcp=127.0.0.1:443 \ # Secured https connection (no self-signed cert)
    # --exit-with-children --start-child='${ChildAppBinary}'    # TODO: Get application binary (for seamless?) 

# DHP: test using --ssl-cert
#xpra start --bind-tcp=0.0.0.0:5903 ${DISPLAY} --daemon=no -dbus-control=no -dbus-launch=no --ssl-cert=/etc/pki/ca-trust/source/anchors/domain.crt > /tmp/xpra.log 2>&1
xpra start --bind-tcp=0.0.0.0:5903 ${DISPLAY} --daemon=no -dbus-control=no -dbus-launch=no --ssl-cert=/etc/JARVICE/cert.pem --bind-tcp=127.0.0.1:443 > /tmp/xpra.log 2>&1

# ------------------------------------------
# Create links to the vault mounted at /data
# ------------------------------------------

ln -sf /data .
mkdir -p Desktop
ln -sf /data Desktop
sleep 2

# -------------------------------
# Start with VirtualGL. Or not...
# -------------------------------

if [ -z "$VGL_DISPLAY" ]; then
    exec "$@"
else
    exec vglrun -d $VGL_DISPLAY "$@"
fi
