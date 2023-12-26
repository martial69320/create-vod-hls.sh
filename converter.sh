#!/bin/bash
START_TIME=$SECONDS
set -e



source="${1}"
target="${2}"
if [[ ! "${target}" ]]; then
  target="${source##*/}" # leave only last component of path
  target="${target%.*}"  # strip extension
  converted="${target}_converted.mkv"
fi

VIDEO_IN=${source}
read -p "Do you want to start 1080p conversion ? (Yes/No) " yn

case $yn in 
  yes ) 
  

echo "-----START GENERATING 1080 FILE-----"

mkdir -p ${target}
ffpb -i ${source} -c:v libx264 -preset veryfast -vf "scale=1920:1080, deband" -c:a copy ${target}/${converted}

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Temps passé: ${ELAPSED_TIME} secondes"
echo "-----FINISH GENERATING 1080p FILE-----";;
no ) echo exiting...;
    exit;;
  * ) echo invalid response;
    exit 1;;
esac

read -p "Do you want to start HLS conversion ? (Yes/No) " yn

case $yn in 
  yes ) 



START_TIME=$SECONDS

echo "-----START GENERATING HLS STREAM-----"

cd ${target}
ffpb -i ${converted} -filter_complex "[0:v]split=3[vtemp001][vtemp002][vtemp003];[vtemp001]scale=640:360:force_original_aspect_ratio=decrease[vout001];[vtemp002]scale=1280:720:force_original_aspect_ratio=decrease[vout002];[vtemp003]scale=1920:1080:force_original_aspect_ratio=decrease[vout003]" -preset veryfast -sc_threshold 0 -map "[vout001]" -c:v:0 libx264 -b:v:0 800k -maxrate:v:0 856k -bufsize:v:0 1200k -map "[vout002]" -c:v:1 libx264 -b:v:1 2800k -maxrate:v:1 2996k -bufsize:v:1 4200k -map "[vout003]" -c:v:2 libx264 -b:v:2 5000k -maxrate:v:2 5350k -bufsize:v:2 7500k -map a:0 -c:a aac -b:a 192k  -ac 2 -f hls -hls_time 4 -hls_playlist_type vod -hls_flags independent_segments -hls_segment_filename stream_%v/data%06d.ts -master_pl_name "master.m3u8" -strftime_mkdir 1 -var_stream_map "a:0,agroup:audio128,language:FRA v:0,agroup:audio128 v:1,agroup:audio128 v:2,agroup:audio128" stream_%v.m3u8
rm -r ${converted}
cd ..
tar acvf ${target}.zip ${target}
rm -r ${target}

ELAPSED_TIME=$(($SECONDS - $START_TIME))

echo "Temps passé: ${ELAPSED_TIME} secondes"
echo "-----FINISH GENERATING HLS STREAM-----";;
no ) echo exiting...;
    exit;;
  * ) echo invalid response;
    exit 1;;
esac
