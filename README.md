# Docker Bitcoin with OP_CAT

Dockerfile of the public image [ghcr.io/vulpemventures/bitcoin-cat:latest](https://github.com/orgs/vulpemventures/packages/container/package/bitcoin-cat)


Pull the image:

```bash
$ docker pull ghcr.io/vulpemventures/bitcoin-cat:latest
```

Run the image:

```bash
$ docker run -v path/to/bitcoin.conf:/home/bitcoin/.bitcoin -d ghcr.io/vulpemventures/bitcoin-cat:latest
```


## Release

To tag a new image with a new version, change the branch in Dockerfile and push it to the repository.

