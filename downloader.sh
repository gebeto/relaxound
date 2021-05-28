# /bin/bash

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
	echo "Found new video!"
	echo "Title: $curr_video_title"
	echo "Downloading..."
	youtube-dl -U $curr_video_url -x --audio-format mp3
	echo $curr_video_title > .lock
	git add .lock
	git commit -m "Downloaded new track: $curr_video_title"
	git push
fi
