# Procedure for upgrading to a new release of the system

- Go to your DoorCE deployment repository (the one created during installation).
- Go to the `.github/workflows` folder.
- Go to each of the three `*.yaml` files.
- In each file modify the version number (e.g. from v1.1.3 to v1.1.4) in two lines - in the `uses:` and in the `with: branch` sections.
- Navigate to the `Actions` section
- Run the `DoorCE Setup` workflow (selecting `apply` and clicking `Run workflow`).