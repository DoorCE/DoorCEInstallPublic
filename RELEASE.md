# Procedure for issuing a new release of the system

- [ ] Go to the DoorCEInstall repository
- [ ] Go to `src/units` and update the `input.tf` files for each of the modified modules.
- [ ] Go to `templates/github-repo/.github/workflows` and update version numbers in the contained `*.yaml` files.
- [ ] Commit the above file changes to GitHub with an `Update to vX.Y.Z` message.
- [ ] Create a new release in GithHub.

## Updating the `input.tf` files

- Go to the `scr/units` folder.
- Iterate over every `docker.container.*` folder for the modules that have their version changed.
- In each such folder, go to `module/inputs.tf` file.
- Modify the `image_version` section - the `default` parameter - set it to the new docker image tag.
- If necessary, modify also the `image_name` section - the `default` parameter - set it to the new docker image name, as available in dockerhub.

## Updating the `*.yaml` files

- Go to the `templates/github-repo/.github/workflows` folder.
- Go to each of the three `*.yaml` files.
- In each file modify the version number (e.g. from v1.1.3 to v1.1.4) in two lines - in the `uses:` and in the `with: branch` sections.

## Creating a new release in GitHub

- In GitHub select `Releases` on the `Code` page of the DoorCEInstall repository
- Select `Draft a new release` button
- Select the `Select tag` field and then select `Create new tag` and add a tag in the format like `v1.1.4`
- Select `Generate release notes` or add release notes manually
- Select `Publish release`
- Go to the [DoorCEInstall-workflows repository](https://github.com/DoorCE/DoorCEInstall-workflows)
- Repeat from selecting the `Release` option as above