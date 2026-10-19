#!/bin/bash

# avahi as a client only: it finds scanners and printers, but doesn't announce this machine's name and
# addresses on the network (public wifi). The file belongs to pacman, which keeps this edit on upgrades.
avahi_config=/etc/avahi/avahi-daemon.conf
if ! grep -q '^disable-publishing=yes' "$avahi_config"; then
  if grep -Eq '^#?disable-publishing=' "$avahi_config"; then
    sudo sed -i -E 's/^#?disable-publishing=.*/disable-publishing=yes/' "$avahi_config"
  else
    sudo sed -i '/^\[publish\]/a disable-publishing=yes' "$avahi_config"
  fi
  avahi_config_changed=1
fi

# sane-airscan finds eSCL scanners through avahi. Started now as well, so scanning works before a reboot.
sudo systemctl enable --now avahi-daemon.service
if [[ -n $avahi_config_changed ]]; then
  sudo systemctl restart avahi-daemon.service
fi
