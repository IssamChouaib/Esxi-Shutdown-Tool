# Herramienta Automatizada de Gestión ESXi

Esta utilidad proporciona una interfaz gráfica (GUI) para la gestión automatizada de hosts VMware ESXi, permitiendo el apagado o reinicio controlado del servidor y todas las máquinas virtuales en ejecución. Utiliza `plink.exe` para conexiones SSH y está orientada a facilitar operaciones masivas con trazabilidad y seguridad.

## Características

- Apagado controlado (o forzado, si es necesario) de todas las VMs en ejecución.
- Apagado o reinicio del host ESXi tras la gestión de las VMs.
- Detección y gestión automática del fingerprint SSH del host.
- Generación de log de credenciales y ejecución para trazabilidad completa.
- Historial persistente de IPs de hosts ESXi para acceso rápido.
- Interfaz gráfica nativa con Windows Forms (.NET) (solo requiere `plink.exe`).

## Requisitos

- Windows con PowerShell 5.1 o superior.
- `plink.exe` (de la suite PuTTY) en el mismo directorio que el script.
- Conectividad de red al host ESXi por SSH (TCP/22).
- Credenciales con privilegios de apagado/reinicio sobre el host ESXi.

## Funcionamiento

1. **Gestión del fingerprint SSH**: El script intenta detectar y usar el fingerprint SSH del host. Si no se detecta, se asume que ya está confiado en el sistema.
2. **Verificación de credenciales**: Se comprueban las credenciales antes de ejecutar cualquier acción.
3. **Gestión de máquinas virtuales**: Se intenta un apagado controlado de todas las VMs. Si alguna no responde, se fuerza el apagado.
4. **Acción sobre el host**: Según la selección, el host ESXi será apagado o reiniciado de forma controlada.
5. **Log de operaciones**: Todas las acciones, errores y salidas se registran en `esxi_manager.log` en el directorio del script.
6. **Historial de IPs**: Los hosts gestionados quedan guardados para acceso rápido posterior.

## Uso

1. Copie `plink.exe` y el script en el mismo directorio.
2. Ejecute el script PowerShell (`.ps1`) con permisos adecuados.
3. Introduzca la IP, usuario y contraseña del host ESXi. Elija **Shutdown** o **Reboot**.
4. Pulse **Execute**. Aparecerá un mensaje de advertencia para confirmar la operación.
5. El script gestionará las VMs y el host según corresponda. Consulte `esxi_manager.log` para el registro completo.

## Seguridad y recomendaciones

- Las credenciales **no se almacenan en texto claro** en el log.
- Todas las operaciones quedan registradas para auditoría.
- Se recomienda realizar pruebas en entorno controlado antes de utilizar en producción.
- El script se distribuye de forma libre para su uso y modificación.

## Autor

Issam Chouaib  
Licencia para distribución gratuita.
