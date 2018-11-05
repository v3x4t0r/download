#/bin/bash

#Links.txt = All bookmark url`s
#url.txt = All youtube videos from links.txt
#file.txt = All files that are present
#newsongs.txt = All songs that does not exist
#code = urlcode for local files
#urlcode = urlcode for youtube bookmarks
#newurlcode = codes that are not present on the system
if [[ $1 == "install" ]]
then
  #Unlock dpkg if locked
  if [ -f /var/lib/dpkg/lock ]
  then
    rm /var/lib/dpkg/lock
  fi

  #Check if build-essentials is installed
  build=$(dpkg -l | grep build-essential)
  if [ -z "$build" ]
  then
    echo "Build-Essentail Not installed, install it? y/n"
    read install
    var=y
    if [ $install = $var ]
    then
      sudo apt install build-essential
    else exit
    fi
    else
      echo "Build-Essentail is installed"
  fi

  #Check if liblz4-dev is installed
  lz4=$(dpkg -l | grep liblz4-dev)
  if [ -z "$lz4" ]
  then
    echo "liblz4-dev = Not installed, install it? y/n"
    read install1
    var=y
    if [ $install1 = $var ]
    then
      sudo apt install liblz4-dev
    else exit
    fi
    else
      echo "liblz4-dev is installed"
  fi

  #Check if pkg-config is installed
  pkg=$(dpkg -l | grep pkg-config)
  if [ -z "$pkg" ]
  then
    echo "pkg-config = Not installed, install it? y/n"
    read install2
    var=y
    if [ $install2 = $var ]
    then
      sudo apt install pkg-config
    else exit
    fi
    else
      echo "liblz4-dev is installed"
  fi

  #Find path of lz4jsoncat if compiled
  lz4jsoncat=$(sudo find / -name 'lz4jsoncat' 2> /dev/null)
  #If lz4jsoncat does not exist, clone & compile
  if [ -z "$lz4jsoncat" ]
    then
      echo "lz4jsoncat is not installed, install now? y/n"
      read install3
      if [ $install3 = 'y' ]
      then
        if [ -d "lz4json" ]
        then
          cd lz4json && make && cd
        else
          mkdir lz4json && cd lz4json
          git clone https://github.com/andikleen/lz4json.git
          cd lz4json && make && cd
        fi
      fi
    else
      echo "lz4jsoncat is installed @ $lz4jsoncat"
    fi

    youtubedl=$(sudo find / -name 'lz4jsoncat' 2> /dev/null)
    if [ -z $youtubedl ]
    then
      echo "youtube-dl = Not installed, install it? y/n"
      read install4
      var=y
      if [ $install4 = $var ]
      then
        sudo curl -L https://yt-dl.org/latest/youtube-dl -o /usr/local/bin/youtube-dl
        sudo chmod a+rx /usr/local/bin/youtube-dl
      else exit
      fi
      else
        echo "Youtube-dl is installed"
    fi
fi


#find path of lz4jsoncat
lz4jsoncat=$(sudo find / -name 'lz4jsoncat' 2> /dev/null)

#decompress the jsonlz4 bookmarks
bookmarks=$(sudo $lz4jsoncat ~/.mozilla/firefox/*.default/bookmarkbackups/*.jsonlz4)
#Regex to match only url`s
links=$(echo $bookmarks | grep -ohP '"uri":"[^"]*' | grep -ohP 'http?.*')

#For loop to add each url to file
> links.txt
for line in $links
  do
    echo $line >> links.txt
done

#Remove duplicates and add youtube links from firefox to url.txt
links=$(sort links.txt | uniq | grep watch?v=)
IFS=$'\n'
echo $links | sed -E -e 's/[[:blank:]]+/\n/g' > url.txt
> newsongs.txt
for x in $links
do
  end=$(echo $x | grep -ohP '==?.*' | sed  's/=/-/g')
  #Find the title of the file
  title=$(curl -s $x | grep -ohP '"title":"[^"]*' | awk '{print substr($0,10); }')
  #Create full name of file
  filename=$title$end".mp3"
  echo $filename >> newsongs.txt
  echo $end | cut -c 2- | sed 's/\s//g' >> urlcode0.txt
  #Find existing files in directory (exclude .sh and .txt files)
done
sort urlcode0.txt > urlcode.txt
rm urlcode0.txt

files=$(find . -maxdepth 1 -type f -name '*.mp3' | sed 's#.*/##')

echo $files | sed -E -e 's/.mp3/\n/g' > file.txt
cat file.txt | awk '{print $NF}' | cut -d'-' -f2,3 | sed 's/\s//g' > code0.txt
sort code0.txt > code.txt
rm code0.txt

diff code.txt urlcode.txt | grep '^>' | sed 's/^>\ //g' > newurlcode.txt
>final.txt
#grep for urlcode in urlcode.txt for each line in newurlcode.txt
newurlcode=`cat newurlcode.txt`
for z in $newurlcode
do
  cat url.txt | grep $z >> final.txt
done

links=`cat final.txt`

for line in $links
do
  youtube-dl --extract-audio --audio-format mp3 -l $line 2> /dev/null
done


#What files can be made to variables or removed??
rm newsongs.txt
rm newurlcode.txt
rm urlcode.txt
rm code.txt
rm file.txt
rm links.txt
rm url.txt
