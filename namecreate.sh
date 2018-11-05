#/bin/bash
echo "Provide url:"
read url
#Find end of line for the url
end=$(echo $url | grep -ohP '==?.*' | sed  's/=/-/g')
#Find the title of the file
title=$(curl -s $url | grep -ohP '"title":"[^"]*' | awk '{print substr($0,10); }')
#Create full name of file
filename=$title$end".mp3"
#Find existing files in directory (exclude .sh and .txt files)
files=$(find . -maxdepth 1 -type f -name '*.mp3' | sed 's#.*/##')
> file.txt

if [ ! -z "$files" ]
then
  echo "Comparing files"
  IFS=$'\n'
  for line in $files
  do
    #Use diff to compare the url file to existing files
    newfiles=$(diff "$filename" "$line" 2> files.txt)
    #Strip unnessecary characters with sed
    localname=$(cat files.txt | sed 's/diff://g' | sed 's/: No such file or directory//g')
    #echo $localname >> file.txt
    if [ -z $localname ]
    then
      echo "File exist"
    else
      echo "file does not exist"
      echo $url >> file.txt
    fi
  done
else
  echo "No files in directory"
  echo $url >> file.txt
fi

if [ -f files.txt ]
then
  rm files.txt
fi
sort file.txt | uniq
