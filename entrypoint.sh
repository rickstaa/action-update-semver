#!/bin/sh
set -eu

cd "${GITHUB_WORKSPACE}" || exit

# Apply hotfix for 'fatal: unsafe repository' error (see #13).
git config --global --add safe.directory "${GITHUB_WORKSPACE}"

# Set up variables.
TAG="${INPUT_TAG:-${GITHUB_REF#refs/tags/}}" # v1.2.3
MINOR="${TAG%.*}"                            # v1.2
MAJOR="${MINOR%.*}"                          # v1
MAJOR_VERSION_TAG_ONLY=${INPUT_MAJOR_VERSION_TAG_ONLY:-}
MOVE_PATCH_TAG=${INPUT_MOVE_PATCH_TAG:-}
GPG_PRIVATE_KEY="${INPUT_GPG_PRIVATE_KEY:-}"
GPG_PASSPHRASE="${INPUT_GPG_PASSPHRASE:-}"
MESSAGE="${INPUT_MESSAGE:-Release ${TAG}}"

# Check if the workflow is triggered by a tag push.
if [ "${GITHUB_REF}" = "${TAG}" ]; then
  echo "[action-update-semver] [ERROR] This workflow is not triggered by tag push: GITHUB_REF=${GITHUB_REF}."
  exit 1
fi

# Configure git and gpg if GPG key is provided.
if [ -n "${GPG_PRIVATE_KEY}" ]; then
  # Import the GPG key.
  echo "[action-update-semver] Importing GPG key."
  echo "${GPG_PRIVATE_KEY}" | gpg --batch --yes --import

  # If GPG_PASSPHRASE is set, unlock the key.
  if [ -n "${GPG_PASSPHRASE}" ]; then
    echo "[action-update-semver] Unlocking GPG key."
    echo "${GPG_PASSPHRASE}" | gpg --batch --yes --pinentry-mode loopback --passphrase-fd 0 --output /dev/null --sign
  fi

  # Retrieve GPG key information.
  public_key_id=$(gpg --list-secret-keys --keyid-format=long | grep sec | awk '{print $2}' | cut -d'/' -f2)
  signing_key_email=$(gpg --list-keys --keyid-format=long "${public_key_id}" | grep uid | sed 's/.*<\(.*\)>.*/\1/')
  signing_key_username=$(gpg --list-keys --keyid-format=long "${public_key_id}" | grep uid | sed 's/uid\s*\[\s*.*\]\s*//; s/\s*(.*//')

  # Setup git user name, email, and signingkey.
  echo "[action-update-semver] Setup git user name, email, and signingkey."
  git config --global user.name "${signing_key_username}"
  git config --global user.email "${signing_key_email}"
  git config --global user.signingkey "${public_key_id}"
  git config --global commit.gpgsign true
  git config --global tag.gpgSign true
else
  # Setup git user name and email.
  echo "[action-update-semver] Setup git user name and email."
  git config --global user.name "${GITHUB_ACTOR}"
  git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
fi

# Update MAJOR/MINOR tag.
[ "${MAJOR_VERSION_TAG_ONLY}" = 'true' ] && echo_str="major version tag" || echo_str="major/minor version tags"
echo "[action-update-semver] Create ${echo_str}."
git tag -fa "${MAJOR}" -m "${MESSAGE}"
[ "${MAJOR_VERSION_TAG_ONLY}" = 'true' ] || git tag -fa "${MINOR}" -m "${MESSAGE}"
if [ -n "${INPUT_TAG}" ] && [ "${MOVE_PATCH_TAG}" = 'true' ]; then
  echo "[action-update-semver] Moves ${TAG} to the latest commit."
  git tag -fa "${TAG}" -m "${MESSAGE}"
fi

# Set up remote URL for checkout@v1 action.
if [ -n "${INPUT_GITHUB_TOKEN}" ]; then
  git remote set-url origin "https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
fi

echo "[action-update-semver] Force push tags."
[ "${MAJOR_VERSION_TAG_ONLY}" = "true" ] || git push --force origin "${MINOR}"
if [ -n "${INPUT_TAG}" ] && [ "${MOVE_PATCH_TAG}" = "true" ]; then
  git push --force origin "${TAG}"
fi
git push --force origin "${MAJOR}"
