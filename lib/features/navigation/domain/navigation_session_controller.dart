import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/services/geolocation_service.dart';
import 'package:cyclerisk/core/services/navigation_tts_service.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/navigation/data/models/navigation_launch_args.dart';
import 'package:cyclerisk/features/navigation/data/models/navigation_session.dart';
import 'package:cyclerisk/features/navigation/data/models/route_step.dart';
import 'package:cyclerisk/features/navigation/data/repositories/navigation_cache_repository.dart';
import 'package:cyclerisk/features/navigation/data/services/navigation_api_service.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_background_coordinator.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_engine.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_tts_prompt.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_risk_alert_prompt.dart';
import 'package:cyclerisk/features/navigation/domain/route_alert_proximity.dart';
import 'package:cyclerisk/features/navigation/domain/route_alerts_resolver.dart';
import 'package:cyclerisk/features/reports/data/services/reports_api_service.dart';
import 'package:cyclerisk/features/reports/domain/community_obstacle_alerts.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/data/models/saved_route_meta.dart';
import 'package:cyclerisk/features/route_results/data/services/route_api_service.dart';
import 'package:cyclerisk/features/risk_alert/data/models/risk_alert.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

/// App-scoped navigation session. Survives [NavigationScreen] dispose so GPS,
/// reroute and TTS can continue while the app is in background.
class NavigationSessionController extends ChangeNotifier
    with WidgetsBindingObserver {
  NavigationSessionController({
    NavigationApiService? apiService,
    RouteApiService? routeApiService,
    ReportsApiService? reportsApiService,
    GeolocationService? geolocationService,
    NavigationCacheRepository? cacheRepository,
    NavigationTtsService? ttsService,
    NavigationBackgroundCoordinator? backgroundCoordinator,
    Duration mapMatchThrottle = const Duration(seconds: 3),
    Duration backgroundMapMatchThrottle = const Duration(seconds: 8),
  }) : _apiService = apiService ?? NavigationApiService(),
       _routeApiService = routeApiService ?? RouteApiService(),
       _reportsApiService = reportsApiService ?? ReportsApiService(),
       _geolocationService = geolocationService ?? GeolocationService(),
       _cacheRepository = cacheRepository ?? NavigationCacheRepository(),
       _ttsService = ttsService ?? NavigationTtsService(),
       _backgroundCoordinator =
           backgroundCoordinator ?? NavigationBackgroundCoordinator(),
       _mapMatchThrottle = mapMatchThrottle,
       _backgroundMapMatchThrottle = backgroundMapMatchThrottle {
    WidgetsBinding.instance.addObserver(this);
    _backgroundCoordinator.bindNotificationUpdater(_handleForegroundNotificationUpdate);
  }

  final NavigationApiService _apiService;
  final RouteApiService _routeApiService;
  final ReportsApiService _reportsApiService;
  final GeolocationService _geolocationService;
  final NavigationCacheRepository _cacheRepository;
  final NavigationTtsService _ttsService;
  final NavigationBackgroundCoordinator _backgroundCoordinator;
  final Duration _mapMatchThrottle;
  final Duration _backgroundMapMatchThrottle;

  NavigationSession? session;
  RouteOption? activeRoute;
  RoutePreference? preference;
  BikeProfile? bikeProfile;
  GeoPoint? destination;
  GeoPoint? origin;
  String? originLabel;
  String? destinationLabel;

  int currentStepIndex = 0;
  GeoPoint? lastSnappedPoint;
  LatLng? markerPosition;
  double distanceToRouteM = 0;
  double mapMatchDistanceFromInputM = 0;
  double progress = 0;
  double? deviceHeading;
  bool isRerouting = false;
  bool hasArrived = false;
  bool isInBackground = false;
  String? bannerMessage;
  String? errorMessage;
  RiskAlert? activeNearbyAlert;

  DateTime? _lastRerouteAt;
  DateTime? _lastMapMatchAt;
  DateTime? _offRouteSince;
  int _offRouteStreak = 0;
  StreamSubscription<LocationSnapshot>? _gpsSubscription;
  String? _accessToken;
  bool _disposed = false;
  bool _voiceGuidanceEnabled = true;
  late String _arrivalTtsMessage;
  final Set<int> _announcedApproachBuckets = {};
  int? _announcedApproachStepIndex;
  final Set<String> _dismissedAlertIds = {};
  final Set<String> _announcedAlertIds = {};
  List<RiskAlert> _communityAlerts = const [];
  String _navigationActiveLabel = 'Navigation active';
  String _recalculatingLabel = 'Recalculating route...';
  String _riskAlertTtsPrefix = 'Alert';
  String Function(int meters)? _alertDistanceFormatter;
  String? _notificationTitle;
  String? _notificationText;
  bool _gpsRestartInProgress = false;
  bool _gpsStreamActive = false;

  bool get isSessionActive =>
      session != null && activeRoute != null && !hasArrived;

  NavigationLaunchArgs? get launchArgs {
    final currentSession = session;
    final route = activeRoute;
    final pref = preference;
    final dest = destination;
    if (currentSession == null || route == null || pref == null || dest == null) {
      return null;
    }

    return NavigationLaunchArgs(
      session: currentSession,
      activeRoute: route,
      preference: pref,
      bikeProfile: bikeProfile ?? BikeProfile.urban,
      destination: dest,
      destinationLabel: destinationLabel,
      resumeStepIndex: currentStepIndex,
    );
  }

  List<RouteStep> get steps => activeRoute?.steps ?? const [];

  RouteStep? get currentStep {
    if (steps.isEmpty) {
      return null;
    }
    final index = currentStepIndex.clamp(0, steps.length - 1);
    return steps[index];
  }

  String get instruction =>
      currentStep?.instruction ??
      (steps.isEmpty ? '' : steps.last.instruction);

  List<GeoPoint> get routeCoordinates => activeRoute?.coordinates ?? const [];

  RoutePreference? get _resolvedPreference =>
      preference ?? session?.activeRouteId;

  BikeProfile get _resolvedBikeProfile => bikeProfile ?? BikeProfile.urban;

  String Function(int meters)? _ttsDistanceFormatter;

  Duration get _activeMapMatchThrottle =>
      isInBackground ? _backgroundMapMatchThrottle : _mapMatchThrottle;

  /// Starts or re-attaches a navigation session. Skips restart when the same
  /// backend session is already active (e.g. user re-opens the map screen).
  Future<void> begin({
    required NavigationLaunchArgs args,
    required String accessToken,
    required String ttsLanguageCode,
    required bool voiceGuidanceEnabled,
    required String arrivalTtsMessage,
    required String navigationActiveLabel,
    required String recalculatingNotificationLabel,
    required String riskAlertTtsPrefix,
    String Function(int meters)? ttsDistanceFormatter,
    String Function(int meters)? alertDistanceFormatter,
  }) async {
    if (isSessionActive && session?.id == args.session.id) {
      notifyListeners();
      return;
    }

    await _endLocalSession(stopApi: false);

    _accessToken = accessToken;
    _ttsDistanceFormatter = ttsDistanceFormatter;
    _arrivalTtsMessage = arrivalTtsMessage;
    _voiceGuidanceEnabled = voiceGuidanceEnabled;
    _navigationActiveLabel = navigationActiveLabel;
    _recalculatingLabel = recalculatingNotificationLabel;
    _riskAlertTtsPrefix = riskAlertTtsPrefix;
    _alertDistanceFormatter = alertDistanceFormatter;
    _backgroundCoordinator.setFallbackNotificationText(navigationActiveLabel);
    bannerMessage = null;
    errorMessage = null;
    hasArrived = false;
    _dismissedAlertIds.clear();
    _announcedAlertIds.clear();
    _communityAlerts = const [];
    activeNearbyAlert = null;

    final accessStatus = await _geolocationService.resolveAccessStatus();
    if (!accessStatus.isGranted) {
      errorMessage = 'location_denied';
      notifyListeners();
      return;
    }

    session = args.session;
    activeRoute = args.activeRoute;
    preference = args.preference;
    bikeProfile = args.bikeProfile;
    destination = args.destination;
    origin = args.origin;
    originLabel = args.originLabel;
    destinationLabel = args.destinationLabel;
    currentStepIndex = args.resumeStepIndex ?? 0;
    _lastRerouteAt = args.session.lastRerouteAt;
    _lastMapMatchAt = null;
    _offRouteSince = null;
    _offRouteStreak = 0;

    await _backgroundCoordinator.onNavigationStarted(
      destinationLabel: args.destinationLabel ?? args.destination.toString(),
    );

    await _loadCommunityAlerts(token: accessToken);

    if (voiceGuidanceEnabled) {
      await _ttsService.initialize(languageCode: ttsLanguageCode);
      _ttsService.resetStepTracking();
      _resetApproachAnnouncements();
      await _speakStepInstruction();
    } else {
      _publishInstructionNotification(instruction);
    }
    await _persistCache();
    notifyListeners();

    await _startGpsStream();
  }

  Future<void> cancelNavigation() async {
    final token = _accessToken;
    final sessionId = session?.id;
    await _persistRouteHistory();
    if (token != null && token.isNotEmpty) {
      try {
        await _apiService.cancelNavigation(
          accessToken: token,
          sessionId: sessionId,
        );
      } on ApiException {
        // Local exit even if API fails.
      }
    }
    await _endLocalSession(stopApi: false);
    await _cacheRepository.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        isInBackground = false;
        notifyListeners();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        isInBackground = true;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _completeNavigation() async {
    final token = _accessToken;
    final sessionId = session?.id;
    if (token == null || token.isEmpty || hasArrived) {
      return;
    }

    hasArrived = true;
    try {
      await _apiService.completeNavigation(
        accessToken: token,
        sessionId: sessionId,
      );
    } on ApiException {
      // Arrival UX still proceeds.
    }
    await _persistRouteHistory();
    await _cacheRepository.clear();
    if (_voiceGuidanceEnabled) {
      await _ttsService.speakMessage(
        _arrivalTtsMessage,
        dedupeKey: 'arrival',
      );
    }
    await _endLocalSession(stopApi: false);
    notifyListeners();
  }

  GeoPoint? _resolveHistoryOrigin() {
    final explicit = origin;
    if (explicit != null) {
      return explicit;
    }

    final snapped = lastSnappedPoint;
    if (snapped != null) {
      return snapped;
    }

    final marker = markerPosition;
    if (marker != null) {
      return GeoPoint(lat: marker.latitude, lng: marker.longitude);
    }

    final coords = activeRoute?.coordinates ?? const <GeoPoint>[];
    if (coords.isNotEmpty) {
      return coords.first;
    }

    final steps = activeRoute?.steps ?? const <RouteStep>[];
    if (steps.isNotEmpty) {
      return steps.first.location;
    }

    return session?.lastKnown;
  }

  Future<void> _persistRouteHistory() async {
    final token = _accessToken;
    final route = activeRoute;
    final dest = destination;
    if (token == null || token.isEmpty || route == null || dest == null) {
      return;
    }

    final resolvedOrigin = _resolveHistoryOrigin();
    if (resolvedOrigin == null) {
      return;
    }

    try {
      await _routeApiService.addRouteHistory(
        accessToken: token,
        origin: resolvedOrigin,
        destination: dest,
        selectedRoute: route,
        meta: SavedRouteMeta(
          origin: resolvedOrigin,
          destination: dest,
          originLabel: originLabel,
          destinationLabel: destinationLabel,
          planningPreference: _resolvedPreference,
          bikeProfile: _resolvedBikeProfile,
        ),
      );
    } on ApiException {
      // Best-effort: navigation UX should not fail if history cannot be saved.
    } catch (_) {}
  }

  Future<void> _endLocalSession({required bool stopApi}) async {
    await _stopGps();
    await _ttsService.stop();
    await _backgroundCoordinator.onNavigationEnded();
    session = null;
    activeRoute = null;
    destination = null;
    origin = null;
    originLabel = null;
    destinationLabel = null;
    preference = null;
    bikeProfile = null;
    markerPosition = null;
    lastSnappedPoint = null;
    activeNearbyAlert = null;
    bannerMessage = null;
    _announcedAlertIds.clear();
    _accessToken = null;
    _notificationTitle = null;
    _notificationText = null;
  }

  Future<void> _startGpsStream() async {
    final title = destinationLabel ?? 'CycloRoute';
    final text = _notificationText ??
        (instruction.trim().isEmpty ? _navigationActiveLabel : instruction.trim());
    _notificationTitle = title;
    _notificationText = text;

    await _gpsSubscription?.cancel();
    _gpsSubscription = _geolocationService
        .getNavigationLocationStream(
          notificationTitle: title,
          notificationText: text,
        )
        .listen(
          _onLocationUpdate,
          onError: (_) {},
        );
    _gpsStreamActive = true;
  }

  void _handleForegroundNotificationUpdate({
    required String title,
    required String text,
  }) {
    if (_notificationTitle == title && _notificationText == text) {
      return;
    }
    _notificationTitle = title;
    _notificationText = text;
    if (!_gpsStreamActive || !isSessionActive || _gpsRestartInProgress) {
      return;
    }
    unawaited(_restartGpsStreamForNotification());
  }

  Future<void> _restartGpsStreamForNotification() async {
    if (_gpsRestartInProgress || !isSessionActive) {
      return;
    }

    _gpsRestartInProgress = true;
    try {
      await _gpsSubscription?.cancel();
      _gpsSubscription = null;
      final title = _notificationTitle ?? destinationLabel ?? 'CycloRoute';
      final text = _notificationText ?? _navigationActiveLabel;
      _gpsSubscription = _geolocationService
          .getNavigationLocationStream(
            notificationTitle: title,
            notificationText: text,
          )
          .listen(
            _onLocationUpdate,
            onError: (_) {},
          );
    } finally {
      _gpsRestartInProgress = false;
    }
  }

  void _publishInstructionNotification(String instruction) {
    _backgroundCoordinator.onInstructionUpdated(instruction);
  }

  Future<void> _stopGps() async {
    await _gpsSubscription?.cancel();
    _gpsSubscription = null;
    _gpsStreamActive = false;
  }

  Future<void> _onLocationUpdate(LocationSnapshot fix) async {
    if (_disposed || hasArrived || isRerouting) {
      return;
    }

    final token = _accessToken;
    final route = activeRoute;
    final dest = destination;
    final pref = _resolvedPreference;
    if (token == null || route == null || dest == null || pref == null) {
      return;
    }

    deviceHeading = _validHeading(fix.heading);
    final gpsPoint = GeoPoint(
      lat: fix.point.latitude,
      lng: fix.point.longitude,
    );

    final markerPoint = lastSnappedPoint ?? gpsPoint;
    markerPosition = LatLng(markerPoint.lat, markerPoint.lng);

    distanceToRouteM = NavigationEngine.minDistanceToPolyline(
      gpsPoint,
      route.coordinates,
    );
    progress = NavigationEngine.progressOnRoute(
      markerPoint,
      route.coordinates,
    );

    if (NavigationEngine.isOffRoute(gpsPoint, polyline: route.coordinates)) {
      _offRouteStreak++;
      _offRouteSince ??= DateTime.now();
    } else {
      _offRouteStreak = 0;
      _offRouteSince = null;
    }

    if (NavigationEngine.shouldTriggerReroute(
      offRouteStreak: _offRouteStreak,
      offRouteSince: _offRouteSince,
      lastRerouteAt: _lastRerouteAt,
    )) {
      await _performReroute(
        token: token,
        fix: fix,
        destination: dest,
        preference: pref,
        bikeProfile: _resolvedBikeProfile,
      );
      return;
    }

    unawaited(
      _maybeMapMatch(
        token: token,
        gpsPoint: gpsPoint,
        fix: fix,
      ),
    );

    try {
      await _advanceStepIfReached(gpsPoint);
      await _maybeSpeakApproachAnnouncement(gpsPoint);
      await _handleNearbyAlerts(gpsPoint);

      final distanceToDest = NavigationEngine.distanceMeters(gpsPoint, dest);
      if (distanceToDest < NavigationEngine.arrivalThresholdM ||
          currentStep?.type == 'arrive') {
        await _completeNavigation();
        return;
      }
    } finally {
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  Future<void> _maybeMapMatch({
    required String token,
    required GeoPoint gpsPoint,
    required LocationSnapshot fix,
  }) async {
    final now = DateTime.now();
    final lastMatch = _lastMapMatchAt;
    if (lastMatch != null &&
        now.difference(lastMatch) < _activeMapMatchThrottle) {
      return;
    }

    _lastMapMatchAt = now;
    try {
      final snap = await _apiService.mapMatch(
        accessToken: token,
        point: gpsPoint,
        bearing: deviceHeading,
        accuracyM: fix.accuracy,
      );
      lastSnappedPoint = snap.snappedPoint;
      mapMatchDistanceFromInputM = snap.distanceFromInputM;
      final snapped = snap.snappedPoint;
      markerPosition = LatLng(snapped.lat, snapped.lng);
      if (!_disposed) {
        notifyListeners();
      }
    } on ApiException {
      // Keep last snap; off-route and steps use raw GPS.
    }
  }

  Future<void> _advanceStepIfReached(GeoPoint gpsPoint) async {
    if (steps.isEmpty || currentStepIndex >= steps.length - 1) {
      return;
    }

    final step = steps[currentStepIndex];
    final distToStep = NavigationEngine.distanceMeters(gpsPoint, step.location);
    if (distToStep >= NavigationTtsPrompt.stepReachedThresholdM) {
      return;
    }

    currentStepIndex++;
    _resetApproachAnnouncements();
    await _persistCache();
    await _speakStepInstruction();
  }

  Future<void> _performReroute({
    required String token,
    required LocationSnapshot fix,
    required GeoPoint destination,
    required RoutePreference preference,
    required BikeProfile bikeProfile,
  }) async {
    isRerouting = true;
    bannerMessage = 'recalculating';
    _publishInstructionNotification(_recalculatingLabel);
    notifyListeners();

    try {
      final result = await _apiService.reroute(
        accessToken: token,
        origin: GeoPoint(lat: fix.point.latitude, lng: fix.point.longitude),
        destination: destination,
        preference: preference,
        bikeProfile: bikeProfile,
        bearing: _validHeading(fix.heading),
        accuracyM: fix.accuracy,
        fastReroute: true,
        sessionId: session?.id,
      );

      activeRoute = result.route;
      currentStepIndex = 0;
      _dismissedAlertIds.clear();
      _announcedAlertIds.clear();
      activeNearbyAlert = null;
      lastSnappedPoint = null;
      _lastRerouteAt = DateTime.now();
      _lastMapMatchAt = null;
      _offRouteStreak = 0;
      _offRouteSince = null;
      bannerMessage = 'route_updated';
      errorMessage = null;
      _ttsService.resetStepTracking();
      _resetApproachAnnouncements();
      await _persistCache();
      await _loadCommunityAlerts(token: token);
      await _speakStepInstruction();
    } on ApiException catch (e) {
      errorMessage = e.message;
      bannerMessage = null;
    } catch (_) {
      errorMessage = 'reroute_failed';
      bannerMessage = null;
    } finally {
      isRerouting = false;
      notifyListeners();
    }
  }

  Future<void> _persistCache() async {
    final currentSession = session;
    final route = activeRoute;
    final pref = preference;
    final profile = bikeProfile;
    final dest = destination;
    if (currentSession == null ||
        route == null ||
        pref == null ||
        dest == null) {
      return;
    }

    await _cacheRepository.save(
      NavigationCacheData(
        session: currentSession,
        activeRoute: route,
        preference: pref,
        bikeProfile: profile ?? BikeProfile.urban,
        destination: dest,
        destinationLabel: destinationLabel,
        currentStepIndex: currentStepIndex,
      ),
    );
  }

  Future<void> _speakStepInstruction() async {
    if (!_voiceGuidanceEnabled) {
      return;
    }
    final step = currentStep;
    if (step == null) {
      return;
    }

    final text = step.instruction.trim();
    _publishInstructionNotification(text);

    if (!_voiceGuidanceEnabled) {
      return;
    }

    await _ttsService.speakInstruction(
      text: text,
      stepIndex: currentStepIndex,
      dedupeKey: 'step:$currentStepIndex:$text',
    );
  }

  Future<void> _maybeSpeakApproachAnnouncement(GeoPoint gpsPoint) async {
    if (!_voiceGuidanceEnabled) {
      return;
    }
    final step = currentStep;
    final formatter = _ttsDistanceFormatter;
    if (step == null || formatter == null) {
      return;
    }

    if (_announcedApproachStepIndex != currentStepIndex) {
      _resetApproachAnnouncements();
    }

    final liveDistanceM = NavigationEngine.distanceMeters(
      gpsPoint,
      step.location,
    ).round();

    final bucket = NavigationTtsPrompt.nextApproachBucket(
      distanceM: liveDistanceM,
      announcedBuckets: _announcedApproachBuckets,
    );
    if (bucket == null) {
      return;
    }

    _announcedApproachBuckets.add(bucket);
    _announcedApproachStepIndex = currentStepIndex;

    final text = NavigationTtsPrompt.build(
      instruction: step.instruction,
      distanceM: bucket,
      distanceFormatter: formatter,
    );
    if (text.isEmpty) {
      return;
    }

    await _ttsService.speakInstruction(
      text: text,
      stepIndex: currentStepIndex,
      dedupeKey: 'approach:$currentStepIndex:$bucket',
    );
  }

  void _resetApproachAnnouncements() {
    _announcedApproachBuckets.clear();
    _announcedApproachStepIndex = null;
  }

  Future<void> _loadCommunityAlerts({required String token}) async {
    final route = activeRoute;
    if (route == null || route.coordinates.isEmpty) {
      _communityAlerts = const [];
      return;
    }

    try {
      _communityAlerts = await CommunityObstacleAlerts.loadForRoute(
        apiService: _reportsApiService,
        accessToken: token,
        coordinates: route.coordinates,
      );
    } catch (_) {
      _communityAlerts = const [];
    }
  }

  Future<void> _handleNearbyAlerts(GeoPoint gpsPoint) async {
    final route = activeRoute;
    if (route == null) {
      if (activeNearbyAlert != null) {
        activeNearbyAlert = null;
        _restoreNavigationNotification();
      }
      return;
    }

    final alerts = [
      ...RouteAlertsResolver.resolve(route),
      ..._communityAlerts,
    ];
    if (alerts.isEmpty) {
      if (activeNearbyAlert != null) {
        activeNearbyAlert = null;
        _restoreNavigationNotification();
      }
      return;
    }

    final previous = activeNearbyAlert;
    final nearby = RouteAlertProximity.nearestForNavigation(
      position: gpsPoint,
      alerts: alerts,
      dismissedIds: _dismissedAlertIds,
      routePolyline: route.coordinates,
    );

    if (nearby?.id == previous?.id) {
      return;
    }

    activeNearbyAlert = nearby;
    if (nearby == null) {
      _restoreNavigationNotification();
      return;
    }

    if (_announcedAlertIds.contains(nearby.id)) {
      return;
    }

    _announcedAlertIds.add(nearby.id);

    _backgroundCoordinator.onRiskAlertUpdated(
      title: NavigationRiskAlertPrompt.notificationTitle(nearby),
      body: NavigationRiskAlertPrompt.notificationBody(nearby),
    );

    if (!_voiceGuidanceEnabled) {
      return;
    }

    final distanceM = RouteAlertProximity.distanceMeters(
      position: gpsPoint,
      alert: nearby,
      routePolyline: route.coordinates,
    );
    final ttsText = NavigationRiskAlertPrompt.buildTts(
      alert: nearby,
      prefix: _riskAlertTtsPrefix,
      distanceM: distanceM,
      distanceFormatter: _alertDistanceFormatter,
    );
    if (ttsText.isEmpty) {
      return;
    }

    await _ttsService.speakRiskAlert(
      text: ttsText,
      alertId: nearby.id,
      highPriority: nearby.severity.toLowerCase() == 'high',
    );
  }

  void _restoreNavigationNotification() {
    final text =
        instruction.trim().isEmpty ? _navigationActiveLabel : instruction.trim();
    _publishInstructionNotification(text);
  }

  void dismissActiveAlert(String alertId) {
    _dismissedAlertIds.add(alertId);
    if (activeNearbyAlert?.id == alertId) {
      activeNearbyAlert = null;
      _restoreNavigationNotification();
    }
    notifyListeners();
  }

  double? _validHeading(double? heading) {
    if (heading == null || heading.isNaN || heading < 0) {
      return null;
    }
    return heading % 360;
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_stopGps());
    _ttsService.dispose();
    super.dispose();
  }
}
