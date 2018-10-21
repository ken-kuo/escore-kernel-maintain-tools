#!/bin/bash

PATCH_FILE=update.patch
CENTOS_DIR=../kernel
DIFF_FILES=".gitignore SOURCES/ SPECS/"
CURR_VER=$(git branch | grep kernel-3.10.0 | sort -Vr | head -n 1)

GIT_CENTOS="git -C $CENTOS_DIR"

CURR_TAG=$($GIT_CENTOS tag -l | grep $CURR_VER)
UPDATE_TAG=$($GIT_CENTOS tag -l | sort -Vr| grep -B1 $CURR_TAG |
			 grep -v $CURR_TAG)

if [[ "$UPDATE_TAG" == "" ]];then
	echo "$CURR_TAG is uptodate"
	exit 0
fi

UPDATE_VER=$(echo ${UPDATE_TAG} | grep -o kernel.*$)

$GIT_CENTOS diff ${CURR_TAG}..${UPDATE_TAG} -- ${DIFF_FILES} \
	> $PATCH_FILE
git apply $PATCH_FILE
git add ${DIFF_FILES}
git commit -m "Apply Red Hat ${UPDATE_VER} changes"
git branch ${UPDATE_VER}
rm -f $PATCH_FILE
