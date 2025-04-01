# Flutter Canvas Drawing with Zoom & Share

## Overview
This Flutter demo allows users to draw on a canvas with various colors and brush sizes. It also supports zooming and panning for precise drawing and includes a feature to share the final drawing as an image.

## Features
- **Draw on Canvas** with different colors and brush sizes.
- **Load an Image** (e.g., a black sketch) as a background for coloring.
- **Change Background Image** dynamically.
- **Zoom & Pan** using pinch gestures.
- **Clear Canvas** to start fresh.
- **Capture & Share** the drawing as an image.

## Dependencies
Ensure you have the following dependencies added to your `pubspec.yaml` file:
```yaml
dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.0.15  # For saving images
  share_plus: ^7.0.2  # For sharing images
```

## Installation & Usage
1. Clone the repository or copy the source code.
2. Add images inside the `assets/` folder.
3. Update `pubspec.yaml` to include the assets:
   ```yaml
   flutter:
     assets:
       - assets/image/black_image.png
       - assets/image/grey_image.png
       - assets/image/nature_image.png
   ```
4. Run the app:
   ```sh
   flutter run
   ```

## How It Works
- **Drawing:** Users can drag their finger to draw lines.
- **Zooming & Panning:** Users can pinch to zoom and move around the canvas.
- **Changing Background:** Users can select a different image as the background.
- **Clearing Canvas:** Tap the clear button to erase all drawings.
- **Sharing:** Tap the share button to save and share the drawing.