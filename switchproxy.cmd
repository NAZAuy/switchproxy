@echo off & TITLE SWICTCH PROXY 1.4.7 BNING4 (Jesus Gomez) & COLOR 0A
CHCP 65001
REM Rutina en CMD para conmutar entre 2 redes con proxy. Jesus Gomez (Administrador de sistemas informáticos.)
REM 1.4.7 - Revisión de comentarios
REM 1.4.6 - Se agrega CHCP 65001
REM 1.4.5 - Se optimiza el código

REM Variables del entorno.
REM -------------------------------------
    REM SETLOCAL enabledelayedexpansion
    SETLOCAL
    REM Versión Actual
    SET cmdProxyVer=1.4.6
    REM Requiere configuración 192.168.0.XXX
    REM La IP de la VPN termina con especificado cmdipv4
    SET cmdipv4=10
    REM cmdProxyEnable Desactiva la configuración proxy y la IP del a VPN
    SET cmdProxyEnable=0
    REM cmdPrivateIPEnable Si se cuenta con una alternativa perfil IP al DHCP especifique 1. O para DHCP
    SET cmdPrivateIPEnable=0
    REM cmdEthernetName Nombre de la Interface a ser modificada.
    REM vea en "Panel de control\Todos los elementos de Panel de control\Conexiones de red"
    SET cmdEthernetName=Ethernet
    REM VarRegProxy Registro de Windows donde modificamos los cambios del proxy.
    SET VarRegProxy=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings
    REM DebugMode Para igual 1 activa los registros LOG. (INCOMPLETO)
    SET DebugMode = 1
    
REM Registrando parámetros si están disponibles.
REM -------------------------------------------
    IF exist %~dp0\set.cmd (
        CD /D "%~dp0"
        ECHO %Time% CARGO Y MUESTRO CONFIGURACION DESDE %~dp0\set.cmd >> %~dp0\switchproxy.log
        CALL set.cmd
        DEL set.cmd
        GOTO SetProxy
    ) ELSE (
        REM Iniciamos el registro en archivo.
        ( Echo Inicio de registro.
          FOR /F "tokens=2" %%i in ('date /t') do echo Fecha actual %%i hora %Time%
        ) > %~dp0\switchproxy.log
        
        rem Si no se especifica parámetros, desplegar ayuda y muestra stats.
        IF "%1" EQU "" (
            CLS
            ECHO.
            ECHO    GESTION PROXY %cmdProxyVer% por Jesús Gómez
            ECHO    Permite de forma fácil activar y desactivar el proxy.
            ECHO.
            ECHO        Especifica [switchproxy stats] para saber cuál es tu configuración actual.
            ECHO        Especifica [switchproxy actproxy] para activar la conexión PROXY.
            ECHO        Especifica [switchproxy noproxy] desactivar la conexión PROXY.
            ECHO        Especifica [switchproxy noproxy nodhcp] desactiva PROXY y activa la IP alternativa.
            ECHO        Especifica [switchproxy onlyproxy] Solo activa el proxy y no modifica la ip.
            ECHO.
            ECHO    Se requiere que edite este archivo he ingrese los valores de cmdipv4.
            ECHO    Ingrese el nombre de la tarjeta de red que quiere modificar en cmdEthernetName
            ECHO.
            GOTO FIN
        )
        REM Buscando parámetros

        IF "%1" EQU "stats" echo Ver Stats & GOTO Stats
        IF "%1" EQU "actproxy" SET cmdProxyEnable=1 & ECHO SET cmdProxyEnable=1 >> %~dp0\set.cmd
        IF "%1" EQU "onlyproxy" SET cmdProxyEnable=2 & GOTO SetProxy
        IF "%1" EQU "noproxy" SET cmdProxyEnable=0 & ECHO Este archivo es %~dp0\set.cmd > %~dp0\set.cmd & ECHO SET cmdProxyEnable=0 >> %~dp0\set.cmd
        IF "%2" EQU "nodhcp" SET cmdPrivateIPEnable=1 & ECHO SET cmdPrivateIPEnable=1 >> %~dp0\set.cmd

        IF exist %~dp0\set.cmd GOTO SetProxy
        GOTO FIN
    )

REM Marca
REM ------------------------------------

REM .bat con permisos de administrador
REM ------------------------------------
    :SetProxy
    ECHO ### Modificando Estado del Proxy
    ECHO %Time% Modificando Estado del Proxy >> %~dp0\switchproxy.log
    IF %cmdProxyEnable% GEQ 1 (
        reg add "%VarRegProxy%" /v ProxyEnable /t REG_DWORD /d 1 /f >> %~dp0\switchproxy.log
        reg add "%VarRegProxy%" /v ProxyServer /d 10.1.1.57:8080 /f >> %~dp0\switchproxy.log
        reg add "%VarRegProxy%" /v ProxyOverride /d "<local>" /f >> %~dp0\switchproxy.log
        ECHO ### Proxy activado para %USERNAME%
        ECHO %Time% Proxy activado para %USERNAME% >> %~dp0\switchproxy.log
    ) ELSE (
        reg add "%VarRegProxy%" /v ProxyEnable /t REG_DWORD /d 0 /f >> %~dp0\switchproxy.log
        ECHO ### Proxy desactivado para %USERNAME%
        ECHO %Time% Proxy desactivado para %USERNAME% >> %~dp0\switchproxy.log
    )
    REM Salir si es solo activar el proxy.
    IF "%1" EQU "onlyproxy" GOTO FIN

