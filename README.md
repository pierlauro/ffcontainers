# Export/Import Firefox Multi-Account Containers

This bash script allows to synchronize Firefox containers among different machines.

Note: the script is currently working just with the updated version of [Firefox Multi-Account Containers](https://addons.mozilla.org/es/firefox/addon/multi-account-containers/)

# Usage
### Export containers

```
$ ./ffcontainers export
Containers successfully exported in:	 ffcontainers-PROFILE-20190210.zip
```

### Import containers

```
$ ./ffcontainers import ffcontainers-PROFILE-20190210.zip
Containers successfully imported
```

## Dependencies
- [zip](www.info-zip.org)
- [jq](https://stedolan.github.io/jq/) - needed just in case of multiple profiles in Mozilla Firefox

## Supported
- Standard Mozilla Firefox installation path
- Multi-profile installations

## TODO
- Custom Mozilla Firefox installation paths
- Automatic check extension's version
- Incremental update of containers
