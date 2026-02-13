@echo off
:: 1. 解决中文乱码 + 彻底关闭批处理指令回显（关键）
chcp 65001 >nul 2>&1

:: 2. 初始化参数变量
set "args=%*"

:: 3. 分场景执行（无参/有参），全程无冗余输出
if not defined args (
    bash "E:/Github/CheckIpPort/CheckIpPort.sh"
) else (
    :: 转换路径分隔符（反斜杠→正斜杠）
    set "args=%args:\=/%"
    bash "E:/Github/CheckIpPort/CheckIpPort.sh" %args%
)

:: 4. 执行完不闪退，且无多余提示
pause >nul