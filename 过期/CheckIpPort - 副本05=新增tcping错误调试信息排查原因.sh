#!/bin/bash

# 获取当前脚本目录
script_dir="$(dirname "$(realpath "$0")")"

# 设置日志文件路径
logfile="$script_dir/RouteLog.txt"

# 设置tcping工具路径
tcping_path="/cygdrive/g/msys64/usr/bin/tcping"

# 定义一个正则表达式来匹配src和sport
regex='src=([0-9.]+).*dport=([0-9]+)'

# 临时文件存储测试结果
temp_file=$(mktemp)
temp_file_results="$script_dir/ip.txt"

# 提取IP和端口并输出
echo "提取到的IP和端口："
while IFS= read -r line; do
  if [[ $line =~ $regex ]]; then
    src_ip="${BASH_REMATCH[1]}"
    dport="${BASH_REMATCH[2]}"
    # 只输出src_ip和dport（端口）
    echo "$src_ip $dport"
    echo "$src_ip $dport" >> "$temp_file"
  fi
done < "$logfile"

# 打印开始测试的信息
echo "开始tcping是否公网端口开放..."

# 测试每个IP和端口，并输出结果
while IFS= read -r ipport; do
  ip=$(echo "$ipport" | awk '{print $1}')
  port=$(echo "$ipport" | awk '{print $2}')

  echo "Testing $ip:$port"  # Debugging line
  result=$("$tcping_path" "$ip" "$port" -n 2 2>&1)
  echo "$result"  # Debugging line

  if echo "$result" | grep -q 'Port is open'; then
    echo "$ip $port : open"
    echo "$ip" >> "$temp_file_results"
  else
    echo "$ip $port : No response"
  fi
done < "$temp_file"

# 输出开放端口的IP（去重）
if [[ -s "$temp_file_results" ]]; then
  echo "已检测到开放端口的IP如下："
  sort "$temp_file_results" | uniq
else
  echo "没有检测到开放端口的IP。"
fi

# 清理临时文件
rm "$temp_file"
# rm "$temp_file_results"
