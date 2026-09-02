#!/bin/sh
# Wrapper script for docker.
#
# This is used primarily for wrapping the GNU Make workflow.
# Instead of typing "make TARGET", type "./run.sh make TARGET".
# This will run the make workflow within a docker container.
#
# The assumption is that you are working in the src/ontology folder;
# we therefore map the whole repo (../..) to a docker volume.
#
# See README-editors.md for more details.

# Pin to the same ODK image the CI workflow uses (.github/workflows/build.yaml).
# Override with e.g. ODK_TAG=v1.2.31 sh odk.sh make all
ODK_TAG=${ODK_TAG:-v1.2.30}

docker run -e ROBOT_JAVA_ARGS='-Xmx6G' -e JAVA_OPTS='-Xmx6G' -v $PWD/:/work -w /work --rm -ti obolibrary/odklite:$ODK_TAG "$@"
