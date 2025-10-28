# CarPlatesScanner

A Swift Package for real-time car license plate recognition using `AVFoundation`, `Vision`, and `SwiftUI`.

1. Add NSCameraUsageDescription into Info.plist for Camera Useage Description.
2. import CarPlatesScanner on top of your View.
3. To create scanner use CameraScanView { series, number in , onClose: () }
4. Plates are returned separately as series and as body (number)
5. Try Demo version to get along easier

## 🚀 Features

- 📷 Real-time number plate scanning with live camera preview.
- 🔍 Smart character post-processing (e.g. replaces `0` with `О` when needed).
- 🇺🇿 Localized support for Uzbek license plate formats.

## ⚙️ Accessibility

|       Properties         |  Description                                                                |
| ------------------------ | --------------------------------------------------------------------------- |
| onPlatesDetected         | (String, String) -> (Void): Returns 2 strings, series and number, 01 A123BC |
| onClose                  | () -> Void: Action to do when camera should close                           |
| scannedPlatesTextColor   | Color: Color of recognized plates, that are displayed for a moment          |
| toolBarItemsColor        | Color: Color of toolbar items                                               |
| cameraViewBgColor        | Color: Color of camera's background                                         |
| cameraViewBgColorOpacity | Double: Opacity for camera's background color                               |
| cutoutWidth              | CGFloat: Width of frame where you point plates                              |
| cutoutHeight             | CGFloat: Height of frame where you point plates                             |
| cutoutStrokeColor        | Color: Color of the frame's stroke                                          |
| cutoutStrokeLineWidth    | CGFloat: Width of stroke line                                               |
| font                     | Font: Font for all texts                                                    |

## 🛠 Installation

### Swift Package Manager

Use the following URL in Xcode:

https://github.com/Shoxrux715/CarPlatesScanner
