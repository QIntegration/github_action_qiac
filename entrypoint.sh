#!/bin/sh -l

SCANFOLDER=$1

echo "Action triggered by $GITHUB_EVENT_NAME event"

if [ $GITHUB_EVENT_NAME = "push" ] || [ $GITHUB_EVENT_NAME = "pull_request" ]
then
    if [ $(git diff --name-only --diff-filter=ACMRT HEAD^ HEAD | wc -l) -eq "0" ]; then 
        echo "There are no files/folders to scan."
        exit 0
    else
        echo "From the below files, Only the files with extensions supported by IaC module are included in the scan."
        git diff --name-only --diff-filter=ACMRT HEAD^ HEAD
        foldername="qiacscanfolder_$(date +%Y%m%d%H%M%S)"
        mkdir $foldername
        cp --parents $(git diff --name-only --diff-filter=ACMRT HEAD^ HEAD) $foldername
        cd $foldername
        SCANFOLDER="."
    fi
else
    if [ "$SCANFOLDER" = "." ]
    then 
        echo "Scanning entire repository."
    else
        echo "Scan Directory Path is - $SCANFOLDER"
    fi
fi

 #Calling Iac CLI
 echo "Scanning Started at - $(date +"%Y-%m-%d %H:%M:%S")"
 qiac scan -a $URL -u $UNAME -p $PASS -d $SCANFOLDER -m json -n GitHubActionScan --branch $GITHUB_REF --gitrepo $GITHUB_REPOSITORY > /result.json
 cat result.json
 if [ $? -ne 0 ]; then
    exit 1
 fi
 echo "Scanning Completed at - $(date +"%Y-%m-%d %H:%M:%S")"
 #process result for annotation
 echo " "
 echo "SCAN RESULT"
 cd /
 #cat result.json
 python resultParser.py result.json











