#!/bin/sh -l

SCANFOLDER=$1
SOURCE_UUID="8c0ac08e-60ad-4a8a-9571-a2c56514b61a"
SCANID_STR="Scan launched successfully. Scan ID: "

echo "Action triggered by $GITHUB_EVENT_NAME event"
echo "GITHUB_HEAD_REF = $GITHUB_HEAD_REF"
echo "GITHUB_REF_NAME= $GITHUB_REF_NAME"
echo "ls "
ls

changed_files=""
while read oldrev newrev refname; do
echo"inside while.."
  if [ "$refname" = "refs/heads/$GITHUB_REF_NAME" ]; then
    echo "inside if.."
    changed_files=$(git diff-tree --name-only -r $oldrev $newrev)
  fi
done
echo "changed_files= $changed_files"
while read -r oldrev newrev refname
do
  echo "Branch: $refname"
  echo "Previous commit: $oldrev"
  echo "New commit: $newrev"
  if [ "$refname" = "refs/heads/master" ]
  then
    changed_files=$(git diff-tree --name-only -r "$oldrev" "$newrev")
  fi
done
echo "changed_files= $changed_files"


if [ $GITHUB_EVENT_NAME = "push" ] || [ $GITHUB_EVENT_NAME = "pull_request" ]
then
    if [ $(git diff --name-only --diff-filter=ACMRT HEAD~1 HEAD | wc -l) -eq "0" ]; then 
        echo "There are no files/folders to scan."
        echo "{\"version\": \"2.1.0\",\"runs\": [{\"tool\": {\"driver\": {\"name\": \"QualysIaCSecurity\",\"organization\": \"Qualys\"}},\"results\": []}]}" > response.sarif
        exit 0
    else
        echo "From the below files, Only the files with extensions supported by IaC module are included in the scan."
        git diff --name-only --diff-filter=ACMRT HEAD~1 HEAD
        foldername="qiacscanfolder_$(date +%Y%m%d%H%M%S)"
        mkdir $foldername
        cp --parents $(git diff --name-only --diff-filter=ACMRT HEAD~1 HEAD) $foldername
        SCANFOLDER=$foldername
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
 qiac scan -a $URL -u $UNAME -p $PASS -d $SCANFOLDER -m json -n GitHubActionScan --branch $GITHUB_REF --gitrepo $GITHUB_REPOSITORY --source $SOURCE_UUID > /result.json
 if [ $? -ne 0 ]; then
    exit 1
 fi

 LEN=${#SCANID_STR}
 let "LEN+=1"
 SCAN_ID="$(grep "$SCANID_STR" /result.json  | cut -c $LEN-)"
 
 if [[ ! -z "$SCAN_ID" ]]
 then
    echo "Scan ID:" $SCAN_ID
    qiac getresult -a $URL -u $UNAME -p $PASS -i $SCAN_ID -m SARIF -s > /raw_result.sarif
 fi
 
 if [ -f scan_response_*.sarif ]; then
     mv scan_response_*.sarif response.sarif
     chmod 755 response.sarif
 else
    # Adding empty SARIF response in response.sarif file.
    # This issue is from github/codeql-action/upload-sarif@v1 side. 
    # Issue link: https://github.com/psalm/psalm-github-actions/issues/23
    # This issue is an open state when this issue is resolved from the GitHub side we will remove below code line. Same for line no 13.
    echo "{\"version\": \"2.1.0\",\"runs\": [{\"tool\": {\"driver\": {\"name\": \"QualysIaCSecurity\",\"organization\": \"Qualys\"}},\"results\": []}]}" > response.sarif
 fi

 echo "Scanning Completed at - $(date +"%Y-%m-%d %H:%M:%S")"
 #process result for annotation
 echo " "
 echo "SCAN RESULT"
 cd /
 #cat result.json
 python resultParser.py result.json











