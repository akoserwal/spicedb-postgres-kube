# Setup Spicedb with Postgres in local kind kubernetes with monitoring stack

# Run the setup
`./setup.sh`

## Configure files

* [Kubernetes-kind](./kind-kube/README.md)
* [Postgres](./postgres/README.md)
* [Spicedb](./spicedb/README.md)
* [Promethues](./promethues/)

## Tools
* kind
* zed (spicedb)
* helm
* grpcurl (only for testing spicedb grpc end-point)

## Testing grpc end-point
`grpcurl -plaintext spicedb-grpc.127.0.0.1.nip.io:80 list`
```# authzed.api.v1.ExperimentalService
# authzed.api.v1.PermissionsService
# authzed.api.v1.SchemaService
# authzed.api.v1.WatchService
# grpc.health.v1.Health
# grpc.reflection.v1alpha.ServerReflection
```

## Zed Client

zed context set kindspicedb spicedb-grpc.127.0.0.1.nip.io:80 "foobar" --insecure

```
zed schema write ./schema/schema.zed --endpoint spicedb-grpc.127.0.0.1.nip.io:80 --insecure --token "foobar"
```