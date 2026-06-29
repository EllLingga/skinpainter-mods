@echo off
REM ============================================================
REM  Skin Painter Mod - Auto Build Script (Windows)
REM  Requires: Java 17+  and  internet connection
REM ============================================================
setlocal enabledelayedexpansion
title Skin Painter Mod Builder

set GRADLE_VERSION=8.4
set GRADLE_URL=https://services.gradle.org/distributions/gradle-8.4-bin.zip
set GRADLE_ZIP=gradle-8.4-bin.zip
set GRADLE_DIR=gradle-8.4

echo.
echo  ===================================================
echo   Skin Painter Mod Builder - Windows
echo  ===================================================
echo.

REM ── Check Java ────────────────────────────────────────────
where java >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Java tidak ditemukan!
    echo Install Java 17 dari: https://adoptium.net/
    pause
    exit /b 1
)
echo [OK] Java ditemukan

REM ── Download Gradle ───────────────────────────────────────
if not exist "%GRADLE_DIR%\bin\gradle.bat" (
    echo [INFO] Mendownload Gradle %GRADLE_VERSION%...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest '%GRADLE_URL%' -OutFile '%GRADLE_ZIP%' -UseBasicParsing}"
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Gagal download Gradle. Cek koneksi internet.
        pause
        exit /b 1
    )

    echo [INFO] Mengekstrak Gradle...
    powershell -Command "Expand-Archive -Path '%GRADLE_ZIP%' -DestinationPath '.' -Force"
    del "%GRADLE_ZIP%"
    echo [OK] Gradle %GRADLE_VERSION% siap
) else (
    echo [OK] Gradle %GRADLE_VERSION% sudah ada
)

REM ── Generate Gradle wrapper ───────────────────────────────
echo [INFO] Membuat Gradle wrapper...
"%GRADLE_DIR%\bin\gradle.bat" wrapper --gradle-version %GRADLE_VERSION% -q
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Gagal membuat Gradle wrapper.
    pause
    exit /b 1
)
echo [OK] Gradle wrapper dibuat

REM ── Build mod ─────────────────────────────────────────────
echo.
echo [INFO] Mendownload dependencies dan mengkompilasi...
echo        (Bisa memakan waktu 5-10 menit pertama kali)
echo.

call gradlew.bat build
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Build gagal! Lihat pesan error di atas.
    pause
    exit /b 1
)

REM ── Copy result ───────────────────────────────────────────
for /f "delims=" %%f in ('dir /b /s "build\libs\skinpainter-*.jar" 2^>nul ^| findstr /v sources') do (
    set JAR_FILE=%%f
    goto :found
)

echo [ERROR] File .jar tidak ditemukan setelah build.
pause
exit /b 1

:found
copy "!JAR_FILE!" "skinpainter-mod.jar" >nul
echo.
echo  =============================================
echo   BUILD SUKSES!
echo   File: skinpainter-mod.jar
echo   Copy ke folder mods\ di direktori Minecraft!
echo  =============================================
echo.
pause
