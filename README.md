# CycloRoute Mobile

Flutter app for CycloRoute.

The mobile app talks to:

```text
cycloroute-backend NestJS
```

The backend then talks to:

```text
cycloroute-engine FastAPI
```

## API Configuration

The backend API URL is configured with a Dart define:

```text
CYCLO_ROUTE_API_BASE_URL
```

Default value:

```text
http://localhost:3000
```

You can also configure it in `.env`:

```text
CYCLO_ROUTE_API_BASE_URL=http://localhost:3000
MAPTILER_API_KEY=your-maptiler-key
MAPTILER_STYLE=streets-v2
```

`--dart-define` has priority over `.env`, which is useful for release builds.

Run locally:

```bash
flutter run --dart-define=CYCLO_ROUTE_API_BASE_URL=http://localhost:3000
```

For Android emulator, use:

```bash
flutter run --dart-define=CYCLO_ROUTE_API_BASE_URL=http://10.0.2.2:3000
```

For production:

```bash
flutter run --dart-define=CYCLO_ROUTE_API_BASE_URL=https://api.your-domain.com
```

For release builds:

```bash
flutter build apk --dart-define=CYCLO_ROUTE_API_BASE_URL=https://api.your-domain.com
```

## Map Configuration

The app uses `flutter_map`. For production/MVP demos, use MapTiler tiles:

```text
MAPTILER_API_KEY
MAPTILER_STYLE
```

Recommended style:

```text
streets-v2
```

Run with MapTiler:

```bash
flutter run --dart-define=CYCLO_ROUTE_API_BASE_URL=http://10.0.2.2:3000 --dart-define=MAPTILER_API_KEY=your-maptiler-key --dart-define=MAPTILER_STYLE=streets-v2
```

Or set `.env`:

```text
MAPTILER_API_KEY=your-maptiler-key
MAPTILER_STYLE=streets-v2
```

If `MAPTILER_API_KEY` is empty, the app falls back to OpenStreetMap tiles for
local development only.

## Auth

Auth is handled through:

```text
lib/features/auth/data/services/auth_api_service.dart
```

Endpoints used:

```text
POST /auth/register
POST /auth/login
```

Successful login/register stores:

```text
accessToken
userId
fullName
userEmail
phoneNumber
role
```

in `SharedPreferences`.
