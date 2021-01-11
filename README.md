# GitHub Action: Update major/minor semver

[![Docker Image CI](https://github.com/rickstaa/action-update-semver/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/rickstaa/action-update-semver/actions)
[![Code quality CI](https://github.com/rickstaa/action-update-semver/workflows/Code%20quality%20CI/badge.svg)](https://github.com/rickstaa/action-update-semver/actions?query=workflow%3A%22Code+quality+CI%22)
[![release](https://github.com/rickstaa/action-update-semver/workflows/release/badge.svg)](https://github.com/rickstaa/action-update-semver/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/rickstaa/action-update-semver?logo=github&sort=semver)](https://github.com/rickstaa/action-update-semver/releases)

This action updates major/minor release tags on a tag push. e.g. Update `v1` and `v1.2` tag when
released `v1.2.3`. It can also be used to move the patch version up to the latest commit.

It works well for GitHub Action. ref: <https://help.github.com/en/articles/about-actions#versioning-your-action>

## Inputs

### `tag`

**Optional**. Existing tag to update from. Default comes from `$GITHUB_REF`.

### `message`

**Optional**. Tag message. Default: `Release $TAG`

### `major_version_tag_only`

**Optional**. Create only major version tags. Default: `false`

### `move_patch_tag`

**Optional**. Moves the existing tag to the latest commit inside the github action. Default: `false`. Useful when you want to use [auto-changelog](https://www.npmjs.com/package/auto-changelog) to automatically add a changelog to your release.

| ⚠️  | In order to prevent unexpected changes this only works when you explicitly specified a tag. |
| --- | ------------------------------------------------------------------------------------------- |

### `github_token`

**Optional**. It's no need to specify it if you use checkout@v2. Required for
checkout@v1 action.

## Example usage

### [.github/workflows/update_semver.yml](.github/workflows/update_semver.yml)

```yml
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
      - uses: actions/checkout@v2
      - uses: rickstaa/action-update-semver@v1
        with:
          major_version_tag_only: true  # (optional, default is "false")
```

<details>

<summary>oneliner</summary>

    $ cat <<EOF > .github/workflows/update_semver.yml
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
          - uses: actions/checkout@v2
          - uses: rickstaa/action-update-semver@v1
            with:
              github_token: \${{ secrets.github_token }}
    EOF

</details>

## Acknowledgement

This action is based on [@haya14busa's](https://github.com/haya14busa/) [update-major-minor-semver](https://github.com/marketplace/actions/update-major-minor-semver).
