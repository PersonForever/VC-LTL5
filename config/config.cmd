@echo off
::
::  请不要直接使用此脚本，应该使用VC-LTL helper for nmake.cmd
::

call:InitMuiStrings


if /i "%VC_LTL_Helper_Load%" == "true" goto:eof

set "VC_LTL_Root=%~dp0"
set "VC_LTL_Root=%VC_LTL_Root:~0,-7%"

if "%INCLUDE%" == "" echo %ERROR_VC_LTL_CANNOT_FOUND_INCLUDE_ENV%&&goto:eof

if "%LIB%" == "" echo %ERROR_VC_LTL_CANNOT_FOUND_LIB_ENV%&&goto:eof

if "%VisualStudioVersion%" == "14.0" set DefaultVCLTLToolsVersion=14.0.24231
if "%VisualStudioVersion%" == "15.0" set DefaultVCLTLToolsVersion=14.16.27023
if "%VisualStudioVersion%" == "16.0" set DefaultVCLTLToolsVersion=14.29.30037

if "%DefaultVCLTLToolsVersion%" == "" echo %ERROR_VC_LTL_NOT_SUPPORT_PLATFORM_TOOLSET%&&goto:eof


if /i "%Platform%" == "" goto Start_VC_LTL

if /i "%Platform%" == "x86" goto Start_VC_LTL

if /i "%Platform%" == "x64" goto Start_VC_LTL

if /i "%Platform%" == "arm" goto Start_VC_LTL

if /i "%Platform%" == "arm64" goto Start_VC_LTL

echo %ERROR_VC_LTL_NOT_SUPPORT_PLATFORM%

goto:eof


:Start_VC_LTL

::VC-LTL核心版本号，由于4.X并不兼容3.X。此值可以用于兼容性判断。
set LTL_CoreVersion=5

set VC_LTL_Helper_Load=true

set LTLPlatform=%Platform%

if "%LTLPlatform%" == "" set LTLPlatform=Win32
if /i "%LTLPlatform%" == "x86" set LTLPlatform=Win32

call:FoundBestTargetPlatform



if not exist "%VC_LTL_Root%TargetPlatform\%LTLWindowsTargetPlatformMinVersion%\lib\%LTLPlatform%" echo %ERROR_VC_LTL_FILE_MISSING%&&goto:eof


echo #######################################################################
echo #                                                                     #
echo #     *         *      * *             *        * * * * *  *          #
echo #      *       *     *                 *            *      *          #
echo #       *     *     *       * * * * *  *            *      *          #
echo #        *   *       *                 *            *      *          #
echo #          *           * *             * * * *      *      * * * *    #
echo #                                                                     #
echo #######################################################################

echo VC-LTL Path : %VC_LTL_Root%
echo VC Tools Version : %VCToolsVersion%
echo WindowsTargetPlatformMinVersion : %LTLWindowsTargetPlatformMinVersion%
echo Platform : %LTLPlatform%



::修改Include
set INCLUDE=%VC_LTL_Root%TargetPlatform\header;%VC_LTL_Root%TargetPlatform\%LTLWindowsTargetPlatformMinVersion%\header;%INCLUDE%
set LIB=%VC_LTL_Root%TargetPlatform\%LTLWindowsTargetPlatformMinVersion%\lib\%LTLPlatform%;%LIB%

goto:eof


::搜索最佳TargetPlatform
:FoundBestTargetPlatform

set LTLWindowsTargetPlatformMinVersion=%WindowsTargetPlatformMinVersion%

if "%LTLWindowsTargetPlatformMinVersion%" == "" goto FoundBestTargetPlatformDefault

for /f "tokens=3 delims=." %%i in ('echo %LTLWindowsTargetPlatformMinVersion%') do set LTLWindowsTargetPlatformMinVersionBuild=%%i

if "%LTLWindowsTargetPlatformMinVersionBuild%" == "" goto FoundBestTargetPlatformDefault

if %LTLWindowsTargetPlatformMinVersionBuild% GEQ 19041 set LTLWindowsTargetPlatformMinVersion=10.0.19041.0&&goto:eof

if %LTLWindowsTargetPlatformMinVersionBuild% GEQ 10240 set LTLWindowsTargetPlatformMinVersion=10.0.10240.0&&goto:eof
if /i "%LTLPlatform%" == "arm64" set LTLWindowsTargetPlatformMinVersion=10.0.10240.0&&goto:eof

if %LTLWindowsTargetPlatformMinVersionBuild% GEQ 9200 set LTLWindowsTargetPlatformMinVersion=6.2.9200.0&&goto:eof
if /i "%LTLPlatform%" == "arm" set LTLWindowsTargetPlatformMinVersion=6.2.9200.0&&goto:eof


set LTLWindowsTargetPlatformMinVersion=6.0.6000.0

goto:eof

:FoundBestTargetPlatformDefault

if /i "%LTLPlatform%" == "arm64" set LTLWindowsTargetPlatformMinVersion=10.0.10240.0&&goto:eof

if /i "%LTLPlatform%" == "arm" set LTLWindowsTargetPlatformMinVersion=6.2.9200.0&&goto:eof

set LTLWindowsTargetPlatformMinVersion=6.0.6000.0

goto:eof

::获取当前活跃的代码页，用于识别语言环境
:GetCodePage
for /f "tokens=*" %%s in ('chcp') do set __codepage__=%%s


:TryFindCodePage
::为空，那么跳出循环
if "%__codepage__%" == "" goto:eof

echo %__codepage__% | findstr "^[0-9]" > nul

::匹配到只包含数字的，说识别成功，退出循环
if %ERRORLEVEL% == 0 goto:eof

::删除第一个字符串
set "__codepage__=%__codepage__:~1%"

goto:TryFindCodePage

goto:eof


::初始化多国语言资源
:InitMuiStrings

call:GetCodePage

set __LangID__=1033
if "%__codepage__%" == "936" (set __LangID__=2052)


call "%~dp0%__LangID__%\config.strings.cmd"


goto:eof