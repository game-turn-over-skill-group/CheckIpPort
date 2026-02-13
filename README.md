


将win系统的去重命令移除
```bash
rename "C:\Windows\System32\sort.exe" "sort2.exe.bak"
```

使用Cygwin控制台的去重命令
调整 PATH 环境变量
```bash
set PATH=E:\Cygwin\bin;%PATH%
```

验证结果
```cmd
C:\Users\Administrator\Desktop>where sort
E:\Cygwin\bin\sort.exe
```



##### 项目发起人：rer
##### 项目协作者：豆包
