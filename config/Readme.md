
docker network create -d macvlan \
--subnet=192.168.1.0/24 \
--gateway=192.168.1.1 \
--ip-range=192.168.1.10/31 \
-o parent=enp1s0 \
lan
