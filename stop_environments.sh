#!/bin/bash

### Pega todos os deployments e salva em uma variável
DEPLOYMENTS=`/usr/local/bin/kubectl get deployments | grep -v vault | grep -v NAME | awk {'print $1'}`

### Faz o downscale de cada deployment no cluster
for deployment in $DEPLOYMENTS; do
  /usr/local/bin/kubectl scale deployment $deployment --replicas=0
done

# Aguarda 2 minutos até que todos os pods tenham sido parados
sleep 120

### Faz o downscale dos nodegroups
# qa-cm-eks-node-pool-1-c5-xlarge
/usr/local/bin/aws eks update-nodegroup-config --cluster-name qa-cm-eks-master --nodegroup-name qa-cm-eks-node-pool-1-c5-xlarge --scaling-config minSize=0,maxSize=1,desiredSize=0

# qa-cm-eks-node-pool-2-c5-xlarge
/usr/local/bin/aws eks update-nodegroup-config --cluster-name qa-cm-eks-master --nodegroup-name qa-cm-eks-node-pool-2-c5-xlarge --scaling-config minSize=0,maxSize=1,desiredSize=0

# qa-cm-eks-node-pool-3-c5-xlarge
/usr/local/bin/aws eks update-nodegroup-config --cluster-name qa-cm-eks-master --nodegroup-name qa-cm-eks-node-pool-3-c5-xlarge --scaling-config minSize=1,maxSize=2,desiredSize=1

# Aguarda 2 minutos até que os nodegroups tenham sido atualizados
sleep 120

### Faz o stop RDS
/usr/local/bin/aws rds stop-db-instance --db-instance-identifier sharedtestdb57
