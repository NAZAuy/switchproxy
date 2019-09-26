# Switch Proxy CMD 1.4
- CMD que nos permite optar por tener la configuración proxy con su respectiva IP y volver a DHCP y el proxy desactivado.
# A quien va dirigido.
- Usuarios de PC portátiles que van de una red dementica a una empresarial. Es normal que en la empresa tengan configuración especifica por tema de seguridad y/o control. Switch Proxy CMD además de poder activar y desactivar el proxy, podrás cambiar el perfil de TCP/IP.
En pocos casos en la empresa misma pueden tener más de una opción de red y Switch Proxy CMD puede ser usado como tarea programada o Accesos directos para optar entre una opción y otra.
# FORMA DE USO.
- Edite el archivo CMD entre las primeras 20 líneas encontrara los parámetros que puede cambiar.
- [cmdipv4] ### La IP de la vpn termina con especificado cmdipv4, resultante 10.1.1.###
- Dentro del CMD podrás cambiar los 3 primeros valores de la IP ###.###.###. cmdipv4
- [cmdProxyEnable] [0/1] Desactiva la configuración proxy y la IP del a VPN o como parámetro en línea de comando [noproxy]
- [cmdPrivateIPEnable] [0/1] Si cuentas con una configuración alternativa al VPN y distinta a usar el DHCP o como parámetro en línea de comando [nodhcp]
- Ejecutar sin parametro para recibir ayuda
- cmdEthernetName Especifica que interface va a ser modificada.
- Comenta si no fue clara esta ayuda.
