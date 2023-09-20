#Add gtp5g module
sudo apt update
sudo apt install make gcc -y
cd /home/lax
git clone https://github.com/free5gc/gtp5g.git
cd gtp5g ; make ; sudo make install
cd /home/lax/

#Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start --memory='6g' --cpus='4'
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -o default -F __start_kubectl k" >> ~/.bashrc
source ~/.bashrc
sleep 30
git clone https://github.com/k8snetworkplumbingwg/multus-cni.git
cd multus-cni
cat ./deployments/multus-daemonset-thick.yml | kubectl apply -f -
cd /home/lax/

#Install Free5GC
helm repo add towards5gs 'https://raw.githubusercontent.com/Orange-OpenSource/towards5gs-helm/main/repo/'
helm repo update
helm search repo
mkdir kubedata
mkdir 5gc ; cd 5gc
helm pull towards5gs/free5gc ; helm pull towards5gs/ueransim
tar -zxvf free5gc*.tgz
tar -zxvf ueransim*.tgz
kubectl create ns cp
kubectl create ns up
kubectl create ns an

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-local-pv9
  labels:
    project: free5gc
spec:
  capacity:
    storage: 8Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  local:
    path: /home/lax/kubedata
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - free5gc
EOF