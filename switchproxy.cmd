@ECHO off & TITLE GESTION PROXY 1.0 BNING4 (Jesus Gomez) & COLOR 0A
REM Rutina en CMD para activar y desactivar el proxy del Ejercito Nacional. Jesus Gomez (Administrador de sistemas informaticos.)

REM Varialbes del entorno.
:-------------------------------------
    SETLOCAL
    REM SETLOCAL enabledelayedexpansion
    SET cmdipv4=154
    : La IP de la vpn termina con especificado cmdipv4
    SET cmdProxyEnable=1
    : Desactiva la configuracion proxy y la IP del a VPN
    SET cmdPrivateIPEnable=0
    : Si se cuenta con una alternativa al DHCP y no se decea usar.
    SET cmdEthernetName=Ethernet 2
    : Nombre de la Interfase a ser modificada.

REM Registrando parametros si estan disponibles.
:-------------------------------------
    IF exist settemp.cmd (
    ECHO ### CARGO Y MUESTRO CONFIGURACION DESDE settemp.cmd
    echo Muestro: 
    type settemp.cmd
    ECHO Muestro: 
    set cmd
    call settemp.cmd
    del settemp.cmd
    ECHO Muestro: 
    set cmd
    GOTO SetProxy
    ) ELSE (
     if "%1" EQU "/?" (
    ECHO GESTION PROXY 1.0 BNING4 por Jesus Gomez
    ECHO Permite de forma fácil activar y desactivar el proxy.
    ECHO Específica [switchproxy noproxy] para desactivar la conexión VPN.
    ECHO Específica [switchproxy noproxy nodhcp] desactiva VPN y activa alternativa en la red.
    GOTO FIN
     )
    if "%1" EQU "noproxy" SET cmdProxyEnable=0 & echo :Este archivo es settemp.cmd > settemp.cmd & echo SET cmdProxyEnable=0 >> settemp.cmd
    if "%2" EQU "nodhcp" SET cmdPrivateIPEnable=1 & echo SET cmdPrivateIPEnable=1 >> settemp.cmd
    )

REM .bat con permisos de administrador
:-------------------------------------
    :SetProxy
    ECHO ### Modificando Estado del Proxy
    IF "%cmdProxyEnable%" EQU "1" (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d 10.1.1.57:8080 /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /d "<local>" /f
    ECHO ### Proxy activado para %USERNAME%
    ) ELSE (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
    ECHO ### Proxy desactivado para %USERNAME%
    )

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
    COLOR 0C
    pushd "%CD%"
    CD /D "%~dp0"
    rem Elimino el archivo settemp.
    del settemp.cmd

    ECHO ### Modificando Netsh para la IP: %cmdipv4%
    if "%cmdProxyEnable%" EQU "1" (
    netsh interface ipv4 set address "%cmdEthernetName%" static 10.1.59.%cmdipv4% 255.255.255.0 10.1.59.1 gwmetric=1
    netsh interface ip delete dnsserver "%cmdEthernetName%" all
    netsh interface ipv4 add dnsserver "%cmdEthernetName%" 10.1.59.1 index=1
    ECHO ### Netsh VPN Activado con la IPv4 = 10.1.59.%cmdipv4% en la Interface "%cmdEthernetName%"
    ) ELSE (
    IF "%cmdPrivateIPEnable%" EQU "0" (
    rem Perfil DHCP
    netsh interface ipv4 set address "%cmdEthernetName%" dhcp
    netsh interface ip delete dnsserver "%cmdEthernetName%" all
    netsh interface ipv4 add dnsserver "%cmdEthernetName%" dhcp
    ECHO ### Netsh ADSL Activado con la DHCP en la Interface "%cmdEthernetName%"
    ) ELSE (
    rem Perfil ip privada alternativa a la del proxy.
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
    ENDLOCAL
