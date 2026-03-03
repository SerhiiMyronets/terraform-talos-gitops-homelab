apt update && apt install linux-cpupower

/etc/systemd/system/cpu-powersave.service

systemctl daemon-reload
systemctl enable cpu-powersave.service