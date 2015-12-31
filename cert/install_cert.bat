@echo off
CertMgr.exe -add -c  all.aview.in.crt -s  -r localMachine Root >nul 2>&1
if /i %PROCESSOR_ARCHITECTURE% NEQ x86 (
certutil.exe -addstore -f -enterprise -user root all.aview.in.crt >nul 2>&1
)
