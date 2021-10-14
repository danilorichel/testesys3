#!/bin/bash

### Pega todos os deployments e salva em uma variável
DEPLOYMENTS=`/usr/local/bin/kubectl get deployments | grep -v vault | grep -v NAME | awk {'print $1'}`

### Sobe o RDS
/usr/local/bin/aws rds start-db-instance --db-instance-identifier sharedtestdb57

### Faz o scale dos nodegroups
# qa-cm-eks-node-pool-1-c5-xlarge
/usr/local/bin/aws eks update-nodegroup-config --cluster-name qa-cm-eks-master --nodegroup-name qa-cm-eks-node-pool-1-c5-xlarge --scaling-config minSize=3,maxSize=4,desiredSize=3

# qa-cm-eks-node-pool-2-c5-xlarge
/usr/local/bin/aws eks update-nodegroup-config --cluster-name qa-cm-eks-master --nodegroup-name qa-cm-eks-node-pool-2-c5-xlarge --scaling-config minSize=3,maxSize=4,desiredSize=3

# qa-cm-eks-node-pool-3-c5-xlarge
/usr/local/bin/aws eks update-nodegroup-config --cluster-name qa-cm-eks-master --nodegroup-name qa-cm-eks-node-pool-3-c5-xlarge --scaling-config minSize=3,maxSize=4,desiredSize=3

### Aguarda até que o banco suba e todos os nodes estejam no ar
sleep 300

### Faz o scale de cada deployment no cluster
for deployment in $DEPLOYMENTS; do
  /usr/local/bin/kubectl scale deployment $deployment --replicas=1
done
