h="help"
if [ "$1" = "$h" ]
then
  echo "Mp3 downloader help"
  echo "A script to make it simpler to download mp3 files"
  echo ""
  echo "1.option is to download a youtube playlist"
  echo "2.option is to paste a link to the site with the video/mp3"
  echo "3.option is to search, this function does not work everytime"
  echo "4.option is to paste a file"
  echo ""
  echo "To use the file option (nr 4)"
  echo "You need to have a .txt file with URL's(1 url pr line)"
  echo ""
  echo "Use Ctrl+C to end script"
  echo ""
  echo "You have to install youtube-dl - repositories will respect copywrites"
  echo "sudo curl -L https://yt-dl.org/latest/youtube-dl -o /usr/local/bin/youtube-dl"
  echo "sudo chmod a+rx /usr/local/bin/youtube-dl "
  echo ""
  echo "If you get this error: ffprobe or avprobe not found. Please install one."
  echo "Install libav-tools (ffmpeg is needed to convert audio)"
  exit
fi

echo -e " \e[31m1.Playlist\e[0m"
echo -e " \e[33m2.link\e[0m"
echo -e " \e[32m3.Search\e[0m"
echo -e " \e[31m4.File\e[0m"
echo " "
echo "Enter a number: "
read valg

if [ "$valg" == "1" ]
then
    echo -e "\e[31mPaste the link to your playlist: (Youtube/Soundcloud)\e[0m"
    read link
    youtube-dl -cit --extract-audio --audio-format mp3 $link
fi
if [ "$valg" == "2" ]
then
  echo -e "\e[33mPaste your link here:\e[0m "
  read link2
  youtube-dl --extract-audio --audio-format mp3 -l $link2
fi
if [ "$valg" == "3" ]
then
  echo -e "\e[32mSearch:\e[0m"
  read link3
  youtube-dl -x --audio-format mp3 "gvsearch1:$link3"
fi
if [ "$valg" == "4" ]
then
  echo -e "\e[31mEnter the filename:\e[0m"
  read file
  while read -r line
  do
    link4="$line"
    youtube-dl --extract-audio --audio-format mp3 -l $link4
  done <"$file"
else
  exit
fi



echo -e "Your download has been saved in: "
\pwd
