#!/bin/bash

# 获取当前脚本目录
script_dir="$(dirname "$(realpath "$0")")"

# 设置日志文件路径
logfile="$script_dir/RouteLog.txt"
# 设置测试结果文件路径
open_results="$script_dir/ip.txt"

# 设置tcping工具路径
tcping_path="/cygdrive/g/msys64/usr/bin/tcping"

# 定义一个正则表达式来匹配src和dport，支持IPv4和IPv6
regex='src=([0-9a-fA-F:.]+).*dport=([0-9]+)'

# 初始化文件
echo "" > "$logfile"
echo "" > "$open_results"

# 打开RouteLog.txt以便用户输入日志
cmd.exe /c start "" "$logfile"

echo "请在RouteLog.txt中输入日志内容并保存"
# 等待用户按下任意键继续
# read -n 1 -s -r -p "按任意键继续..."

# 等待文件不为空且不只是空行
while true; do
  if [[ -s "$logfile" && $(grep -v '^[[:space:]]*$' "$logfile") ]]; then
    break
  fi
  sleep 1
done

# 临时文件存储提取的IP和端口
temp_dir=$(cmd /c echo %TEMP% | tr -d '\r')
temp_all=$(mktemp "$temp_dir\\temp_all.XXXXXX")
temp_open=$(mktemp "$temp_dir\\temp_open.XXXXXX")
temp_close=$(mktemp "$temp_dir\\temp_close.XXXXXX")

# 提取IP和端口并输出
echo "提取到的IP和端口："
while IFS= read -r line; do
  if [[ $line =~ $regex ]]; then
    src_ip="${BASH_REMATCH[1]}"
    dport="${BASH_REMATCH[2]}"
    # 只输出src_ip和dport（端口）
    echo "$src_ip $dport"
    echo "$src_ip $dport" >> "$temp_all"
  fi
done < "$logfile"

# 打印开始测试的信息
echo "开始tcping是否公网端口开放..."

# 测试每个IP和端口，并输出结果
while IFS= read -r ipport; do
  ip=$(echo "$ipport" | awk '{print $1}')
  port=$(echo "$ipport" | awk '{print $2}')

  #  echo "Testing $ip:$port"  # Debugging line
  result=$("$tcping_path" -n 2 "$ip" "$port" 2>&1)
  #  echo "$result"  # Debugging line

  if echo "$result" | grep -q 'Port is open'; then
    echo "$ip $port : open"
    echo "$ip $port" >> "$temp_open"
  else
    echo "$ip $port : No response"
    echo "$ip $port" >> "$temp_close"
  fi
done < "$temp_all"

# 输出开放端口的IP+端口（去重）
if [[ -s "$temp_open" ]]; then
	echo "已检测到开放端口的IP如下："
	sort "$temp_open" | uniq
	sort "$temp_open" | uniq >> "$open_results"
else
  echo "没有检测到开放端口的IP。"
fi

echo "未开放端口的IP如下："
if [[ -s "$temp_close" ]]; then
	# cat "$temp_close"
	sort "$temp_close" | uniq
else
  echo "没有提取到任何IP和端口。"
fi

# 清理临时文件
rm "$temp_all"
rm "$temp_open"
rm "$temp_close"

# 如果ip.txt文件有内容，打开文件
if grep -q '[^[:space:]]' "$open_results"; then
  echo "探测完毕,打开ip.txt..."
  cmd.exe /c start "" "$open_results"  # 在Linux中使用xdg-open，如果是Windows，使用cmd.exe打开文件
else
  echo "没有检测到公网ip，ip.txt输出失败。"
  # read -n 1 -s -r -p "按任意键继续..."
fi
