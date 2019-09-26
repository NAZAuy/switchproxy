@echo off & TITLE SWICTCH PROXY 1.4 BNING4 (Sdo Jesus Gomez) & COLOR 0A
REM Rutina en CMD para activar y desactivar el proxy del Ejercito Nacional. Jesus Gomez (Administrador de sistemas informaticos.)

REM Varialbes del entorno.
:-------------------------------------
    SETLOCAL
    REM SETLOCAL enabledelayedexpansion
    SET cmdipv4=10
    : Requiere configuracion 192.168.0.XXX
    : La IP de la vpn termina con especificado cmdipv4
    SET cmdProxyEnable=0
    : Desactiva la configuracion proxy y la IP del a VPN
    SET cmdPrivateIPEnable=0
    : Si se cuenta con una alternativa perfil IP al DHCP especifique 1. O para DHCP
    SET cmdEthernetName=Ethernet
    : Nombre de la Interfase a ser modificada.
    SET VarRegProxy=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings
    
REM Registrando parametros si estan disponibles.
:-------------------------------------
    IF exist %~dp0\set.cmd (
        CD /D "%~dp0"
        ECHO %Time% CARGO Y MUESTRO CONFIGURACION DESDE set.cmd >> switchproxy.log
        CALL set.cmd
        DEL set.cmd
        GOTO SetProxy
    ) ELSE (
        REM Iniciamos elregistro en archivo.
        ( Echo Inicio de registro.
          FOR /F "tokens=2" %%i in ('date /t') do echo Fecha actual %%i hora %Time%
        ) > switchproxy.log
        
        rem Si no se especifica parametros, desplegar ayuda y muestra stats.
        IF "%1" EQU "" (
            CLS
            ECHO.
            ECHO    GESTION PROXY 1.4 BNING4 por Sdo. Jesus Gomez
            ECHO    Permite de forma facil activar y desactivar el proxy.
            ECHO.
            ECHO        Especifica [switchproxy stats] para saber cual es tu configuracion actual.
            ECHO        Especifica [switchproxy actproxy] para activar la conexion PROXY.
            ECHO        Especifica [switchproxy noproxy] desactivar la conexion PROXY.
            ECHO        Especifica [switchproxy noproxy nodhcp] desactiva PROXY y activa la IP alternativa.
            ECHO        Especifica [switchproxy onlyproxy] Solo activa el proxy y no modifica la ip.
            ECHO.
            ECHO    Se requiere que edite este archivo he ingrese los valores de cmdipv4.
            ECHO    Ingrese el nombre de la tarjeta de red que queire modificar en cmdEthernetName
            GOTO FIN
        )
        Rem Buscando parametros
        IF "%1" EQU "stats" echo Ver Stats & GOTO Stats
        IF "%1" EQU "actproxy" SET cmdProxyEnable=1 & echo SET cmdProxyEnable=1 > set.cmd
        IF "%1" EQU "onlyproxy" SET cmdProxyEnable=2 & GOTO SetProxy
        IF "%1" EQU "noproxy" SET cmdProxyEnable=0 & echo :Este archivo es set.cmd > set.cmd & echo SET cmdProxyEnable=0 >> set.cmd
        IF "%2" EQU "nodhcp" SET cmdPrivateIPEnable=1 & echo SET cmdPrivateIPEnable=1 >> set.cmd

        ( echo ### Los parametros a cumplir son:
          set cmd
        ) >> switchproxy.log

        IF exist %~dp0\set.cmd GOTO SetProxy
        ECHO ### PARAMETRO INCORRECTO O ERROR NO ESPERADO.
        ECHO %Time% PARAMETRO INCORRECTO O ERROR NO ESPERADO. >> switchproxy.log
        GOTO FIN
    )

REM Marca
:-------------------------------------

