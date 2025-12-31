# config-scripts
Auto installations for packages for chromebooks and misc

**Usage**

Arch Linux (prefered):
```
bash -c "$(wget -qO- https://raw.githubusercontent.com/agustux/config-scripts/main/chrultrabook-setup-arch.sh)"
```

Ubuntu:
```
bash -c "$(wget -qO- https://raw.githubusercontent.com/agustux/config-scripts/main/chrultrabook-setup-ubuntu24-04.sh)"
```

Real-time CPU frequency reading: `watch -n1 "grep 'MHz' /proc/cpuinfo"`

Current CPU temperatures: `paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'`

Current iGPU freq (Intel ONLY): `sudo intel_gpu_top`

To see max iGPU freq (Intel ONLY): `sudo intel_gpu_frequency --max`

**Ubuntu Only:**

To disable some startup processes: `sudo sed -i 's/NoDisplay=true/NoDisplay=false/g' /etc/xdg/autostart/*.desktop`

