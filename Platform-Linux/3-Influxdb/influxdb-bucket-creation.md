#Influxdb creating databases buckets
- [Inside/from you local machine](#insidefrom-you-local-machine)
- [Inside the Kubernetes pods](#inside-the-kubernetes-pods)


 This guide will demonstrate the process of creating & accessing buckets in Influxdb2.0


# Inside/from you local machine
1. Port Forward the container from your local machine
```sh
kubectl port-forward svc/influxdb 8086:8086 -n influxdb

```

2. This command will setup the influxdb cli on your local machine
```sh
influx -host localhost -port 8086 -username <admin-username> -password '<admin-password>'
```

3. Create the bucket within the influxdb cli
```sh

influx bucket create \
  -n <bucket-name> \
  -o <organization> \
  -r <retention-period>

```


# Inside the Kubernetes pods

1. Open a shell into the k8 pod
```sh
kubectl exec -it <influxdb-pod-name> -n influxdb -- /bin/sh
```
2. Start & run the cli from within the pod
```sh
influx -username <admin-username> -password '<admin-password>'
```

3.  Create bucket
```sh
influx bucket create -n my_bucket -o my_org -r 7d

```