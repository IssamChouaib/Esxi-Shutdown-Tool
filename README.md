# ESXi Automated Shutdown Tool

**Author:** Issam Chouaib  
**License:** Free distribution / Distribución libre

## Description

A portable Windows GUI utility to safely power off or reboot VMware ESXi hosts and their running virtual machines (VMs) remotely, via SSH.  
- Written in PowerShell (auto-executable).
- Integrates PuTTY Plink for secure SSH command execution.
- No console window visible to the end user.

## Features

- Detects and lists running VMs.
- Attempts graceful VM shutdown; falls back to forced power-off if necessary.
- Optionally powers off or reboots the ESXi host once all VMs are off.
- IP address history with quick reuse and clear function.
- Credentials validation before executing any operation.
- All operations and logs shown in a friendly GUI.
- No need for local PowerCLI or vSphere client.

## How to Use

1. Download the executable or build your own from the provided script and plink.exe.
2. Run the tool on any Windows machine.
3. Enter your ESXi server IP, username (default: `root`), and password.
4. Choose whether to power off or reboot the host.
5. Click `Execute`. The utility will:
    - Validate credentials and connectivity.
    - Attempt graceful shutdown of all running VMs.
    - If a VM does not shut down in 1 minute, it will force power off.
    - Shut down or reboot the ESXi host as requested.
6. Status and logs will appear in the lower window.

> **Requires:**  
> - Windows 7/8/10/11 (x86/x64)
> - ESXi host with SSH enabled  
> - plink.exe (included)

## Security Notice

- Passwords are never saved or logged.
- SSH traffic is handled via Plink (PuTTY).
- Use on trusted networks only.

## License

MIT License / Free Distribution. See LICENSE file.

---

# Herramienta de Apagado Automático ESXi

**Autor:** Issam Chouaib  
**Licencia:** Distribución libre / Free distribution

## Descripción

Utilidad portátil con GUI para Windows, que permite apagar o reiniciar de forma segura un servidor VMware ESXi y todas sus máquinas virtuales en ejecución, mediante SSH.
- Desarrollado en PowerShell (auto-ejecutable).
- Integra Plink de PuTTY para la ejecución segura de comandos SSH.
- No aparece ventana de consola al usuario final.

## Funcionalidades

- Detecta y lista las VMs en ejecución.
- Intenta apagar cada VM de forma segura; si no responde, fuerza el apagado.
- Opcionalmente apaga o reinicia el host ESXi al finalizar.
- Historial de IPs para conexión rápida y función de limpieza.
- Valida credenciales antes de ejecutar operaciones.
- Todas las acciones y registros se muestran en la GUI.
- No requiere PowerCLI ni vSphere Client local.

## Cómo usar

1. Descarga el ejecutable o constrúyelo desde el script y plink.exe.
2. Ejecuta la utilidad en cualquier máquina Windows.
3. Introduce la IP del servidor ESXi, usuario (por defecto: `root`) y contraseña.
4. Elige si deseas apagar o reiniciar el host.
5. Haz clic en `Execute`. La utilidad:
    - Validará credenciales y conectividad.
    - Intentará apagar las VMs de forma controlada.
    - Si alguna VM no responde en 1 minuto, forzará el apagado.
    - Apagará o reiniciará el host ESXi según la opción elegida.
6. El estado y los logs aparecerán en la parte inferior de la ventana.

> **Requiere:**  
> - Windows 7/8/10/11 (x86/x64)
> - Host ESXi con SSH habilitado  
> - plink.exe (incluido)

## Aviso de seguridad

- Las contraseñas no se almacenan ni se registran.
- El tráfico SSH se gestiona mediante Plink (PuTTY).
- Utiliza la herramienta solo en redes de confianza.

## Licencia

Licencia MIT / Distribución libre. Ver archivo LICENSE.
