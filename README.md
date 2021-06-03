scap3 deployment configuration for MjoLniR data pipeline

Wheel upload requires setting up maven with archiva configuration.
See https://wikitech.wikimedia.org/wiki/Archiva for instructions.


Process for updating build:

* Update src/ submodule to point to correct version of mjolnir
* Remove all artifacts via `git rm artifacts/*
* Run `make_wheels.py`. This will install mjolnir from src/ into
  a virtualenv and then build wheels for all packages installed.
** `make_wheels.py` needs to be run once with each python version to be
  deployed to, such as 3.5.3 for stretch and 3.4.2 for jessie. Specify a
  PYTHON_PATH variable to override.
* Run `upload_wheels.py artifacts/*.whl` to upload. This will sync
  the wheels to archiva. If a wheel already exists in archiva for
  the same version but a different sha1 your local version will be
  replaced.
* Run `git add artifacts/*.whl`
* Commit and submit to gerrit
