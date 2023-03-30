# mjolnir-deploy

scap3 deployment configuration for MjoLniR data pipeline

Fetches and unpacks deployment artifact from gitlab into the deployed
directory.

## Updating the environment
Process for updating build:

* [optional] release the [mjolnir](https://gitlab.wikimedia.org/repos/search-platform/mjolnir)
 package following the instructions in the repos README.md.
* Update `conda_venv.url` with the desired package from the
 [package repository](https://gitlab.wikimedia.org/repos/search-platform/mjolnir/-/packages)
* Send patch to gerrit for code review and merge.

## Deployment

Follows standard scap deployment:
* SSH into the deployment server
* Pull the latest version of this repo to `/srv/deployment/search/mjolnir/deploy`
* Run `scap deploy '<some deploy reason>'`
* Restart the mjolnir daemons on search-loader instances.
