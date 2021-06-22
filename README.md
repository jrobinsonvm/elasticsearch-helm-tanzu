Setup Elasticsearch via Helm Chart using Project Contour ingress 

# Provision TKG Cluster  

# Login to TKG Cluster 

# Create cluster role binding to allow workload deployments 

kubectl create clusterrolebinding psp:authenticated --clusterrole=psp:vmware-system-privileged --group=system:authenticated


# Deploy Project Contour: 
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

# Setup DNS to point to Project Contour's Envoy Service IP Address 
# Setup A Record which points to the IP Address 
# Make the A Record a wild card DNS 
# Example: *.elasticsearch.mydomain.com ---> IP Address  

# Fetch the Elasticsearch Helm Chart to make changes 
# https://github.com/elastic/helm-charts/tree/master/elasticsearch

helm fetch elastic/elasticsearch --untar

# Change Directories to Elasticsearch 
cd elasticsearch

# 
# Open and edit the values.yaml file 
# After line 92 add the following line.  

   ```storageClassName: pacific-gold-storage-policy```
# 
# Example: 
# volumeClaimTemplate:
#   accessModes: [ "ReadWriteOnce" ]
#   storageClassName: pacific-gold-storage-policy
#   resources:
#     requests:
#       storage: 30Gi
 

# Now navigate to the ingress class on line 235 
# Change Ingress enabled to "true"

# Uncomment the ingress.class annotation below and change nginx to contour 

# Modify the Host variable to match your desired FQDN and the DNS entry which was setup earlier. 

# Match the following example below to include your backend service name and port.  
# Example: 
# ingress:
#   enabled: true
#   annotations: {
#     kubernetes.io/ingress.class: contour } 
#     # kubernetes.io/tls-acme: "true" 
#   hosts:
#     - host: dev.es.haas-401.pez.vmware.com 
#       paths:
#       - backend: 
#           serviceName: elasticsearch-master
#           servicePort: 9200
#         path: /
#   tls: []
#   #  - secretName: chart-example-tls
#   #    hosts:
#   #      - chart-example.local



# Now save and Close the file 
# Make a copy of the values.yaml file and call it master-values.yaml

# Create Namespace for Elasticsearch 
kubectl create ns elk 

# Deploy Elasticsearch to test basic setup functionality 

helm install elk . -n elk  -f master-values.yaml

# Your Elasticsearch Master nodes should now appear.   
# Example: 
# jamesro@jamesro-a01 elasticsearch % kubectl get pods --namespace=elk -l app=elasticsearch-master -w
# NAME                     READY   STATUS    RESTARTS   AGE
# elasticsearch-master-0   1/1     Running   0          8m38s


# Create Cert 

openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365




# helm install elk . -n elk  --set global.storageClass=pacific-gold-storage-policy
