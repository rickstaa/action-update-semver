# GitHub Action: Update major/minor semver

[![Docker Image CI](https://github.com/rickstaa/action-update-semver/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/rickstaa/action-update-semver/actions)
[![Code quality CI](https://github.com/rickstaa/action-update-semver/workflows/Code%20quality%20CI/badge.svg)](https://github.com/rickstaa/action-update-semver/actions?query=workflow%3A%22Code+quality+CI%22)
[![Release](https://github.com/rickstaa/action-update-semver/workflows/release/badge.svg)](https://github.com/rickstaa/action-update-semver/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/rickstaa/action-update-semver?logo=github&sort=semver)](https://github.com/rickstaa/action-update-semver/releases)

This GitHub Action simplifies the process of updating major/minor release tags on a tag push. For example, it automatically updates both `v1` and `v1.2` tags when releasing version `v1.2.3`. Additionally, it provides the option to move the patch version up to the latest commit, making it convenient for use with tools like [auto-changelog](https://www.npmjs.com/package/auto-changelog) to automatically generate changelogs for your releases.

It's designed to seamlessly integrate with GitHub Actions. For more details on versioning your action, refer to [GitHub Actions documentation](https://help.github.com/en/articles/about-actions#versioning-your-action).

## Inputs

### `tag`

**Optional**. Specifies the existing tag to update from. Defaults to `$GITHUB_REF`.

### `message`

**Optional**. Custom tag message. Default: `Release $TAG`.

### `major_version_tag_only`

**Optional**. Creates only major version tags. Default: `false`.

### `move_patch_tag`

**Optional**. Moves the existing tag to the latest commit inside the GitHub Action. Default: `false`. Note that this only works when you explicitly specify a tag to prevent unexpected changes.

### `github_token`

**Optional**. Only required for checkout@v1 action; otherwise, it's not necessary if you use checkout@v2 or higher.

### `gpg_private_key`

**Optional**. Specifies the GPG private key to sign the tag with. Default: `""`.

### `gpg_passphrase`

**Optional**. Specifies the GPG passphrase to sign the tag with. Default: `""`.

## Example Usage

### Simple example

```yaml
name: Update Semver
on:
  push:
    branches-ignore:
      - '**'
    tags:
      - 'v*.*.*'
jobs:
  update-semver:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: rickstaa/action-update-semver@v1
        with:
          major_version_tag_only: true  # (optional, default is "false")
```

Certainly! Here's a refined version of your documentation:

### Signing Tags with GPG

To sign tags with GPG, follow these steps:

#### 1. Generate a GPG Key

First, [generate a GPG key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key). Once generated, export the GPG private key in ASCII armored format to your clipboard using one of the following commands based on your operating system:

- **macOS:**
  ```shell
  gpg --armor --export-secret-key joe@foo.bar | pbcopy
  ```

- **Ubuntu (GNU base64):**
  ```shell
  gpg --armor --export-secret-key joe@foo.bar -w0 | xclip
  ```

- **Arch:**
  ```shell
  gpg --armor --export-secret-key joe@foo.bar | xclip -selection clipboard -i
  ```

- **FreeBSD (BSD base64):**
  ```shell
  gpg --armor --export-s[.github/workflows/update_semver.yml](.github/workflows/update_semver.yml)e your GPG passphrase.

#### 3. Update Workflow YAML

Modify your workflow YAML file to include the GPG private key and passphrase in the `gpg_private_key` and `gpg_passphrase` inputs:

```yaml
name: Update Semver
on:
  push:
    branches-ignore:
      - '**'
    tags:
      - 'v*.*.*'
jobs:
  update-semver:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: rickstaa/action-update-semver@v1
        with:
          gpg_private_key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg_passphrase: ${{ secrets.PASSPHRASE }}
          major_version_tag_only: true  # (optional, default is "false")
```

This workflow will now sign tags using the specified GPG key during tag creation.

## Contributing

Feel free to open an issue if you have ideas on how to improve this GitHub Action or if you want to report a bug! All contributions are welcome. :rocket: Please consult the [contribution guidelines](CONTRIBUTING.md) for more information.

## Acknowledgment

This action is based on [@haya14busa's](https://github.com/haya14busa/) [update-major-minor-semver](https://github.com/marketplace/actions/update-major-minor-semver).
