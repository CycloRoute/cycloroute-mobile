# CycloRoute - Urban Cycling Safety App

A Flutter mobile application that recommends safe cycling routes and displays real-time road risk alerts for urban cyclists.

## 🎯 Overview

CycloRoute is focused on **road safety**, not crime. It helps urban cyclists:
- Find the safest cycling routes considering road risks
- Get real-time alerts about hazardous road conditions
- Avoid high-traffic intersections and poor infrastructure segments

## 📱 Features

- **Home Screen**: View current location, risk level legend, and start route planning
- **Route Search**: Enter origin and destination with quick location suggestions
- **Route Results**: Compare three route options (Safest, Shortest, Balanced) with risk scores
- **Navigation**: Real-time navigation with active route tracking and nearby alerts
- **Risk Alert Modal**: Detailed alerts with recommendations for hazardous areas

## 🏗️ Architecture

The project follows a clean, modular architecture:

```
lib/
├── main.dart                      # App entry point
├── app/
│   ├── app.dart                   # App configuration
│   └── routes.dart                # Navigation routes
├── core/
│   ├── theme/
│   │   ├── app_colors.dart        # Color palette
│   │   └── app_theme.dart         # Material 3 theme
│   ├── constants/
│   │   └── app_strings.dart       # All text strings
│   └── utils/
├── data/
│   └── mock/
│       ├── mock_routes.dart       # Sample route data
│       └── mock_alerts.dart       # Sample alert data
├── features/                      # Feature modules
│   ├── home/
│   ├── route_search/
│   ├── route_results/
│   ├── navigation/
│   └── risk_alert/
└── shared/                        # Reusable widgets
    └── widgets/
        ├── primary_button.dart
        ├── secondary_button.dart
        └── app_card.dart
```

## 🎨 Color Palette

| Purpose | Color | Hex |
|---------|-------|-----|
| Safe Routes | Green | #22C55E |
| Navigation | Cyan | #38BDF8 |
| Medium Risk | Yellow | #F59E0B |
| High Risk Alert | Red | #EF4444 |
| Background | White | #FFFFFF |
| Cards | Light Gray | #F1F5F9 |
| Primary Text | Dark Navy | #0F172A |
| Secondary Text | Gray | #64748B |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)

### Installation

1. Clone the repository:
```bash
cd cyclerisk
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📋 Navigation Flow

```
Home Screen
    ↓
Route Search (Enter origin/destination)
    ↓
Route Results (Choose one of 3 route options)
    ↓
Navigation Screen (Real-time tracking)
    ├→ Risk Alert Modal (Tap on alert)
    └→ Back to Home (End ride)
```

## 📊 Mock Data Structure

### Routes
- **Safest Route**: Longest but with lowest risk score (15%)
- **Shortest Route**: Quick but higher risk (55%)
- **Balanced Route**: Middle ground (38%)

### Risk Levels
- **Low** (0-30): Safe roads with good infrastructure
- **Medium** (31-60): Moderate hazards, use caution
- **High** (61-100): High-risk areas, extreme alert required

### Alert Types
- High traffic intersections
- Poor/limited bike lane infrastructure
- Road construction
- Heavy traffic areas
- Steep slope sections

## 🎯 Ready for Backend Integration

The architecture is prepared for future enhancements:
- Real Maps API (Google Maps, OpenStreetMap)
- Live geolocation services
- Real backend API
- User authentication
- Route history and preferences
- Community-based alert system

## 🛠️ Technologies

- **Framework**: Flutter with Material 3
- **State Management**: StatefulWidget (can be upgraded to Provider, Riverpod, etc.)
- **Navigation**: Named routes with Flutter Navigator
- **Design**: Material Design 3
- **Font**: Inter (fallback to system default)

## 📝 Naming Conventions

- **Files**: snake_case (e.g., `home_screen.dart`)
- **Classes**: PascalCase (e.g., `HomeScreen`)
- **Variables/Functions**: camelCase (e.g., `activeRoute`)
- **Constants**: camelCase with const (e.g., `const appName`)
- **Folders**: snake_case (e.g., `route_search`)

## 🎨 Design Features

- Clean, modern UI with rounded corners (12dp radius)
- Large, accessible touch targets (56dp minimum)
- Clear visual hierarchy using colors and typography
- Smooth transitions between screens
- Responsive layout that adapts to screen sizes

## 📚 Code Quality

- Zero compilation errors
- Clean imports using `package:` format
- Modular components for reusability
- Separation of concerns (UI, data, theme)
- Mock data ready for replacement with API calls

## 🚀 Running on Different Devices

```bash
# Web (Chrome/Firefox)
flutter run -d chrome

# iOS (with iPhone connected)
flutter run -d ios

# macOS
flutter run -d macos

# Android (with emulator/device)
flutter run -d android
```

## 📦 Building for Production

```bash
# Build iOS
flutter build ios

# Build Android
flutter build apk

# Build Web
flutter build web

# Build macOS
flutter build macos
```

## 📄 License

This is a prototype/demo project for educational purposes.

## 👨‍💻 Developer Notes

- All strings are centralized in `app_strings.dart` for easy localization
- Colors are defined in `app_colors.dart` for consistency
- Theme is configured in `app_theme.dart` using Material 3
- Mock data can be easily replaced with API calls
- Each screen is self-contained within its feature folder
- Shared widgets are reusable across features

---

**Status**: MVP Complete ✅
**Ready for**: Backend Integration, Real Maps, Geolocation Services
