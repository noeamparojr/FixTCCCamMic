# Fix TCC Cam Mic (Hackintosh)

> Utilitário simples para **conceder ou remover permissões de Câmera e Microfone** para aplicativos no macOS, pensado para cenários de **Hackintosh com AMFI desativado** (`amfi=0x80`) e patch de Wi-Fi Broadcom em Sonoma/Sequoia.

Quando usamos patches como **IOSkywalk downgrade + IO80211FamilyLegacy + AirPortBrcmNIC** e desativamos AMFI/SIP, o macOS muitas vezes **para de exibir os pop-ups de permissão** e os apps somem de *Privacy & Security → Camera / Microphone*.  
O resultado: o app não consegue acessar câmera/mic, mesmo funcionando perfeitamente em outros sistemas.

Este projeto automatiza o uso do [`tccplus`](https://github.com/jslegendre/tccplus) para **forçar a criação/remoção das entradas de TCC** para um determinado app, sem editar `config.plist` nem o banco `TCC.db` manualmente.

---

## Features

- Interface simples (via diálogos do macOS):
  - Pergunta o **nome do aplicativo** (como aparece em `/Applications`)
  - Descobre automaticamente o **Bundle ID**
  - Pergunta se você quer **DAR acesso** ou **TIRAR acesso**
- Usa `tccplus` para:
  - `add Microphone` / `add Camera`
  - `reset Microphone` / `reset Camera`
- **Baixa e atualiza o `tccplus` automaticamente** na primeira execução
- **Reinicia o serviço `tccd`** para aplicar as mudanças na hora
- Ideal para:
  - Hackintosh com **`amfi=0x80`**
  - Patches de Wi-Fi Broadcom em **macOS 14+ (Sonoma)** e **15+ (Sequoia)**
  - Setups onde os pop-ups de permissão de câmera/mic **não aparecem mais**

---

## Requisitos

- macOS (recomendado Sonoma ou superior)
- AMFI/SIP já desativados/parcialmente desativados (por conta da EFI / OpenCore)
- Ferramentas padrão do sistema:
  - `/bin/bash`
  - `curl`
  - `unzip`
  - `osascript`
- Acesso à internet na primeira execução (para baixar o `tccplus`)

> ⚠️ **Importante:** Este utilitário **não desativa AMFI nem SIP**. Ele assume que o ambiente já está configurado (por exemplo, `amfi=0x80` em `boot-args` e patches de Wi-Fi Broadcom ativos via OpenCore).

---

## Instalação

Existem duas formas principais de uso:

### 1. App Automator (.app)

1. Baixe o `.app` deste repositório (ou construa a partir do script abaixo).
2. Copie para `/Applications` ou qualquer pasta de sua preferência.
3. Na primeira execução o macOS pode exibir um aviso de segurança:
   - Vá em **Ajustes do Sistema → Privacidade e Segurança**
   - Autorize a execução do app, se necessário.

### 2. Script puro (shell)

Se você preferir, pode executar o script diretamente via Terminal, sem o app:

```bash
bash fix_tcc_cam_mic.sh

## Agradecimentos

- Ao Gabriel Luchina e aos membros do Universo Hackintosh, a maior comunidade Hackintosh do Brasil e uma das maiores do mundo, por todas as referências e informações importantes que colaboraram para a criação deste código.
- Comunidade Hackintosh BR e Dortania pelas referências de TCC/AMFI.
