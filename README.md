# Projeto-Metro-SP-2025

Sistema de Gestão de Processos para o Metro SP - São Paulo Stock Sync

## 🚀 Tecnologias

- **Flutter** - Framework multiplataforma
- **Firebase** - Autenticação e banco de dados (Firestore)
- **Riverpod** - Gerenciamento de estado
- **GoRouter** - Navegação
- **Dart Backend** - Servidor Shelf (opcional)

## 📋 Configuração Inicial

### Firebase Setup

Este projeto usa Firebase Authentication e Cloud Firestore. **É necessário configurar o Firebase antes de executar o app.**

Consulte o arquivo [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) para instruções detalhadas de configuração.

**Resumo rápido:**
1. Instale o FlutterFire CLI: `dart pub global activate flutterfire_cli`
2. Execute `flutterfire configure` no diretório `flutter/`
3. Configure Authentication (Email/Password) e Firestore no Firebase Console

### Instalação

```bash
# Instalar dependências do Flutter
cd flutter
flutter pub get

# Instalar dependências do backend (opcional)
cd ../backend_dart
dart pub get
```

## 🏗️ Estrutura do Projeto

```
Projeto-Metro-SP-2025/
├── flutter/              # Aplicação Flutter
│   ├── lib/
│   │   ├── pages/       # Telas da aplicação
│   │   ├── state/       # Controllers e gerenciamento de estado
│   │   ├── theme/       # Tema da aplicação
│   │   └── routing.dart # Configuração de rotas
│   └── assets/          # Imagens e recursos
└── backend_dart/        # Backend opcional (Shelf)
```

## 🔐 Autenticação

A autenticação é gerenciada pelo **Firebase Auth**:
- Login com email e senha
- Cadastro de novos usuários
- Dados do usuário salvos no Firestore

## 📝 Funcionalidades

- ✅ Autenticação com Firebase
- ✅ Cadastro de usuários
- ✅ Dashboard
- ✅ Gestão de alertas
- ✅ Gestão de instrumentos
- ✅ Gestão de materiais
- ✅ Relatórios
- ✅ Configurações
- ✅ Gestão de usuários

## 🧪 Testes

```bash
cd flutter
flutter test
```

## 📱 Executar o App

```bash
cd flutter
flutter run
```

## 🔧 Backend (Opcional)

O backend Dart é opcional, pois a autenticação e persistência são feitas diretamente pelo Flutter usando Firebase.

Para executar o backend:

```bash
cd backend_dart
dart run bin/server.dart
```

O servidor estará disponível em `http://localhost:8080`

## 📚 Documentação

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Flutter Documentation](https://firebase.flutter.dev/)

## 📝 Arquivos Essenciais

- `README.md` - Este arquivo
- `firestore.rules` - Regras de segurança do Firestore
- `package.json` - Dependências Node.js para scripts de importação
- `import_firestore.js` - Script para importar dados no Firestore
- `sync_users_firestore.js` - Script para sincronizar usuários
