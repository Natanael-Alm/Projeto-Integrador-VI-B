# 8. Geração do arquivo APK

O aplicativo será desenvolvido em **Flutter**, que compila o código Dart para código nativo Android e empacota o resultado em um arquivo **APK** (*Android Package*).

## Pré-requisitos

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e no `PATH`
2. [Android Studio](https://developer.android.com/studio) com o **Android SDK** e as *command-line tools*
3. JDK compatível, instalado junto com o Android Studio
4. Verificar o ambiente: `flutter doctor`

## Passo a passo

### 1. Definir a identidade do aplicativo
- Nome exibido: em `android/app/src/main/AndroidManifest.xml` (atributo `android:label`)
- Identificador do pacote (`applicationId`): em `android/app/build.gradle.kts`
- Versão: em `pubspec.yaml` (`version: 1.0.0+1`)
- Ícone: gerado com o pacote [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)

### 2. Executar e testar em modo de desenvolvimento
```bash
flutter pub get
flutter run            # emulador Android ou celular com depuração USB
```

### 3. Criar a chave de assinatura (*keystore*)
```bash
keytool -genkey -v -keystore ~/vitrine-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vitrine
```
Criar o arquivo `android/key.properties` (**não versionar no Git**; já está no `.gitignore`):
```properties
storePassword=<senha>
keyPassword=<senha>
keyAlias=vitrine
storeFile=C:/Users/<usuario>/vitrine-key.jks
```
O `android/app/build.gradle.kts` lê esse arquivo e assina o APK de release com a chave. Se o arquivo não existir (por exemplo, em outro computador do grupo), o release é assinado com a chave de depuração, o que permite compilar, mas não atualizar um app instalado com a chave oficial.

> Guarde uma cópia da chave `.jks` e do `key.properties` fora do repositório. Sem eles não é possível publicar atualizações assinadas com a mesma chave.

### 4. Gerar o APK de produção
```bash
flutter build apk --release
```
Arquivo gerado em:
```
build/app/outputs/flutter-apk/app-release.apk
```

Opcionalmente, para gerar APKs menores por arquitetura de processador:
```bash
flutter build apk --split-per-abi
```

### 5. Instalar no celular
- Copiar o `app-release.apk` para o aparelho e abrir o arquivo (permitindo "instalar apps de fontes desconhecidas"), ou
- Com o celular conectado por USB: `flutter install` ou `adb install build/app/outputs/flutter-apk/app-release.apk`

## Observações
- Durante o desenvolvimento, o APK de depuração pode ser gerado com `flutter build apk --debug`.
- O APK final é anexado em uma *release* do repositório do GitHub (aba **Releases**).

Referência oficial: [Build and release an Android app](https://docs.flutter.dev/deployment/android).
