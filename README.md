# Complete Free5GC demo on Azure using Terraform

This repo provide all necessary file to deploy my azure cluster and free5gc for demo purpose.

```
cd /home/lax/5gc/free5gc/charts
helm install userplane -n up \
--set global.n4network.masterIf=eth0 \
--set global.n3network.masterIf=eth0 \
--set global.n6network.masterIf=eth0 \
--set global.n6network.subnetIP="192.168.49.0" \
--set global.n6network.gatewayIP="192.168.49.1" \
--set upf.n6if.ipAddress="192.168.49.100" \
free5gc-upf
```
```
cd /home/lax/5gc/
helm install controlplane -n cp \
--set deployUpf=false \
--set global.n2network.masterIf=eth0 \
--set global.n3network.masterIf=eth0 \
--set global.n4network.masterIf=eth0 \
--set global.n6network.masterIf=eth0 \
--set global.n9network.masterIf=eth0 \
free5gc
```

```
Login to WebUI
kubectl port-forward --address 0.0.0.0 service/webui-service -n cp 30500:5000
```

```
cd /home/lax/5gc/
helm install an -n an \
--set global.n2network.masterIf=eth0 \
--set global.n3network.masterIf=eth0 \
ueransim
```

https://learn.microsoft.com/en-us/answers/questions/1321052/icmp-traffic-passing-through-nat-gateway

UE Testing
```
curl --interface uesimtun0 -Is http://www.google.com | head -n 1
curl --interface uesimtun0 https://ipinfo.io/ip
```