@echo off
cd /d "%~dp0"
echo 永不复还 x mota-js 演示 - 本地服务启动中...
echo 浏览器打开: http://127.0.0.1:8899
"C:\Users\Administrator\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe" -m http.server 8899 --bind 127.0.0.1
pause