# BlurEditor

`BlurEditor` provides image editor for drawing blur effects.

![dmeo.gif](./assets/demo.gif)


## Features

- [x] Drawing blur effects
- [x] Erasing effects
- [x] Export canvas


## Requirements

- iOS9.0 or later
- Swift 4.0 or later

## Installation

### Cocoapods

```
pod 'BlurEditor', :git => 'https://github.com/kateinoigakukun/BlurEditor.git'
```

### Carthage

```
github "kateinoigakukun/BlurEditor"
```

## Implementaion

```swift
let blurEditorView = BlurEditorView()
blurEditorView.blurRadius = 40.0
blurEditorView.lineWidth = 3.0
blurEditorView.lineCap = .square

blurEditorView.originalImage = UIImage(named: "cat.jpg")
blurEditorView.mode = .pen // or .erase

let image = blurEditorView.exportCanvas()
```