REM .bat con permisos de administrador
:-------------------------------------
    :SetProxy
    ECHO ### Modificando Estado del Proxy
    ECHO %Time% Modificando Estado del Proxy >> switchproxy.log
    IF %cmdProxyEnable% GEQ 1 (
        reg add "%VarRegProxy%" /v ProxyEnable /t REG_DWORD /d 1 /f >> switchproxy.log
        reg add "%VarRegProxy%" /v ProxyServer /d 10.1.1.57:8080 /f >> switchproxy.log
        reg add "%VarRegProxy%" /v ProxyOverride /d "<local>" /f >> switchproxy.log
        ECHO ### Proxy activado para %USERNAME%
        ECHO %Time% Proxy activado para %USERNAME% >> switchproxy.log
    ) ELSE (
        reg add "%VarRegProxy%" /v ProxyEnable /t REG_DWORD /d 0 /f >> switchproxy.log
        ECHO ### Proxy desactivado para %USERNAME%
        ECHO %Time% Proxy desactivado para %USERNAME% >> switchproxy.log
    )
    REM Salir si es solo activar el plroxy.
    IF "%1" EQU "onlyproxy" GOTO FIN

REM Estado de los permisos
:-------------------------------------
    :GetAdmin
    ECHO ### Verificado los permisos de administrador
    ECHO %Time% Verificado los permisos de administrador >> switchproxy.log
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
        ECHO ... Arquitectura %PROCESSOR_ARCHITECTURE%
        ECHO %Time% Arquitectura %PROCESSOR_ARCHITECTURE% >> switchproxy.log
        >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
    ) ELSE (
        ECHO ... Arquitectura %PROCESSOR_ARCHITECTURE%
        ECHO %Time% Arquitectura %PROCESSOR_ARCHITECTURE% >> switchproxy.log
        >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
    )
    IF "%errorlevel%" NEQ "0" (
        ECHO ### Es requierido los permisos de administrador...
        ECHO %Time% Es requierido los permisos de administrador... >> switchproxy.log
        goto UACPrompt
    ) else ( goto gotAdmin )

    :UACPrompt
    ECHO ### Solicitando privilegios de administrador...
    ECHO %Time% Solicitando privilegios de administrador... >> switchproxy.log
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
    echo ### ACTIVANDO CAMBIOS EN LA TARJETA DE RED
    echo %Time% ACTIVANDO CAMBIOS EN LA TARJETA DE RED >> %~dp0\switchproxy.log

    IF %cmdProxyEnable% EQU 1 (
        netsh interface ipv4 set address "%cmdEthernetName%" static 10.1.59.%cmdipv4% 255.255.255.0 10.1.59.1 gwmetric=1 >> %~dp0\switchproxy.log
        netsh interface ip delete dnsserver "%cmdEthernetName%" all >> %~dp0\switchproxy.log
        netsh interface ipv4 add dnsserver "%cmdEthernetName%" 10.1.59.1 index=1 >> %~dp0\switchproxy.log
        ECHO ### Netsh VPN Activado con la IPv4 = 10.1.59.%cmdipv4% en la Interface "%cmdEthernetName%"
        ECHO %Time% Netsh VPN Activado con la IPv4 = 10.1.59.%cmdipv4% en la Interface "%cmdEthernetName%" >> %~dp0\switchproxy.log
    ) ELSE (
        IF %cmdPrivateIPEnable% EQU 0 (
            REM Perfil DHCP
            netsh interface ipv4 set address "%cmdEthernetName%" dhcp >> %~dp0\switchproxy.log
            netsh interface ip delete dnsserver "%cmdEthernetName%" all >> %~dp0\switchproxy.log
            netsh interface ipv4 add dnsserver "%cmdEthernetName%" dhcp >> %~dp0\switchproxy.log
            ECHO ### Netsh ADSL Activado con la DHCP en la Interface "%cmdEthernetName%"
            ECHO %Time% Netsh ADSL Activado con la DHCP en la Interface "%cmdEthernetName%" >> %~dp0\switchproxy.log
            
        ) ELSE (
            REM Perfil ip privada alternativa a la del proxy.
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
:-------------------------------------
    :Stats
    rem ComSpec=C:\WINDOWS\system32\cmd.exe
    ECHO _______________________________________
    ECHO ### Proxy Stats para %USERNAME%
    ECHO %Time% Proxy Stats para %USERNAME% >> switchproxy.log
    ( reg query "%VarRegProxy%" /v ProxyEnable | find "ProxyEnable"
      %ComSpec% /c ipconfig.exe | find "IPv4."
      %ComSpec% /c ipconfig.exe | find "IPv4 "
    ) 1>> switchproxy.log & type switchproxy.log | find /v "cmd"


rem FIN DEL CUENTO BY NAZA
:--------------------------------------  
    :FIN
    ECHO.
    TIMEOUT 3
    Exit /B
