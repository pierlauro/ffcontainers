
## Due to the recent [Firefox 66 update](https://www.ghacks.net/2019/03/19/firefox-66-0-release-information/) moving json storage to IndexedDB, the plugin is currently unstable. Please, refer to [this issue](https://github.com/pierlauro/ffcontainers/issues/3) to check the current state of development.

------------

# Export/Import Firefox Multi-Account Containers

This bash script allows to synchronize [Firefox Multi-Account Containers](https://addons.mozilla.org/es/firefox/addon/multi-account-containers/) among different machines.

It provides two ways of performing synchronization:
- Network-based: uses [Firefox Send](https://send.firefox.com)
- No-Network: produces an archive to manually move between machines

# Usage

### Using Firefox Send
The link produced when exported the containers will be accessible for 24 hours.

#### Export containers

```
$ ./ffcontainers fsexport
Containers successfully exported in:	 http://send.firefox.com/randomString
```

#### Import containers

```
$ ./ffcontainers fsimport http://send.firefox.com/randomString
Containers successfully imported
```


### Using files
#### Export containers

```
$ ./ffcontainers export
Containers successfully exported in:	 ffcontainers-PROFILE-20190210.zip
```

#### Import containers

```
$ ./ffcontainers import ffcontainers-PROFILE-20190210.zip
Containers successfully imported
```

## Dependencies
- [zip](www.info-zip.org)
- [jq](https://stedolan.github.io/jq/) - needed just in case of multiple profiles in Mozilla Firefox
- [ffsend](https://github.com/timvisee/ffsend) - needed just in case you want to export/import by using [Firefox Send](https://send.firefox.com/)

## Supported features
- Standard Mozilla Firefox installation path
- Multi-profile installations ([including more versions of Firefox on the same machine](https://github.com/pierlauro/ffcontainers/issues/1))

## TODO
- Custom Mozilla Firefox installation paths
- Automatic check extension's version
- Incremental update of containers
