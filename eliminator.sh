#!/bin/bash

# ==============================================================================
# CONFIGURACIÓN
# ==============================================================================
CONTAINER_ID="c3289e7c5f09"
WAZUH_BIN="/var/ossec/bin/manage_agents"
RED='\033[0;31m'
NC='\033[0m' # No Color (Reset)

# ==============================================================================
# CABECERA
# ==============================================================================
#clear
echo -e "${RED}"
cat << "EOF"
  ______ _ _           _             _             
 |  ____| (_)         (_)           | |            
 | |__  | |_ _ __ ___  _ _ __   __ _| |_ ___  _ __ 
 |  __| | | | '_ ` _ \| | '_ \ / _` | __/ _ \| '__|
 | |____| | | | | | | | | | | | (_| | || (_) | |   
 |______|_|_|_| |_| |_|_|_| |_|\__,_|\__\___/|_|   
                                                   
EOF
echo -e " >> By Cristian Franco aka SkyH34D${NC}"
echo -e "------------------------------------------------------------"
echo -e " Introduce los agentes a eliminar (ID o Nombre)."
echo -e " Puedes introducir varios separados por comas (ej: 001, Servidor-Web, 105)"
echo -e "------------------------------------------------------------"
echo ""

# ==============================================================================
# LÓGICA PRINCIPAL
# ==============================================================================

# 1. Solicitar input al usuario
read -p "Agentes a eliminar > " USER_INPUT

if [ -z "$USER_INPUT" ]; then
    echo "Error: No has introducido ningún dato."
    exit 1
fi

# 2. Obtener la lista actual de agentes del contenedor (Cache para no saturar con peticiones)
echo -e "\n[i] Obteniendo lista actual de agentes desde Docker..."
CURRENT_LIST=$(docker exec $CONTAINER_ID $WAZUH_BIN -l)

# Verificar si el comando docker funcionó
if [ $? -ne 0 ]; then
    echo "Error: No se pudo contactar con el contenedor $CONTAINER_ID o el binario no existe."
    exit 1
fi

# 3. Procesar la entrada (separar por comas)
IFS=',' read -ra AGENT_ARRAY <<< "$USER_INPUT"

echo -e "------------------------------------------------------------"

for AGENT in "${AGENT_ARRAY[@]}"; do
    # Eliminar espacios en blanco al principio y final del input
    TARGET=$(echo "$AGENT" | xargs)
    
    TARGET_ID=""
    
    # COMPROBACIÓN: ¿Es un ID (numérico) o un Nombre?
    if [[ "$TARGET" =~ ^[0-9]+$ ]]; then
        # --- ES UN ID ---
        # Comprobamos si existe en la lista descargada previamente
        # Buscamos "ID: <NUMERO>," para asegurar coincidencia exacta
        if echo "$CURRENT_LIST" | grep -q "ID: $TARGET,"; then
            TARGET_ID=$TARGET
        else
            echo -e "${RED}[X] Error: El ID '$TARGET' no figura en la lista de agentes activos.${NC}"
            continue
        fi
    else
        # --- ES UN NOMBRE ---
        # Buscamos el nombre para obtener su ID.
        # Formato esperado: "ID: 005, Name: WIN-SERVER, IP: any"
        # Usamos grep con las comas para evitar falsos positivos (ej: 'Server' macheando 'Server2')
        EXTRACTED_ID=$(echo "$CURRENT_LIST" | grep "Name: $TARGET," | awk -F',' '{print $1}' | awk '{print $2}')
        
        if [ -n "$EXTRACTED_ID" ]; then
            TARGET_ID=$EXTRACTED_ID
            echo -e "[i] Nombre '$TARGET' traducido a ID: $TARGET_ID"
        else
            echo -e "${RED}[X] Error: El nombre de agente '$TARGET' no se encuentra en la lista.${NC}"
            continue
        fi
    fi

    # 4. Ejecutar la eliminación si tenemos un ID válido
    if [ -n "$TARGET_ID" ]; then
        echo -e "[!] Eliminando agente ID: $TARGET_ID ..."
        
        # Ejecutamos el comando de borrado dentro del docker
        RESULT=$(docker exec $CONTAINER_ID $WAZUH_BIN -r $TARGET_ID 2>&1)
        
        # Analizamos la salida del comando manage_agents
        if [[ "$RESULT" == *"removed"* ]]; then
            echo -e "    -> ✅ Éxito: Agente $TARGET_ID eliminado correctamente."
        elif [[ "$RESULT" == *"ERROR"* ]] || [[ "$RESULT" == *"not found"* ]]; then
            echo -e "    -> ${RED}❌ Fallo: Wazuh devolvió un error: $RESULT${NC}"
        else
            # Salida desconocida pero mostramos lo que devolvió
            echo -e "    -> ⚠️ Resultado: $RESULT"
        fi
    fi

done

echo -e "\n------------------------------------------------------------"
echo -e "Proceso finalizado."
