# Herramienta de Apagado Automático para ESXi

**Autor:** Issam Chouaib  
**Licencia:** Distribución libre (MIT)

---

## Descripción

Utilidad gráfica (GUI) para Windows que permite apagar o reiniciar de forma segura servidores VMware ESXi y sus máquinas virtuales (VMs) en ejecución, todo mediante SSH.

- 100% portable y ejecutable en cualquier equipo Windows.
- Desarrollada en PowerShell.
- Integra Plink de PuTTY para gestión segura por SSH.
- La ventana de consola se oculta automáticamente para una experiencia de usuario profesional.

---

## Funcionalidades principales

- Detección y listado de máquinas virtuales encendidas.
- Apagado controlado (graceful shutdown) de cada VM; si falla, realiza apagado forzado.
- Apagado o reinicio del host ESXi tras finalizar con las VMs.
- Historial de IPs utilizadas, con opción para limpiar el historial.
- Validación de credenciales antes de ejecutar cualquier acción.
- Toda la operación y logs se visualizan en una interfaz amigable.
- No requiere PowerCLI ni cliente vSphere local.

---

## Requisitos

- **Sistema operativo:** Windows 7, 8, 10 u 11 (x86/x64)
- **Servidor ESXi:** con SSH habilitado
- **Plink.exe:** incluido en el paquete o descargable desde [página oficial de PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)

---

## Uso

1. Descarga el ejecutable o compílalo utilizando el script proporcionado y plink.exe.
2. Ejecuta la herramienta en cualquier equipo Windows.
3. Introduce la IP del servidor ESXi, usuario (por defecto: `root`) y contraseña.
4. Selecciona si deseas apagar o reiniciar el host.
5. Pulsa el botón `Execute`. El proceso será:
    - Validar conectividad y credenciales.
    - Apagar todas las VMs en ejecución de forma segura.
    - Si una VM no apaga en 1 minuto, se forzará el apagado.
    - Apagar o reiniciar el host según tu elección.
6. El estado y los logs se mostrarán en la ventana inferior de la aplicación.

---

## Avisos de seguridad

- Las contraseñas **no se almacenan ni se registran**.
- Todo el tráfico SSH se realiza a través de Plink (PuTTY).
- **Utiliza la herramienta solo en entornos y redes de confianza**.

---

## Licencia

Distribución libre bajo licencia MIT. Consulta el archivo LICENSE para más detalles.

---

## Créditos

Desarrollado por Issam Chouaib.  
Incluye componentes de PuTTY/Plink bajo su propia licencia.
