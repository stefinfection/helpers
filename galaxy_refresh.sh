#!/bin/bash
# This script updates the AWS presigned urls within the 
# galaxy configuration file necessary for launch.
# Will update galaxy_config.json in current directory, 
# unless other specified by user in userPath and fileName below. 
# Dependencies: jq and aws-cli
# SJG for Marth Lab 03Aug2021

# user set params
userPath=""
fileName=""
oneWeek=604800
expireTime=${oneWeek}
sampleLim=5

#consts
fields=("vcfs" "tbis")
subFields=("coverageBam" "coverageBai" "rnaSeqBam" "rnaSeqBai")
suffix="?AWSAccessKeyId"

# set file name if user did not provide
if [ -z "$fileName" ]
then
  fileName="galaxy_config.json"
fi

# check that user set path
if [ -z "$userPath" ]
then
  echo "searching current directory for ${fileName}..."
  userPath="./"
fi


# store text in variable
fullPath="$userPath$fileName"
text=$(<$fullPath)
# write out updated samples 
echo "Found ${fileName}... updating..."

# define out
out="{\n"

# update group fields
for i in ${!fields[@]};
do  
 
  # extract path from existing url
  field=${fields[$i]}
  url=$( echo $text | tr '\n\t\r' ' ' | jq -r --arg fld "$field" '.[$fld] | .[0]' )
  x=$( echo "\"$url\"" | jq 'index(".com/")'+5 )
  y=$( echo "\"$url\"" | jq --arg suf "$suffix" 'index($suf)' )
  path=$( echo "\"$url\"" | jq --argjson x $x --argjson y $y '.[$x:$y]' | cut -d'"' -f 2 )
  path="s3://${path}"
 
  # generate new url and write out
  newUrl=$( aws s3 presign $path --expires-in=$expireTime )
  out+="\t\"${field}\": [\n\t\t\"${newUrl}\"\n\t],\n"
done

# update sample subfields
for ((s=0; s<=sampleLim; s++))
  do
  
  # get individual sample (if it exists)
  sample=$( echo $text | tr '\n\t\r' ' ' | jq -r --arg fld "$s" '.[$fld]' )
  if [[ -z $sample || "$sample" == "null" ]]  #jq is dumb and returns null literal
  then
    break
  fi
  out+="\t\"${s}\": {\n"

  # iterate through subfields within sample
  for i in ${!subFields[@]};
  do
    # get old url (if it exists for current field)
    field=${subFields[i]}
    url=$( echo $sample | jq -r --arg fld "$field" '.[$fld?]' )
    url="\"$url\""
    if [[ ! -z $url && "$url" != "\"null\"" ]] #jq is dumb and returns null literal
    then
      # extract path from existing url
      x=$( echo $url | jq 'index(".com/")'+5 )
      y=$( echo $url | jq --arg suf "$suffix" 'index($suf)' )
      path=$( echo $url | jq -r --argjson x $x --argjson y $y '.[$x:$y]' | cut -d'"' -f 2)
      path="s3://${path}"

      # generate new url and write out
      newUrl=$( aws s3 presign $path --expires-in=$expireTime )
      out+="\t\t\"${field}\": \"${newUrl}\",\n"
    fi
  done
 
  # trim excess comma from last url
  out=${out:0:$((${#out} - 3))}
  out+="\n\t},\n"
done

# last formatting
out=${out:0:$((${#out} - 3))}
out+="\n}"

# clear previous data and write out new
> $fullPath
echo -e $out >> "$fullPath"
echo "successfully updated $fullPath; urls will expire one week from today"
