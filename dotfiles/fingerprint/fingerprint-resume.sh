#!/bin/bash
# Systemd sleep hook — rebind xhci controller if Goodix fingerprint reader
# disappears after resume (error -22 / PM resume failure)

GOODIX_VENDOR="27c6"
GOODIX_PRODUCT="609c"

find_device() {
  for dev in /sys/bus/usb/devices/*/; do
    local v p
    v=$(cat "${dev}idVendor" 2>/dev/null)
    p=$(cat "${dev}idProduct" 2>/dev/null)
    [ "$v" = "$GOODIX_VENDOR" ] && [ "$p" = "$GOODIX_PRODUCT" ] && return 0
  done
  return 1
}

case "$1" in
  post)
    sleep 3
    if find_device; then
      logger "fingerprint-resume: Goodix present, nothing to do"
      exit 0
    fi

    logger "fingerprint-resume: Goodix not detected after resume, rebinding xhci controller"

    XHCI_ID=$(readlink -f /sys/bus/usb/devices/usb1 2>/dev/null | sed 's|/usb1$||; s|.*/||')
    # usb1 may be gone after failed resume, fall back to known path
    if [ -z "$XHCI_ID" ] || [ "$XHCI_ID" = "usb1" ]; then
      XHCI_ID="0000:c1:00.4"
    fi

    echo "$XHCI_ID" > /sys/bus/pci/drivers/xhci_hcd/unbind
    sleep 1
    echo "$XHCI_ID" > /sys/bus/pci/drivers/xhci_hcd/bind
    sleep 3

    if find_device; then
      logger "fingerprint-resume: Goodix restored successfully"
    else
      logger "fingerprint-resume: Goodix still not found after rebind"
    fi
    ;;
esac
