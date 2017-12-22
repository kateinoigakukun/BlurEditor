# BlurEditor

`BlurEditor` provides image editor for drawing blur effects.

![dmeo.gif](./assets/dmeo.gif)


## Features

- [x] Drawing blur effects
- [x] Erasing effects
- [x] Export canvas


## Installation

### Cocoapods

### Carthage

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
