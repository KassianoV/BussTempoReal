# Manual Completo do Projeto: UFF Bus Tracker

_Documento consolidado em 06 de Julho de 2025._

## 1. Visão Geral do Projeto

Este é um protótipo de aplicativo desenvolvido em Flutter para o monitoramento em tempo real dos ônibus da Universidade Federal Fluminense (UFF). O projeto simula um sistema onde motoristas podem compartilhar sua localização e alunos podem visualizar a posição do ônibus em um mapa, com o objetivo de criar uma solução de mobilidade para a comunidade acadêmica.

O aplicativo foi desenvolvido com foco em aprendizado e implementação de tecnologias de tempo real, geolocalização e boas práticas de desenvolvimento com Flutter.

---

## 2. 🚀 Funcionalidades Implementadas

- **Tela de Login:** Interface de login com seleção de tipo de usuário (Aluno ou Motorista).
- **Validação de Formulário:**
  - A autenticação é simulada com usuários de teste para permitir o acesso.
  - Não está sendo feito autenticação nenhuma no codigo para o login.
- **Visão do Motorista:**
  - Exibe um mapa interativo usando **OpenStreetMap** através do pacote `flutter_map`.
  - Utiliza o pacote `geolocator` para obter a localização GPS real do dispositivo.
  - Ao "Ativar Compartilhamento", o app inicia um stream de localização para transmitir as coordenadas em tempo real.
- **Comunicação em Tempo Real:**
  - Implementação do protocolo **MQTT** com o pacote `mqtt_client`.
  - Conecta-se a um broker público (`mqtt-dashboard.com`) para publicar os dados de localização do motorista.
  - O tópico para publicação é `uff/onibus/UFF-01/localizacao`.
- **Visão do Aluno:**
  - Estrutura inicial com tela para seleção de rota e tela de mapa preparada para receber os dados.
- **Gerenciamento de Código:**
  - O projeto foi versionado com Git e preparado para hospedagem no GitHub.

---

## 3. 🛠️ Tecnologias e Pacotes Utilizados

- **Framework:** Flutter
- **Linguagem:** Dart
- **Mapa:** `flutter_map` (com dados do OpenStreetMap)
- **Localização:** `geolocator`
- **Comunicação em Tempo Real:** `mqtt_client` (conectado ao broker público do HiveMQ)
- **Gerenciamento de Estado:** `provider`

---

## 4. ⚙️ Guia de Instalação e Configuração

Siga estes passos para configurar o ambiente e rodar o projeto localmente.

### 4.1. Pré-requisitos

- Ter o [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado.
- Ter o [Git](https://git-scm.com/downloads) instalado.
- Um editor de código como o VS Code ou Android Studio.

### 4.2. Passos de Instalação

1.  **Clonar o Repositório:**

    ```bash
    git clone [https://github.com/seu-usuario/buss_temporeal_app.git](https://github.com/seu-usuario/buss_temporeal_app.git)
    cd buss_temporeal_app
    ```

2.  **Instalar as Dependências:**

    ```bash
    flutter pub get
    ```

3.  **Configurar Permissões de Localização (para rodar no celular):**

    - **Android:** Abra o arquivo `android/app/src/main/AndroidManifest.xml` e garanta que as seguintes permissões estão presentes antes da tag `<application>`:

      ```xml
      <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
      <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
      ```

    - **iOS:** Abra o arquivo `ios/Runner/Info.plist` e adicione as seguintes chaves dentro da tag `<dict>` principal:
      ```xml
      <key>NSLocationWhenInUseUsageDescription</key>
      <string>Este aplicativo precisa da sua localização para compartilhar a posição do ônibus.</string>
      ```

### 4.3. Como Executar o Aplicativo

- **Para rodar no Navegador (Chrome):**

  ```bash
  flutter run -d chrome
  ```

- **Para rodar em um Emulador ou Celular Conectado:**
  ```bash
  flutter run
  ```
  **Aviso:** Ao rodar pela primeira vez em um celular, o sistema operacional irá pedir permissão de localização. Você precisa aceitar para que o `geolocator` funcione.

---

## 5. ✍️ Guia de Estilo de Código

Para manter o código limpo, legível e consistente, seguimos os seguintes padrões.

### 5.1. Formatação

A regra principal é usar o formatador automático do Dart. Antes de fazer um commit, sempre rode:

```bash
dart format .
```

## 6. 🚧 Status e Próximos Passos

Status Atual: Projeto em desenvolvimento. A funcionalidade do motorista (publicação de localização) está implementada e funcional.

### Próximos Passos:

Implementar a lógica na tela do aluno para se inscrever no tópico MQTT e exibir o ônibus se movendo no mapa.

Substituir a simulação de login por uma autenticação real com um backend (ex: Firebase Authentication).

Criar uma interface para o motorista selecionar qual linha/ônibus ele está dirigindo para publicar no tópico correto.

Melhorar a UI/UX geral do aplicativo.
