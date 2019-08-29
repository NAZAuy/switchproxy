@echo off & TITLE SWICTCH PROXY 1.1 BNING4 (Jesus Gomez) & COLOR 0A
REM Rutina en CMD para activar y desactivar el proxy del Ejercito Nacional. Jesus Gomez (Administrador de sistemas informaticos.)

REM Varialbes del entorno.
:-------------------------------------
    SETLOCAL
    REM SETLOCAL enabledelayedexpansion
    SET cmdipv4=154
    : La IP de la vpn termina con especificado cmdipv4
    SET cmdProxyEnable=1
    : Desactiva la configuracion proxy y la IP del a VPN
    SET cmdPrivateIPEnable=1
    : Si se cuenta con una alternativa perfil IP al DHCP especifique 1. O para DHCP
    SET cmdEthernetName=Ethernet 2
    : Nombre de la Interfase a ser modificada.

REM Registrando parametros si estan disponibles.
:-------------------------------------
    IF exist %~dp0\set.cmd (
    CD /D "%~dp0"
    ECHO ### CARGO Y MUESTRO CONFIGURACION DESDE set.cmd
    CALL set.cmd
    DEL set.cmd
    ) ELSE (
    if "%1" EQU "/?" (
    ECHO GESTION PROXY 1.0 BNING4 por Jesus Gomez
    ECHO Permite de forma facil activar y desactivar el proxy.
    ECHO Especifica [switchproxy noproxy] para desactivar la conexion VPN.
    ECHO Especifica [switchproxy noproxy nodhcp] desactiva VPN y activa alternativa en la red.
    ECHO Especifica [switchproxy onlyproxy] Solo activa el proxy y no modifica la ip.
    GOTO FIN
    )
    if "%1" EQU "onlyproxy" SET cmdProxyEnable=2 & GOTO SetProxy
    if "%1" EQU "noproxy" SET cmdProxyEnable=0 & echo :Este archivo es set.cmd > set.cmd & echo SET cmdProxyEnable=0 >> set.cmd
    if "%2" EQU "nodhcp" SET cmdPrivateIPEnable=1 & echo SET cmdPrivateIPEnable=1 >> set.cmd
    )

REM Marca
:-------------------------------------

REM .bat con permisos de administrador
:-------------------------------------
    :SetProxy
    ECHO ### Modificando Estado del Proxy
    IF "%cmdProxyEnable%" GEQ "1" (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d 10.1.1.57:8080 /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /d "<local>" /f
    ECHO ### Proxy activado para %USERNAME%
    ) ELSE (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
    ECHO ### Proxy desactivado para %USERNAME%
    )
    REM Salir si es solo activar el plroxy.
    if "%1" EQU "onlyproxy" GOTO FIN

REM Estado de los permisos
:-------------------------------------
    :GetAdmin
    ECHO ### Verificado los permisos de administrador
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
    ECHO ... Arquitectura %PROCESSOR_ARCHITECTURE%
    >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
    ) ELSE (
    ECHO ... Arquitectura %PROCESSOR_ARCHITECTURE%
    >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
    )
    if "%errorlevel%" NEQ "0" (
    ECHO Es requierido los permisos de administrador...
    goto UACPrompt
    ) else ( goto gotAdmin )

    :UACPrompt
    ECHO ### Solicitando privilegios de administrador
    ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    ECHO UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

REM Aplicando cambios de configuracion
:-------------------------------------

    :gotAdmin
    COLOR 0E
    pushd "%CD%"
    CD /D "%~dp0"
    rem Elimino el archivo settemp.
    IF exist %~dp0\set.cmd del set.cmd

    if "%cmdProxyEnable%" EQU "1" (
    netsh interface ipv4 set address "%cmdEthernetName%" static 10.1.59.%cmdipv4% 255.255.255.0 10.1.59.1 gwmetric=1
    netsh interface ip delete dnsserver "%cmdEthernetName%" all
    netsh interface ipv4 add dnsserver "%cmdEthernetName%" 10.1.59.1 index=1
    ECHO ### Netsh VPN Activado con la IPv4 = 10.1.59.%cmdipv4% en la Interface "%cmdEthernetName%"
    ) ELSE (
    IF "%cmdPrivateIPEnable%" EQU "0" (
    REM Perfil DHCP
    netsh interface ipv4 set address "%cmdEthernetName%" dhcp
    netsh interface ip delete dnsserver "%cmdEthernetName%" all
    netsh interface ipv4 add dnsserver "%cmdEthernetName%" dhcp
    ECHO ### Netsh ADSL Activado con la DHCP en la Interface "%cmdEthernetName%"
    ) ELSE (
    REM Perfil ip privada alternativa a la del proxy.
    netsh interface ipv4 set address "%cmdEthernetName%" static 192.168.0.%cmdipv4% 255.255.255.0 192.168.0.1 gwmetric=1
    netsh interface ip delete dnsserver "%cmdEthernetName%" all
    netsh interface ipv4 add dnsserver "%cmdEthernetName%" 192.168.0.1 index=1
    ECHO ### Netsh ADSL Activado con la IPv4 = 192.168.0.%cmdipv4% en la Interface "%cmdEthernetName%"
    )
    )
    ECHO ### Netsh Reactiva interface: %cmdEthernetName%
    netsh interface set interface "%cmdEthernetName%" disabled
    netsh interface set interface "%cmdEthernetName%" enabled

rem FIN DEL CUENTO BY NAZA
:--------------------------------------  
    :FIN
    ECHO.
    Exit /B
