# Setup Elasticsearch and Kibana via Helm Chart using Project Contour ingress 

* Provision TKG Cluster  

* Login to TKG Cluster 

## Elasticsearch Setup 

1. Create cluster role binding to allow workload deployments 
```
kubectl create clusterrolebinding psp:authenticated --clusterrole=psp:vmware-system-privileged --group=system:authenticated
```


2. Deploy Project Contour: 
```
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
```

3. Setup DNS to point to Project Contour's Envoy Service IP Address 
``` Setup A Record which points to the IP Address 
    Make the A Record a wild card DNS 
    Example: *.elasticsearch.mydomain.com ---> IP Address 
```

4.  Now Fetch the Elasticsearch Helm Chart to make changes 
* https://github.com/elastic/helm-charts/tree/master/elasticsearch


The example below will pull version 7.11.1 
```
helm fetch elastic/elasticsearch  --version 7.11.1 --untar
```

5.  Change Directories to Elasticsearch 
```
cd elasticsearch
```

6.  Open and edit the values.yaml file to include the storageClassName
   
    After line 92 add the following line.  
   ```
   storageClassName: pacific-gold-storage-policy
   ```
 
### Example: 
```
 volumeClaimTemplate:
   accessModes: [ "ReadWriteOnce" ]
   storageClassName: pacific-gold-storage-policy
   resources:
     requests:
       storage: 30Gi
```

7.  Now enable your ingress (if desired)
   
   * Change Ingress enabled to "true"

   * Uncomment the ingress.class annotation below and change nginx to contour 

   * Modify the Host variable to match your desired FQDN and the DNS entry which was setup earlier. 

 Match the following example below to include your backend service name and port.  

 ### Example: 
 ```
 ingress:
   enabled: true
   annotations: {
     kubernetes.io/ingress.class: contour } 
   hosts:
     - host: dev.es.haas-401.pez.vmware.com 
       paths:
       - backend: 
           serviceName: elasticsearch-ingest
           servicePort: 9200
         path: /
```
8. Now save, close and make duplicates of this values.yaml file for your various elasticsearch roles
   (ie. Master, Data, ML, Coordinating-Only)
   Make a copy of the values.yaml file and call it master-values.yaml for the master node roles.   

9. Create Namespace for Elasticsearch 
```
kubectl create ns elk 
```

10. Deploy Elasticsearch to test basic setup functionality 

``` 
helm install elk . -n elk  -f master-values.yaml 
```

Your Elasticsearch Master nodes should now appear.   
### Example: 

```
 jamesro@jamesro-a01 elasticsearch % kubectl get pods --namespace=elk -l app=elasticsearch-master -w
 NAME                     READY   STATUS    RESTARTS   AGE
 elasticsearch-master-0   1/1     Running   0          8m38s
```

## Kibana Setup 


1.  Now Fetch the Kibana Helm Chart to make changes 
* https://github.com/elastic/helm-charts/tree/master/kibana

The example below will pull version 7.11.1 
```
helm fetch elastic/kibana --version 7.11.1  --untar
```

2.  Change Directories to kibana 
```
cd kibana
```

3.  Edit the values.yaml file to point to your elasticsearch hosts 

```
elasticsearchHosts: "http://<IP-Address-OR-FQDN>:9200"   #changeme
```


