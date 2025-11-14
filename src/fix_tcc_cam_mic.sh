#!/bin/bash
set -e

echo "=== Fix TCC (Câmera/Microfone) com tccplus ==="

# Diretório e binário do tccplus
TCCPLUS_DIR="$HOME/.local/bin"
TCCPLUS_BIN="$TCCPLUS_DIR/tccplus"
TCCPLUS_ZIP_URL="https://github.com/jslegendre/tccplus/releases/download/1.0/tccplus.zip"

mkdir -p "$TCCPLUS_DIR"

# Verificar se já existe um tccplus válido
NEEDS_DOWNLOAD=1
if [[ -x "$TCCPLUS_BIN" ]]; then
  if /usr/bin/file "$TCCPLUS_BIN" 2>/dev/null | grep -qi "Mach-O"; then
    NEEDS_DOWNLOAD=0
  fi
fi

# Baixar e extrair tccplus se necessário
if [[ $NEEDS_DOWNLOAD -eq 1 ]]; then
  TMP_ZIP="$(/usr/bin/mktemp /tmp/tccplus.XXXXXX.zip)"
  /usr/bin/curl -L "$TCCPLUS_ZIP_URL" -o "$TMP_ZIP"
  /usr/bin/unzip -p "$TMP_ZIP" tccplus > "$TCCPLUS_BIN"
  /bin/chmod +x "$TCCPLUS_BIN"
  /bin/rm -f "$TMP_ZIP"
fi

# --- 1) Perguntar o NOME do app (tratando Cancelar/ESC sem erro) ---
APP_NAME="$(/usr/bin/osascript << 'EOF'
try
    tell application "System Events"
        activate
        display dialog "Digite o NOME EXATO do app (como aparece em /Applications):" ¬
            default answer "" buttons {"Cancelar", "OK"} default button "OK"
        if button returned of result is "Cancelar" then
            return ""
        else
            return text returned of result
        end if
    end tell
on error number -128 -- usuário clicou Cancelar ou pressionou Esc
    return ""
end try
EOF
)"

# Se cancelou ou deixou em branco, encerra em silêncio (sem erro no Automator)
if [[ -z "$APP_NAME" ]]; then
  exit 0
fi

# Descobrir o Bundle ID do app
BUNDLE_ID=$(/usr/bin/osascript -e "id of app \"$APP_NAME\"" 2>/dev/null || true)

if [[ -z "$BUNDLE_ID" ]]; then
  APP_NAME_ESCAPED=$(printf '%s' "$APP_NAME" | sed 's/"/\\"/g')
  /usr/bin/osascript <<EOF
set appName to "$APP_NAME_ESCAPED"
display alert "Fix TCC" message "Não consegui obter o Bundle ID do app " & appName & ". Verifique o nome e tente novamente." buttons {"Fechar"} default button "Fechar"
EOF
  exit 1
fi

APP_NAME_ESCAPED=$(printf '%s' "$APP_NAME" | sed 's/"/\\"/g')

# --- 2) Perguntar se quer DAR ou TIRAR acesso (tratando Cancelar/ESC) ---
ACTION=$(/usr/bin/osascript <<EOF
set appName to "$APP_NAME_ESCAPED"
try
    tell application "System Events"
        activate
        set dlg to display dialog "O que você deseja fazer para o app " & appName & "?" ¬
            buttons {"Cancelar", "Tirar acesso", "Dar acesso"} default button "Dar acesso"
        return button returned of dlg
    end tell
on error number -128 -- usuário cancelou
    return "Cancelar"
end try
EOF
)

# Se cancelar, sair em silêncio
if [[ "$ACTION" == "Cancelar" || -z "$ACTION" ]]; then
  exit 0
fi

# --- 3) Executar ação escolhida ---
if [[ "$ACTION" == "Dar acesso" ]]; then
  # Conceder acesso a Microfone e Câmera
  "$TCCPLUS_BIN" add Microphone "$BUNDLE_ID"
  "$TCCPLUS_BIN" add Camera "$BUNDLE_ID"

  # Reiniciar tccd
  /usr/bin/killall tccd 2>/dev/null || true

  # Mensagem de conclusão
  /usr/bin/osascript <<EOF
set appName to "$APP_NAME_ESCAPED"
display alert "Fix TCC" message "Permissões de CÂMERA e MICROFONE foram CONCEDIDAS para " & appName & "." buttons {"Fechar"} default button "Fechar"
EOF

else
  # Tirar acesso: resetar permissões de Microfone e Câmera
  "$TCCPLUS_BIN" reset Microphone "$BUNDLE_ID"
  "$TCCPLUS_BIN" reset Camera "$BUNDLE_ID"

  # Reiniciar tccd
  /usr/bin/killall tccd 2>/dev/null || true

  # Mensagem de conclusão
  /usr/bin/osascript <<EOF
set appName to "$APP_NAME_ESCAPED"
display alert "Fix TCC" message "Permissões de CÂMERA e MICROFONE foram REMOVIDAS/RESETADAS para " & appName & "." buttons {"Fechar"} default button "Fechar"
EOF
fi

exit 0