REM Estado de los permisos
REM ------------------------------------
    :GetAdmin
    ECHO ### Verificado los permisos de administrador
    ECHO %Time% Verificado los permisos de administrador >> %~dp0\switchproxy.log
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
        ECHO ... Arquitectura %PROCESSOR_ARCHITECTURE%
        ECHO %Time% Arquitectura %PROCESSOR_ARCHITECTURE% >> %~dp0\switchproxy.log
        >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
    ) ELSE (
        ECHO ... Arquitectura %PROCESSOR_ARCHITECTURE%
        ECHO %Time% Arquitectura %PROCESSOR_ARCHITECTURE% >> %~dp0\switchproxy.log
        >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
    )
    IF "%errorlevel%" NEQ "0" (
        ECHO ### Es requerido los permisos de administrador...
        ECHO %Time% Es requerido los permisos de administrador... >> %~dp0\switchproxy.log
        goto UACPrompt
    ) else ( goto GetadminPass )

    :UACPrompt
    ECHO ### Solicitando privilegios de administrador...
    ECHO %Time% Solicitando privilegios de administrador... >> %~dp0\switchproxy.log
    ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    ECHO UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

REM Aplicando cambios de configuración
REM -------------------------------------

    :GetadminPass
    COLOR 0E
    pushd "%CD%"
    CD /D "%~dp0"
    rem Elimino el archivo settemp.
    IF exist %~dp0\set.cmd del set.cmd
    echo ### ACTIVANDO CAMBIOS EN LA TARJETA DE RED
    echo %Time% ACTIVANDO CAMBIOS EN LA TARJETA DE RED >> %~dp0\switchproxy.log

    IF /I %cmdProxyEnable% GEQ 1 (
        netsh interface ipv4 set address "%cmdEthernetName%" static 10.1.59.%cmdipv4% 255.255.255.0 10.1.59.1 gwmetric=1 >> %~dp0\switchproxy.log
        netsh interface ip delete dnsserver "%cmdEthernetName%" all >> %~dp0\switchproxy.log
        netsh interface ipv4 add dnsserver "%cmdEthernetName%" 10.1.59.1 index=1 >> %~dp0\switchproxy.log
        ECHO ### Netsh VPN Activado con la IPv4 = 10.1.59.%cmdipv4% en la Interface "%cmdEthernetName%"
        ECHO %Time% Netsh VPN Activado con la IPv4 = 10.1.59.%cmdipv4% en la Interface "%cmdEthernetName%" >> %~dp0\switchproxy.log
    ) ELSE (
        IF /I %cmdPrivateIPEnable% EQU 0 (
            REM Perfil DHCP
            netsh interface ipv4 set address "%cmdEthernetName%" dhcp >> %~dp0\switchproxy.log
            netsh interface ip delete dnsserver "%cmdEthernetName%" all >> %~dp0\switchproxy.log
            netsh interface ipv4 add dnsserver "%cmdEthernetName%" dhcp >> %~dp0\switchproxy.log
            ECHO ### Netsh ADSL Activado con la DHCP en la Interface "%cmdEthernetName%"
            ECHO %Time% Netsh ADSL Activado con la DHCP en la Interface "%cmdEthernetName%" >> %~dp0\switchproxy.log 
        ) ELSE (
            REM Perfil IP privada alternativa a la del proxy.
            netsh interface ipv4 set address "%cmdEthernetName%" static 192.168.0.%cmdipv4% 255.255.255.0 192.168.0.1 gwmetric=1 >> %~dp0\switchproxy.log
            netsh interface ip delete dnsserver "%cmdEthernetName%" all >> %~dp0\switchproxy.log
            netsh interface ipv4 add dnsserver "%cmdEthernetName%" 192.168.0.1 index=1 >> %~dp0\switchproxy.log
            ECHO ### Netsh ADSL Activado con la IPv4 = 192.168.0.%cmdipv4% en la Interface "%cmdEthernetName%"
            ECHO %Time% Netsh ADSL Activado con la IPv4 = 192.168.0.%cmdipv4% en la Interface "%cmdEthernetName%" >> %~dp0\switchproxy.log
        )
    )

    ECHO ### Netsh Reactiva interface: %cmdEthernetName%
    ECHO %Time% Netsh Reactiva interface: %cmdEthernetName% >> %~dp0\switchproxy.log
    netsh interface set interface "%cmdEthernetName%" disabled >> %~dp0\switchproxy.log
    netsh interface set interface "%cmdEthernetName%" enabled >> %~dp0\switchproxy.log
    TIMEOUT 5 > nul

REM Stats
REM ------------------------------------
    :Stats
    rem ComSpec=C:\WINDOWS\system32\cmd.exe
    ECHO _______________________________________
    ECHO ### Proxy Stats para %USERNAME%
    IF "%1" NEQ "" ECHO PARAMETRO: "%1" >> %~dp0\switchproxy.log
    IF "%2" NEQ "" ECHO PARAMETRO: "%2" >> %~dp0\switchproxy.log
    IF "%3" NEQ "" ECHO PARAMETRO: "%3" >> %~dp0\switchproxy.log
    IF "%4" NEQ "" ECHO PARAMETRO: "%4" >> %~dp0\switchproxy.log
    ECHO %Time% Proxy Stats para %USERNAME% >> %~dp0\switchproxy.log
    ( reg query "%VarRegProxy%" /v ProxyEnable | find "ProxyEnable"
      %ComSpec% /c ipconfig.exe | find "IPv4."
      %ComSpec% /c ipconfig.exe | find "IPv4 "
    ) 1>> %~dp0\switchproxy.log & type switchproxy.log | find /v "cmd"


REM FIN DEL CUENTO BY NAZA
REM ------------------------------------
    :FIN
    ECHO.
    TIMEOUT 3
    Exit /B
