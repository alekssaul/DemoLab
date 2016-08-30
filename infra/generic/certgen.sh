#!/bin/bash

MASTER_HOST=${MASTER_HOST:-192.168.1.1}
K8S_SERVICE_IP=${K8S_SERVICE_IP:-10.3.0.1}
WORKER1_IP=${WORKER2_IP:-192.168.1.11}
WORKER2_IP=${WORKER2_IP:-192.168.1.11}

openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"

cat << EOF > ./openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = ${K8S_SERVICE_IP}
IP.2 = ${MASTER_HOST}
EOF

openssl genrsa -out apiserver-key.pem 2048
openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config openssl.cnf
openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 365 -extensions v3_req -extfile openssl.cnf

cat << EOF > ./worker1-openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = ${WORKER1_IP}
EOF

cat << EOF > ./worker2-openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = ${WORKER2_IP}
EOF

openssl genrsa -out worker1-worker-key.pem 2048
openssl req -new -key worker1-worker-key.pem -out worker1-worker.csr -subj "/CN=${WORKER1_IP}" -config worker1-openssl.cnf
openssl x509 -req -in worker1-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out worker1-worker.pem -days 365 -extensions v3_req -extfile worker1-openssl.cnf

openssl genrsa -out worker2-worker-key.pem 2048
openssl req -new -key worker2-worker-key.pem -out worker2-worker.csr -subj "/CN=${WORKER1_IP}" -config worker2-openssl.cnf
openssl x509 -req -in worker2-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out worker2-worker.pem -days 365 -extensions v3_req -extfile worker2-openssl.cnf

openssl genrsa -out admin-key.pem 2048
openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=kube-admin"
openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 365
