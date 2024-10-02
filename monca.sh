#!/bin/bash

# Configurations
CA_PATH="/opt/CARKaim/sdk/clipasswordsdk"
APP_ID="ORAASDIKU_U_AIM_178435_User"
QUERY="Safe=ORAASDIKU_U_AIM_178435_Safe;Folder=Root;Object=ORAAS_MXCGN1U_oraasqrp024_ORAASDIKU_OAAS_UAT_RW"
REASON="test"
RETRY_INTERVAL=1.5
LOG_FILE="/var/log/get_password.log"

# Función para manejar errores
error_exit() {
    echo "Error: $1" | tee -a $LOG_FILE
    exit 1
}

# Captura de interrupciones
trap "error_exit 'Script interrumpido.'" SIGINT SIGTERM

# Obtener la contraseña
PasswordRetrieved=0
while [ $PasswordRetrieved -eq 0 ]; do
    OUT=$($CA_PATH GetPassword -p "AppDescs.AppID=$APP_ID" -p "Query=$QUERY" -p "Reason=$REASON" -p "FailRequestOnPasswordChange=false" -o "Password,PasswordChangeInProcess" 2>&1)

    if [ $? -ne 0 ]; then
        if [[ $OUT != APPAP282E* ]]; then
            error_exit "Fallo en la obtención de la contraseña: $OUT"
        else
            sleep $RETRY_INTERVAL
        fi
    else
        PasswordRetrieved=1
    fi
done

# Procesar la salida
if [ $PasswordRetrieved -eq 1 ]; then
    password=$(echo "$OUT" | awk -F',' '{print $1}')
else
    password="$OUT"
fi

# Log de la operación completada
echo "Contraseña obtenida correctamente." | tee -a $LOG_FILE

# Aquí puedes añadir el uso de la variable `password` según sea necesario.

