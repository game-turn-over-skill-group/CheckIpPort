#!/bin/bash

# 设置日志文件路径
logfile="/cygdrive/c/Users/Administrator/Desktop/1.txt"

# 设置tcping工具路径
tcping_path="/cygdrive/g/msys64/usr/bin/tcping"

# 定义一个正则表达式来匹配src和sport
regex='src=([0-9.]+).*sport=([0-9]+)'

# 临时文件存储测试结果
temp_file=$(mktemp)

# 提取IP和端口并输出
echo "提取到的IP和端口："
while IFS= read -r line; do
  if [[ $line =~ $regex ]]; then
    ip="${BASH_REMATCH[1]}"
    port="${BASH_REMATCH[2]}"
    echo "$ip $port"
    echo "$ip $port" >> "$temp_file"
  fi
done < "$logfile"

# 打印开始测试的信息
echo "开始tcping是否公网端口开放..."

# 测试每个IP和端口，并输出结果
while IFS= read -r ipport; do
  ip=$(echo "$ipport" | awk '{print $1}')
  port=$(echo "$ipport" | awk '{print $2}')

  result=$("$tcping_path" "$ip" "$port" -n 1 2>&1)
  if echo "$result" | grep -q 'open'; then
    echo "$ip $port : open"
  else
    echo "$ip $port : No response"
  fi
done < "$temp_file"

# 输出开放端口的IP
echo "已检测到开放端口的IP如下："
while IFS= read -r ipport; do
  ip=$(echo "$ipport" | awk '{print $1}')
  port=$(echo "$ipport" | awk '{print $2}')

  result=$("$tcping_path" "$ip" "$port" -n 1 2>&1)
  if echo "$result" | grep -q 'open'; then
    echo "$ip"
  fi
done < "$temp_file"

# 清理临时文件
rm "$temp_file"
