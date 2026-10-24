# Federated Wiki Farm

Start Playing Federated Wiki: http://start.fed.wiki

### Run a local wiki farm

    docker run -p 3000:3000 -it --rm \
      ghcr.io/andrewshell/fedwikifarm

Visit http://localhost:3000 and http://anything.localhost:3000

### Run a local wiki that will survive a reboot

    docker run -p 3000:3000 -it --rm \
      -v ~/.wiki:/home/node/.wiki \
      ghcr.io/andrewshell/fedwikifarm

Your wiki pages and configuration will be saved in the ~/.wiki folder.

# Development

This image's tag does not match the version of the included wiki
software. Our version indicates the scale of changes in this tiny
devops pipeline.

`package-lock.json` pins wiki and every plugin, so the image contains
exactly what the lockfile says. `.npmrc` sets `install-strategy=shallow`
so wiki's plugins land in `node_modules/wiki/node_modules`, where wiki
looks for them.

Testing new images locally:

``` bash
IMAGE=fedwikifarm:dev
docker build --tag $IMAGE .
docker run -p 3000:3000 -it --rm $IMAGE
```

# Updating wiki and plugins

Every Monday, `.github/workflows/update-wiki.yml` regenerates
`package-lock.json` against the latest `wiki` release and refreshes
`WIKI_VERSIONS.json`. If anything changed, it opens or updates a single
pull request, `fix(deps): update wiki and plugins`. Run it on demand
from the Actions tab.

To do the same by hand:

``` bash
rm package-lock.json
npm install --save-exact wiki@latest
npx wiki --version > WIKI_VERSIONS.json
```

# Publish container images

Releases are driven by [release-please](https://github.com/googleapis/release-please)
from [Conventional Commits](https://www.conventionalcommits.org/) on
`main`. Use `fix:` for a patch, `feat:` for a minor, and `feat!:` for
a major release.

1. Merge changes to `main`. release-please opens or updates a release
   pull request that bumps the version in `package.json` and adds to
   `CHANGELOG.md`.
2. Merge the release pull request. release-please tags the commit and
   creates a GitHub release.
3. The same workflow builds the image for linux/amd64 and linux/arm64
   and pushes it to ghcr.io/andrewshell/fedwikifarm as both the new
   version and `latest`.

Watch the build at https://github.com/andrewshell/fedwikifarm/actions

Announce the new image in matrix:

    I've published a new docker image with wiki 0.40.1: ghcr.io/andrewshell/fedwikifarm:1.2.3
    https://github.com/andrewshell/fedwikifarm/pkgs/container/fedwikifarm

# Experiment with a local farm

This example shows a configuration using the friends security plugin
and making all the wikis under the localhost domain owned by the same
author. The browser will demand a login for each localhost subdomain,
but will accept the same password for authentication.

## Create ~/tmp/wiki/config.json

    {
      "admin": "any memorable password",
      "autoseed": true,
      "farm": true,
      "cookieSecret": "any random string",
      "secure_cookie": false,
      "security_type": "friends",
      "wikiDomains": {
        "localhost": {
          "id": "/home/node/.wiki/localhost.owner.json"
        }
      }
    }

## Create ~/tmp/wiki/localhost.owner.json

`.friend.secret` must match the `.admin` field from `config.json`

    {
      "name": "The Owner",
      "friend": {
        "secret": "any memorable password"
      }
    }

## Run a local wiki that will use those config files and survive a reboot

    docker run -p 3000:3000 -it --rm \
      -v ~/tmp/wiki:/home/node/.wiki \
      ghcr.io/andrewshell/fedwikifarm

## Visit a couple local wiki sites

http://foo.localhost:3000
http://bar.localhost:3000

You should be able to log into both of those local sites using
'any memorable password'. And if you create a few pages in each
wiki you can examine how the files are laid out in the `~/tmp/wiki`
folder where you have stored those config files.

# Experiment with K8S

With the local kubernetes example (see [examples/k8s/README.md](./examples/k8s/README.md)):

``` bash
k3d image import $IMAGE --cluster wiki
kubectl patch deployment.apps/wiki-deployment \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"'$IMAGE'"}]'
```
