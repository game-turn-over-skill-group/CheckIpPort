#!/bin/bash

# 设置日志文件路径
logfile="/cygdrive/E/云盘数据暂存区/Github/CheckIpPort/RouteLog.txt"

# 设置tcping工具路径
tcping_path="/cygdrive/g/msys64/usr/bin/tcping"

# 定义一个正则表达式来匹配src和sport
regex='src=([0-9.]+).*sport=([0-9]+).*dport=([0-9]+)'

# 临时文件存储测试结果
temp_file=$(mktemp)
temp_file_results=$(mktemp)

# 提取IP和端口并输出
echo "提取到的IP和端口："
while IFS= read -r line; do
  if [[ $line =~ $regex ]]; then
    src_ip="${BASH_REMATCH[1]}"
    sport="${BASH_REMATCH[2]}"
    dport="${BASH_REMATCH[3]}"
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

  result=$("$tcping_path" "$ip" "$port" -n 2 2>&1)
  if echo "$result" | grep -q 'open'; then
    echo "$ip $port : open"
    echo "$ip" >> "$temp_file_results"
  else
    echo "$ip $port : No response"
  fi
done < "$temp_file"

# 输出开放端口的IP（去重）
echo "已检测到开放端口的IP如下："
sort "$temp_file_results" | uniq

# 清理临时文件
rm "$temp_file"
rm "$temp_file_results"
