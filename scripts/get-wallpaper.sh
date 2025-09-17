#!/bin/bash
# Author: TonyChen
# Create date: 2025/04/14
# This Shell Script is used to download Bing Daily Wallpaper

# set -e

# 设置时区为日本
export TZ=Asia/Tokyo

# 输出到 GitHub Actions 日志
echo "============================"
echo "===== 壁紙ダウンロードスクリプト開始 ====="
echo "🚀 Start Bing Wallpaper Download"
echo "📅 Current Date: $CURRENT_DATE"
echo "🕒 Current Time: $(date +"%Y-%m-%d %H:%M:%S")"
echo "============================"

# Define Variables
BING_URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=ja-JP"
current_date=$(date +%Y-%m-%d)
save_dir="wallpapers"  # ✅ 改成仓库内的 wallpapers 文件夹
log_dir="logs"         # 也改为仓库内的 log 文件夹，方便一起 push
mkdir -p "$save_dir" "$log_dir"

log_file="Get-wallpaper-$current_date.log"
log_full_path="$log_dir/$log_file"
RETURN_VALUE=0
RETURN_TEXT=""

# Check log file
if [[ ! -f "$log_full_path" ]]; then
    touch "$log_full_path"
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] New log file created." >> "$log_full_path"
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] New log file created."
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] Next the save folder will be check." >> "$log_full_path"
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] Next the save folder will be check."
else
    log_full_path="$log_dir/new_$log_file"
    : > "$log_full_path"
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] The old Log have exist, new one created." >> "$log_full_path"
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] The old Log have exist, new one created."
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] Next the save folder will be check." >> "$log_full_path"
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] Next the save folder will be check."
fi

# Get wallpaper info
json=$(curl -s "$BING_URL")
imageUrlBase=$(echo "$json" | jq -r '.images[0].urlbase')
imageUrl="https://www.bing.com/${imageUrlBase}_UHD.jpg"
file_name="bing_daily_${current_date}_4k.jpg"
file_full_path="$save_dir/$file_name"

if [[ -f "$file_full_path" ]]; then
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Error] The Wallpaper file have already exist." >> "$log_full_path"
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Error] The Wallpaper file have already exist."
    RETURN_VALUE=6
else
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] The Wallpaper for $current_date have not been download." >> "$log_full_path"
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] Next Download will be start." >> "$log_full_path"
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] Start to get bing daily wallpaper. Today is $current_date." >> "$log_full_path"

    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] The Wallpaper for $current_date have not been download."
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] Next Download will be start."
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [Message] Start to get bing daily wallpaper. Today is $current_date."
    curl -s -o "$file_full_path" "$imageUrl"

    if [[ ! -f "$file_full_path" ]]; then
        RETURN_TEXT="$(date +'%Y-%m-%d-%H:%M:%S') [Error] Fail to download bing daily wallpaper."
        RETURN_VALUE=8
    fi
fi

# Result log
if [[ $RETURN_VALUE -eq 8 ]]; then
    echo "$RETURN_TEXT" >> "$log_full_path"
    echo "$RETURN_TEXT"
elif [[ $RETURN_VALUE -eq 0 ]]; then
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [SUCCESS] Download Finished." >> "$log_full_path"
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [SUCCESS] Download Finished."
elif [[ $RETURN_VALUE -eq 6 ]]; then
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [WARN] Today's Wallpaper have already exist." >> "$log_full_path"
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [WARN] Today's Wallpaper have already exist."
fi

exit $RETURN_VALUE
