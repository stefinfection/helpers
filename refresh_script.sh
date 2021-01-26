#!/bin/bash

# user set params
userPath=""
oneWeek=604800
expiresTime=${oneWeek}

#consts
fields=("vcfUrl" "tbiUrl" "coverageBamUrl" "coverageBaiUrl" "rnaSeqBamUrl" "rnaSeqBaiUrl" "atacSeqBamUrl" "atacSeqBaiUrl" "cnvUrl")
staticFields=("id" "order" "selectedSample" "isTumor")
suffix="?AWSAccessKeyId"

# check that user set path
if [ -z "$userPath" ]
then
  echo "Please set path where your json config files exist...exiting..."
  exit 1
fi

# add on suffix to path
path="$userPath/*.json"

for f in $path
  do

  echo "$userPath/package.json"
 
  # don't overwrite package.json
  if [ "$f" = "$userPath/package.json" ];
  then
    echo "skipping package.json..."
    continue
  fi

  echo "updating ${f}..."
  text=$(<$f)
 
  # get index of "samples" field
  i=$( echo $text | jq -r 'tostring | index("samples")' )
  i=$((i+10)) 

  # clear existing contents of file
  > $f

  # write unchanged prefix to out
  out=$( echo $text | jq -r -j --argjson i $i 'tostring | .[:$i]' ) 
  
  # iterate through samples
  samples=$( echo $text | jq -c '.samples | .[]')
  while read sample
  do
    # write unchanged sample fields
    out+="{"
    for j in ${!staticFields[@]};
    do
      stat=${staticFields[$j]}
      val=$( echo $sample | jq -r --arg fld "$stat" '.[$fld]' )
      out+="\"${stat}\":\"${val}\"," 
    done

    # update urls
    for i in ${!fields[@]}; 
    do
      # parse path to file in bucket
      field=${fields[$i]}
      x=$( echo $sample | jq -r --arg fld "$field" '.[$fld?] | index(".com/")+5' )
      y=$( echo $sample | jq -r --arg fld "$field" --arg suf "$suffix" '.[$fld?] | index($suf)' )
      offset=${#suffix}
      path=$( echo $sample | jq -r --arg fld "$field" --argjson x $x --argjson y $y '.[$fld?] | tostring | .[$x:$y]' )
      
      if [ -z "$path" ]
      then
        # replace null if there previously
        out+="\"${field}\":null,"
      else 
        # create new presigned url & add
        path="s3://${path}"
        newUrl=$( aws s3 presign $path --expires-in=$expireTime )
        out+="\"${field}\":\"${newUrl}\","
      fi
    done
  
  # last formatting
  out=${out:0:$((${#out} - 1))}
  out+="},"
  done <<< "$samples"
 
  # write out updated samples 
  out=${out:0:$((${#out} - 1))}
  echo -n $out >> $f
  echo -n "]}" >> $f
done

