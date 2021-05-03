# Face recognition

ID card image comparison app and real selfie flutter app.

# Run app

    flutter clean
    flutter run


## Integrate the plugin in an existing app

### Add dependencies to pubspec.yaml

   **dependencies:**

    flutter:
	  sdk:  flutter
    
    blinkid_flutter:  ^5.11.0 // BlinkId SDK
    provider:  ^5.0.0 //State management
    // ------Firebase -----
    firebase_core:  ^1.0.4
    tflite_flutter:  ^0.8.0
    firebase_ml_vision:  ^0.12.0+1
    // ----- Camera -----
    camera:  ^0.5.8+5
    image_picker:  ^0.7.4
    image:  ^3.0.2
    image_size_getter:  ^1.0.0
    // ----- Path -----
    path_provider:  ^2.0.1
    path:  ^1.8.0
    // ------ Fonts -----
    auto_size_text:  ^2.1.0
    google_fonts:  ^2.0.0
    // ----- Animations -----
    lottie:  ^1.0.1

**Assets**

 1. Create assets folder in the root folder ./
 2. Add **mobilefacenet.tflite**, **scan_card.json** and **take_selfie.json** in the created folder
 3. Add the **lines** below in **(4)** inside pubspec.yaml file 
 4. 

    assets:
      - assets/mobilefacenet.tflite
      - assets/scan_card.json
      - assets/take_selfie.json

## Inside main.dart
Replace 

    void main(){runApp(MyApp())} or void main() => runApp(MyApp())
  By

    void main(){runApp(MultiProvider(providers: [ChangeNotifierProvider(create: (_) =>  BlinkIdService()),], child: MyApp(),));}
 

