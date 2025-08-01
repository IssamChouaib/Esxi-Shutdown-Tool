# Herramienta Automatizada de Gestión ESXi

Esta utilidad proporciona una interfaz gráfica (GUI) para la gestión automatizada de hosts VMware ESXi, permitiendo el apagado o reinicio controlado del servidor y todas las máquinas virtuales en ejecución. La solución se distribuye como un ejecutable autoextraíble (SFX) para una máxima facilidad de uso.

## Ejecutable Autoextraíble (SFX)

El paquete se presenta como un **ejecutable autoextraíble** que contiene:

- `plink.exe` (necesario para la comunicación SSH con ESXi)
- `esxi_shutdown.ps1` (script PowerShell con toda la lógica y la interfaz gráfica)
- `start.bat` (archivo batch que se ejecuta automáticamente y lanza el script PowerShell)

Al ejecutar el SFX, se extraen automáticamente todos los archivos necesarios en una carpeta temporal y se ejecuta `start.bat`, que inicia la utilidad de gestión. Esto garantiza una experiencia sencilla y transparente incluso para usuarios sin conocimientos técnicos.

## Características

- Apagado controlado o forzado de todas las VMs en ejecución.
- Apagado o reinicio del host ESXi tras la gestión de las VMs.
- Detección y gestión automática del fingerprint SSH.
- Registro de ejecución y errores en `esxi_manager.log`.
- Historial persistente de IPs de hosts ESXi para acceso rápido.
- Interfaz gráfica nativa en Windows; solo requiere `plink.exe`.

## Requisitos

- Windows con PowerShell 5.1 o superior.
- No es necesaria instalación previa—simplemente ejecute el archivo autoextraíble.
- Conectividad de red con el host ESXi por SSH (TCP/22).
- Credenciales con privilegios de apagado/reinicio sobre el host ESXi.

## Uso

1. Descargue y ejecute el archivo autoextraíble.
2. Introduzca la IP, usuario y contraseña del host ESXi. Seleccione **Shutdown** o **Reboot**.
3. Pulse **Execute**.
4. El script gestionará las VMs y el host según corresponda. Revise `esxi_manager.log` para el registro detallado.

## Seguridad y recomendaciones

- Las credenciales **no se almacenan en texto claro** en el log.
- Todas las operaciones quedan registradas para auditoría.
- Se recomienda realizar pruebas en entorno controlado antes de utilizar en producción.
- El script se distribuye libremente para su uso y modificación.

## Autor

Issam Chouaib  
Licencia para distribución gratuita.
