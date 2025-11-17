#!/bin/bash
# Author: TonyChen
# Create date: 2025/04/14
# This Shell Script is used to download Bing Daily Wallpaper

# set -e

# 设置时区为日本
export TZ=Asia/Tokyo

#######################################
# Slack 设置
#######################################
SLACK_API_URL="https://slack.com/api/chat.postMessage"
SLACK_CHANNEL="C09T9JA4FQW"          # 你的 channel ID
SLACK_TOKEN=$env:SLACK_TOKEN         # 从环境变量读取 Token

send_slack() {
    local text="$1"

    # 没有设置 Token 的时候就跳过发送，避免报错
    if [[ -z "$SLACK_TOKEN" ]]; then
        echo "[INFO] SLACK_TOKEN not set, skip Slack notification: $text"
        return
    fi

    curl -s --location --request POST "$SLACK_API_URL" \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --header "Authorization: Bearer $SLACK_TOKEN" \
        --data-urlencode "channel=$SLACK_CHANNEL" \
        --data-urlencode "text=$text" >/dev/null 2>&1
}

#######################################
# 变量定义
#######################################
BING_URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=ja-JP"
current_date=$(date +%Y-%m-%d)
current_time=$(date +"%H:%M:%S")
save_dir="wallpapers"  # ✅ 仓库内的 wallpapers 文件夹
log_dir="logs"         # 仓库内的 logs 文件夹
mkdir -p "$save_dir" "$log_dir"

log_file="Get-wallpaper-$current_date.log"
log_full_path="$log_dir/$log_file"
RETURN_VALUE=0
RETURN_TEXT=""

#######################################
# 开始时 Slack 通知
#######################################
send_slack "🟢 [Bing Wallpaper] スクリプト開始\n📅 日付: $current_date\n🕒 時刻: $current_time"

# 输出到 GitHub Actions 日志
echo "============================"
echo "===== 壁紙ダウンロードスクリプト開始 ====="
echo "🚀 Start Bing Wallpaper Download"
echo "📅 Current Date: $current_date"
echo "🕒 Current Time: $current_time"
echo "============================"

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

echo "🚀 Bing Wallpaper Download　finished"
echo "===== 壁紙ダウンロードスクリプト終了 ====="

#######################################
# 结束时 Slack 通知（按状态区分）
#######################################
if [[ $RETURN_VALUE -eq 0 ]]; then
    send_slack "✅ [Bing Wallpaper] ダウンロード成功\n📅 $current_date\n🖼 ファイル: $file_name"
elif [[ $RETURN_VALUE -eq 6 ]]; then
    send_slack "⚠️ [Bing Wallpaper] 既に本日の壁紙が存在します\n📅 $current_date\n🖼 ファイル: $file_name"
elif [[ $RETURN_VALUE -eq 8 ]]; then
    send_slack "❌ [Bing Wallpaper] ダウンロード失敗\n📅 $current_date\n詳細: Fail to download bing daily wallpaper."
else
    send_slack "⚠️ [Bing Wallpaper] 異常終了\n📅 $current_date\nRETURN_VALUE: $RETURN_VALUE"
fi

exit $RETURN_VALUE
