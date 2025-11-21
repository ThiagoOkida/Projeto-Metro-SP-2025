# 📱 Configuração Android - Metro SP

## ✅ Estrutura Criada

A estrutura Android foi criada com sucesso! Agora você só precisa:

## 🔧 Passos Finais

### 1. Adicionar o arquivo `google-services.json`

1. Abra o arquivo `google-services.json` que você baixou do Firebase Console
2. Copie TODO o conteúdo JSON
3. Cole no arquivo: `flutter/android/app/google-services.json`
4. **Substitua** o conteúdo atual (que tem apenas instruções)

### 2. Verificar o Package Name

O package name configurado é: `com.metro.sp`

**Se você usou um package name diferente no Firebase:**
- Edite o arquivo `android/app/build.gradle`
- Procure por `applicationId "com.metro.sp"`
- Altere para o package name que você usou no Firebase

### 3. Adicionar credenciais no `.env`

Adicione as credenciais do Android no arquivo `flutter/.env`:

```env
FIREBASE_ANDROID_API_KEY=sua_api_key_aqui
FIREBASE_ANDROID_APP_ID=seu_app_id_aqui
FIREBASE_ANDROID_MESSAGING_SENDER_ID=seu_sender_id_aqui
FIREBASE_ANDROID_PROJECT_ID=seu_project_id_aqui
FIREBASE_ANDROID_STORAGE_BUCKET=seu_storage_bucket_aqui
```

Você encontra essas credenciais no Firebase Console, na mesma tela onde baixou o `google-services.json`.

## ✅ Pronto!

Depois disso, você pode executar:

```bash
cd flutter
flutter run
```

E selecionar Android quando perguntar a plataforma.

## 📝 Nota

Se você precisar alterar o package name, edite:
- `android/app/build.gradle` (linha `applicationId`)
- `android/app/src/main/kotlin/com/metro/sp/MainActivity.kt` (package name)
- E mova o arquivo MainActivity.kt para a pasta correspondente ao novo package

