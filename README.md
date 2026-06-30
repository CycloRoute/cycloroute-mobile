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

## Map layers (CycloMap)

The app uses a unified `CycloMap` widget (`lib/features/map/presentation/widgets/cyclo_map.dart`) across home, navigation, route preview, location pickers, and the reviewer map.

- **Obstacle reports (moderated):** Community obstacles feed the alert layer during navigation. **Reviewers** approve, reject, edit, and delete obstacle reports.
- **AI infrastructure:** Reviewers submit photo captures (analyzed, pending). **Admins** manage them in **Administrar infraestructura IA** (queue + map): approve to update the graph, reject, or delete rejected items.

`cycloroute-engine` is unchanged in this phase — moderated obstacles affect alerts and map display only, not graph routing weights.

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
