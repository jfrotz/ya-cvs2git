#!/bin/bash
#----------------------------------------------------------------------
# USAGE:
#   sh migrate.sh $CVSMODULENAME
#
# DESCRIPTION:
#   This script will copy the CVS files from your CVS server to a scratch directory, 
#   then run cvs2svn to prepare the migration to git.
#
# CONSIDERATIONS:
#   Our migration decided to migrate CVS module structure to GitLab Group / Subgroup / Repo structure
#   so that our engineers would be able to know where things migrated to as this was a multi-week / multi-month
#   migration process (low-priority, keep-alive-priority).
#
#   This also allowed us to uplevel our git-fu in small pockets and migrate our collective skillsets as
#   each CVS module ("build") was migrated.
#
# HISTORICAL CONTEXT:
#   Our CVS structure started life as an install-tree repository semantics.  (Checkout / checkin in place.)
#   Ten years ago, we began shifting to build-tree repository semantics.  (Build / install to deploy.)
#   We were unable to get away from our install-tree habit, so we cheated and created symlinks under our
#   CVS repository to allow us to work in either view (install-tree or build-tree).
#
#   With our migration to git, we are dropping our install-tree semantics (because git won't support that and
#   it is long past time for us to stop doing bad things because we can).
#
# MIGRATION PROBLEMS:
#    Windows users have a bad penchant for including non-ascii strings into check-in comments.
#    Historically we have deleted CVS files and then recreated them.
#
# PREREQUISITES:
#    https://rpmfind.net/linux/rpm2html/search.php?query=cvs2svn -- cvs2git
#

export CVSSERVER=yourcvs.example.org
export CVSROOT=/usr/local/cvsroot
export CVSMODULE=$1
export CVSARCHIVE=/CVSROOT/cvs.archive
export GITSERVER

set -x -v
cd ~/migrate || mkdir ~/migrate && cd ~/migrate

rm -rf cvs2git-tmp && mkdir -p cvs2git-tmp/$CVSMODULE
rm -rf git-repo && mkdir git-repo

# DO NOT copy the path ($1) into cvs2git-tmp/                                                                                                    

ssh $CVSSERVER "ls -lR $CVSROOT/$CVSMODULE"
scp -r $CVSSERVER:$CVSROOT/$CVSMODULE/. cvs2git-tmp/      ## Make sure we pick up . files in the recursive copy
mkdir -p cvs2git-tmp/CVSROOT

cvs2git -v --blobfile=cvs2git-tmp/git-blob.dat --dumpfile=cvs2git-tmp/git-dump.dat --tmpdir=cvs2git-tmp --username=cvs2git ./cvs2git-tmp

mkdir git-repo
cd git-repo

git init

cat ../cvs2git-tmp/git-blob.dat ../cvs2git-tmp/git-dump.dat | git fast-import

pwd
git checkout
git status

git remote add origin git@$GITSERVER:$CVSMODULE.git
git push -v --set-upstream origin master
git push -v -u origin --all
git push -v -u origin --tags
if [ $? != 0 ]; then
    echo "Migration failed.  Check for common faults."
else
    ssh $CVSSERVER "perl cvsoffline.pl $CVSROOT $CVSMODULE $ARCHIVE"
fi
