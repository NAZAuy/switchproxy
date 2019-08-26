# SwitchProxy CMD 1.0
CMD que nos permite optar por tener la configuracion proxy con su repectiva IP y volver a DHCP y el proxy desactivado.

# FORMA DE USO.

Edite el archivo CMD entre las primeras 20 lineas econtrara los parametros que puede cambiar.

REM SETLOCAL enabledelayedexpansion

SET cmdipv4=154

cmdipv4 La IP de la vpn termina con especificado cmdipv4, resultante 10.1.1.154

SET cmdProxyEnable=0

cmdProxyEnable [0/1] Desactiva la configuracion proxy y la IP del a VPN

SET cmdPrivateIPEnable=0
cmdPrivateIPEnable [0/1] Si cuentas con una configuracion alternativa al VPN y distinta a usar el DHCP 

SET cmdEthernetName=Ethernet 2

cmdEthernetName Especifica que interfase va a ser modificada.


Comenta si no fue clara esta ayuda.
