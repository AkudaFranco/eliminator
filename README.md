# 🛡️ Wazuh Agent Eliminator

> Una herramienta de CLI avanzada para la eliminación rápida y segura de agentes Wazuh en entornos Dockerizados.

![Bash](https://img.shields.io/badge/Script-Bash-success?style=flat-square&logo=gnu-bash)
![Wazuh](https://img.shields.io/badge/Wazuh-Manager-blue?style=flat-square&logo=wazuh)
![Docker](https://img.shields.io/badge/Environment-Docker-2496ED?style=flat-square&logo=docker)

## 📋 Descripción

**Eliminator** es un script en Bash diseñado para administradores de sistemas que gestionan **Wazuh** en contenedores Docker. Facilita la tarea repetitiva de eliminar agentes interactuando directamente con el binario `manage_agents` dentro del contenedor del Manager.

Resuelve la limitación de eliminar agentes uno a uno, permitiendo la **eliminación por lotes** y el uso de **Nombres de Agente** en lugar de solo IDs, encargándose automáticamente de la traducción y validación.

## ✨ Características

-   **Detección Inteligente:** Acepta tanto **ID numérico** (ej: `005`) como **Nombre del Agente** (ej: `SRV-PROD-01`).
-   **Procesamiento por Lotes:** Permite eliminar múltiples agentes en una sola ejecución separándolos por comas.
-   **Validación de Seguridad:** Verifica que el agente exista en el inventario antes de intentar eliminarlo, evitando errores del sistema.
-   **Soporte Docker:** Ejecuta los comandos directamente dentro del contenedor del Wazuh Manager sin necesidad de entrar en él.
-   **Interfaz Clara:** Feedback visual con códigos de colores y manejo de errores robusto.

## 🚀 Instalación y Uso

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/SkyH34D/wazuh-agent-eliminator.git](https://github.com/SkyH34D/wazuh-agent-eliminator.git)
    cd wazuh-agent-eliminator
    ```

2.  **Dar permisos de ejecución:**
    ```bash
    chmod +x eliminator.sh
    ```

3.  **Ejecutar el script:**
    ```bash
    ./eliminator.sh
    ```

## ⚙️ Configuración

⚠️ **IMPORTANTE:** Antes de usar el script, debes configurar el ID de tu contenedor Docker.

Edita el archivo `eliminator.sh` y modifica la variable `CONTAINER_ID` en la sección de configuración:

```bash
# ==============================================================================
# CONFIGURACIÓN
# ==============================================================================
CONTAINER_ID="c3289e7c5f09"  <-- Cambia esto por el ID o Nombre de tu contenedor Wazuh
WAZUH_BIN="/var/ossec/bin/manage_agents"
```

Puedes obtener el ID de tu contenedor ejecutando `docker ps`.

## 💡 Ejemplos de Uso

El script te solicitará una entrada. Puedes usar diferentes formatos:

**1. Eliminar por ID:**
```text
Agentes a eliminar > 015
```

**2. Eliminar por Nombre de Host:**
```text
Agentes a eliminar > WIN-SERVER-2019
```

**3. Eliminación Múltiple (Híbrida):**
```text
Agentes a eliminar > 012, WIN-SERVER-2019, 104, UBUNTU-LAPTOP
```
*El script limpiará automáticamente los espacios en blanco entre las comas.*

## 🛠️ Requisitos

-   Linux Host con Docker instalado.
-   Contenedor de Wazuh Manager en ejecución.
-   Permisos suficientes para ejecutar `docker exec`.

## 👨‍💻 Autor

Desarrollado por **Cristian Franco** (aka **SkyH34D**).

-   📧 Email: cristianfranco.n@outlook.com
-   🔗 [LinkedIn](https://www.linkedin.com/in/cristian-franco/)

---
*Este script se distribuye bajo licencia MIT. Úsalo bajo tu propia responsabilidad.*
