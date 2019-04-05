
# react-native-itunes-music-export

## Getting started

`$ npm install react-native-itunes-music-export --save`

### Mostly automatic installation

`$ react-native link react-native-itunes-music-export`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-itunes-music-export` and add `RNItunesMusicExport.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNItunesMusicExport.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNItunesMusicExportPackage;` to the imports at the top of the file
  - Add `new RNItunesMusicExportPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-itunes-music-export'
  	project(':react-native-itunes-music-export').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-itunes-music-export/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-itunes-music-export')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNItunesMusicExport.sln` in `node_modules/react-native-itunes-music-export/windows/RNItunesMusicExport.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Itunes.Music.Export.RNItunesMusicExport;` to the usings at the top of the file
  - Add `new RNItunesMusicExportPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNItunesMusicExport from 'react-native-itunes-music-export';

// TODO: What to do with the module?
RNItunesMusicExport;
```
  