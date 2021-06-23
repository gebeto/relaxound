# /bin/bash


function getUrl() {
	video_id=$1
	res_url=$(curl -s 'https://www.y2mate.com/mates/mp3Convert?hl=ru' \
	  -H 'authority: www.y2mate.com' \
	  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="90", "Google Chrome";v="90"' \
	  -H 'accept: */*' \
	  -H 'x-requested-with: XMLHttpRequest' \
	  -H 'sec-ch-ua-mobile: ?0' \
	  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36' \
	  -H 'content-type: application/x-www-form-urlencoded; charset=UTF-8' \
	  -H 'origin: https://www.y2mate.com' \
	  -H 'sec-fetch-site: same-origin' \
	  -H 'sec-fetch-mode: cors' \
	  -H 'sec-fetch-dest: empty' \
	  -H "referer: https://www.y2mate.com/ru/youtube-mp3/$video_id" \
	  -H 'accept-language: en-US,en;q=0.9,la;q=0.8,da;q=0.7,uk;q=0.6' \
	  -H 'cookie: PHPSESSID=p1k51lorol2m86mlh1kndrv0s2; _gid=GA1.2.523803935.1622463867; MarketGidStorage=%7B%220%22%3A%7B%7D%2C%22C705876%22%3A%7B%22page%22%3A2%2C%22time%22%3A1622464270260%7D%7D; _ga=GA1.2.2089586023.1622463867; _ga_K8CD7CY0TZ=GS1.1.1622463867.1.1.1622464402.0' \
	  --data-raw "type=youtube&_id=60b47d6e37e2de9b668b4585&v_id=$video_id&ajax=1&token=&ftype=mp3&fquality=320" \
	  --compressed | jq -r .result)
	url=`echo $res_url | awk -F'"' '{print $8}'`
	echo $url
}


if [[ $1 == "id" ]]; then
	url=$(getUrl $2)
	# echo "DOWNLOAD: $url"
	echo $url
	exit 0
fi


git pull

# DUMP old data
mkdir -p .trash
mv *.mp3 .trash/ 2>/dev/null
mv *.webm .trash/ 2>/dev/null

# get new video data
last_video_title=$(cat .lock 2>/dev/null)
last_video=$(youtube-dl -j --flat-playlist --playlist-start 1 --playlist-end 1 "https://www.youtube.com/channel/UCq22aK0t0mrOEq676Be4ezw/videos")
curr_video_title=$(echo $last_video | jq -r .title)
curr_video_url=$(echo $last_video | jq -r .url)


if [[ $last_video_title == $curr_video_title ]]; then
	echo "Already up to date."
else
	if [[ $@ == "native" ]]; then
		echo "Found new video!"
		echo "Title: $curr_video_title"
		echo "Downloading..."
		youtube-dl -U $curr_video_url -x --audio-format mp3
	else
		# echo "https://www.youtube.com/watch?v=$curr_video_url"
		open "https://www.y2mate.com/ru/youtube-mp3/$curr_video_url"
		# url=$(getUrl $curr_video_url)
		# curl -o "$curr_video_title" $url
	fi
	echo $curr_video_title > .lock
	git add .lock
	git commit -m "Downloaded new track: $curr_video_title"
	git push
fi

