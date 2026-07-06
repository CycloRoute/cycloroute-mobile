// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CycloRoute';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get defaultRoutePreference => 'Default route preference';

  @override
  String get defaultRoutePreferenceHint =>
      'This option is preselected when you compare routes.';

  @override
  String get preferenceUpdated => 'Default route preference updated.';

  @override
  String get couldNotUpdatePreference => 'Could not update preference';

  @override
  String get savedRoutes => 'Saved routes';

  @override
  String get routeHistory => 'Route history';

  @override
  String get reportObstacle => 'Report obstacle';

  @override
  String get collaborativeMap => 'Reviewer map';

  @override
  String get aiRouteCoverage => 'AI route coverage';

  @override
  String get reviewInfrastructure => 'Review infrastructure';

  @override
  String get submitInfrastructureCapture => 'Submit infrastructure capture';

  @override
  String get infrastructureAdminTitle => 'Manage AI infrastructure';

  @override
  String get infrastructureAdminSubtitle =>
      'Review captures submitted by collaborators, approve valid ones to update the routing graph, or reject invalid submissions.';

  @override
  String get infrastructureAdminListTab => 'Queue';

  @override
  String get infrastructureAdminMapTab => 'Map';

  @override
  String get infrastructureEmptyPending => 'No captures waiting for review.';

  @override
  String get infrastructureEmptyActive => 'No active captures on the map.';

  @override
  String get infrastructureEmptyHidden => 'No rejected captures.';

  @override
  String get infrastructureEmptyAll => 'No AI infrastructure captures yet.';

  @override
  String infrastructureSubmittedBy(String name) {
    return 'Submitted by $name';
  }

  @override
  String get couldNotLoadInfrastructure => 'Could not load AI infrastructure';

  @override
  String get infrastructureApproveGraphHint =>
      'Approving updates the routing graph. Rejecting hides the capture without changing the graph.';

  @override
  String get obstacleReports => 'Obstacle reports';

  @override
  String get reviewerTools => 'Reviewer tools';

  @override
  String get accessDenied => 'Access denied';

  @override
  String get insufficientRole => 'You do not have permission for this action.';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get whereTo => 'Where to?';

  @override
  String get origin => 'Origin';

  @override
  String get destination => 'Destination';

  @override
  String get originHint => 'Current location or another place';

  @override
  String get destinationHint => 'Enter a destination';

  @override
  String get searchDestinationHint =>
      'Search recent places or enter a destination';

  @override
  String get recentDestinations => 'Recent destinations';

  @override
  String get recentOrigins => 'Recent starting points';

  @override
  String get recentDestinationsEmpty =>
      'Your recent destinations will appear here.';

  @override
  String get recentOriginsEmpty =>
      'Your recent starting points will appear here.';

  @override
  String get clear => 'Clear';

  @override
  String get seeRouteOptions => 'See route options';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get setLocationOnMap => 'Set location on map';

  @override
  String get currentLocation => 'Current location';

  @override
  String get mapSelectedLocation => 'Selected on map';

  @override
  String get confirmLocation => 'Confirm location';

  @override
  String get dragMapToAdjustPin => 'Drag the map to adjust the pin';

  @override
  String get chooseStartingPoint => 'Choose starting point';

  @override
  String get gpsLocation => 'GPS location';

  @override
  String get nearbyAlerts => 'Nearby alerts';

  @override
  String get checkingArea => 'Checking area';

  @override
  String get liveContext => 'Live context';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInSubtitle => 'Sign in to continue.';

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get sessionExpired => 'Your session expired. Please sign in again.';

  @override
  String get enterEmailAndPassword => 'Please enter both email and password';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get createAccount => 'Create an account';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Add your details to get started.';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account? ';

  @override
  String get agreeToTermsPrefix => 'I agree to the ';

  @override
  String get authEntrySubtitle =>
      'Routes designed for cyclists, with infrastructure you can trust.';

  @override
  String get authFeatureBikeInfra => 'Bike lanes first';

  @override
  String get authFeatureSmartRoutes => '3 route options';

  @override
  String get authFeatureTurnByTurn => 'Turn-by-turn voice';

  @override
  String get homeQuickAccess => 'Quick access';

  @override
  String get homeYourSetup => 'Your setup';

  @override
  String get register => 'Register';

  @override
  String get firstNames => 'First names';

  @override
  String get lastNames => 'Last names';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get agreeToTerms => 'You must agree to the terms and conditions';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get resetYourPassword => 'Reset your password';

  @override
  String get forgotPasswordHint =>
      'Enter your email and we will send a 6-digit code if the account exists.';

  @override
  String get sendResetCode => 'Send reset code';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String get continueButton => 'Continue';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get enterCodeFromEmail => 'Enter the code from your email';

  @override
  String get resetCodeHint =>
      'Check your inbox for the 6-digit code. It expires in 15 minutes.';

  @override
  String get sixDigitCode => '6-digit code';

  @override
  String get newPassword => 'New password';

  @override
  String get updatePassword => 'Update password';

  @override
  String get fillAllFieldsReset => 'Please fill in all fields';

  @override
  String get codeMustBeSixDigits => 'The code must have 6 digits';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get passwordUpdatedSignIn => 'Password updated. Sign in again.';

  @override
  String get resetFailed => 'Reset failed';

  @override
  String get chooseDefaultRoute => 'Choose your default route';

  @override
  String get onboardingRouteHint =>
      'We will preselect this option when you compare routes. You can change it later in Settings.';

  @override
  String onboardingStepLabel(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingFinishSetup => 'Start riding';

  @override
  String get noProfileLoaded => 'No profile loaded';

  @override
  String get editRoutePreference => 'Edit route preference';

  @override
  String get roleCyclist => 'Cyclist';

  @override
  String get roleReviewer => 'Reviewer';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleLabel => 'Role';

  @override
  String get defaultRouteLabel => 'Default route';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get emailLabel => 'Email';

  @override
  String get noSavedRoutes => 'No saved routes yet :(';

  @override
  String get noSavedRoutesHint =>
      'Save a route from results or history to see it here.';

  @override
  String get noRouteHistory => 'No routes in your history yet :(';

  @override
  String get noRouteHistoryHint =>
      'When you finish a ride, it will show up here.';

  @override
  String get pleaseSignInAgain => 'Please sign in again';

  @override
  String get couldNotLoadSavedRoutes => 'Could not load saved routes';

  @override
  String get couldNotLoadRouteHistory => 'Could not load route history';

  @override
  String get routeHistoryDetailTitle => 'Past route';

  @override
  String get routeHistoryMissingPayload =>
      'This past route has no navigation data.';

  @override
  String routeHistoryCompletedAt(String date) {
    return 'Completed on $date';
  }

  @override
  String get manualObstacleReport => 'Report obstacle';

  @override
  String get obstacleReportHint =>
      'Pin the exact spot on the map. Other cyclists get alerts when riding nearby.';

  @override
  String get obstacleCategoryTitle => 'Obstacle type';

  @override
  String get obstacleSeverityTitle => 'Severity';

  @override
  String get obstacleCategoryBlockedLane => 'Blocked bike lane';

  @override
  String get obstacleCategoryConstruction => 'Construction or closure';

  @override
  String get obstacleCategorySurfaceDamage => 'Damaged pavement';

  @override
  String get obstacleCategoryDebris => 'Debris on road';

  @override
  String get obstacleCategoryOther => 'Other';

  @override
  String get obstacleSeverityLow => 'Low';

  @override
  String get obstacleSeverityMedium => 'Medium';

  @override
  String get obstacleSeverityHigh => 'High';

  @override
  String get pinObstacleLocation => 'Obstacle location';

  @override
  String get adjustPinOnMap => 'Move the map to place the pin accurately';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get myObstacleReports => 'My reports';

  @override
  String get noMyReportsYet => 'You have not reported any obstacles yet';

  @override
  String get noMyReportsHint =>
      'Your reports help warn other cyclists in the area.';

  @override
  String get communityReportThanks =>
      'Thanks. Other cyclists will be alerted near this spot.';

  @override
  String get reportFromNavigation => 'Report here';

  @override
  String get description => 'Description';

  @override
  String get obstacleDescriptionHint => 'Vehicle blocking bike lane...';

  @override
  String get relatedRouteType => 'Related route type';

  @override
  String get describeObstacle => 'Please describe the obstacle';

  @override
  String get waitingForGps => 'Waiting for GPS location';

  @override
  String get obstacleSubmitted => 'Obstacle report submitted.';

  @override
  String get couldNotSubmitReport => 'Could not submit report';

  @override
  String get submitReport => 'Submit report';

  @override
  String get noReportsYet => 'No obstacle reports yet :(';

  @override
  String get couldNotLoadReports => 'Could not load reports';

  @override
  String get couldNotLoadCollaborativeMap => 'Could not load reviewer map';

  @override
  String get couldNotLoadCoverage => 'Could not load coverage';

  @override
  String get captureInfrastructure => 'Capture street infrastructure';

  @override
  String get reviewerCaptureHint =>
      'Your photo and GPS help improve the collaborative map for all cyclists.';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get takePhotoFirst => 'Take or choose a photo first';

  @override
  String get analyzeAndSubmit => 'Analyze and submit';

  @override
  String get reportImprovedMap => 'Your report improved the map for everyone.';

  @override
  String graphEdgesUpdated(int count) {
    return 'Graph edges updated: $count';
  }

  @override
  String get detections => 'Detections';

  @override
  String get engineDiagnostics => 'Engine diagnostics';

  @override
  String get reviewerToolsHint =>
      'Only reviewers and admins can access these endpoints.';

  @override
  String get couldNotLoadEngineHealth => 'Could not load engine health';

  @override
  String get gpsRequiredForDebug => 'GPS location required for debug route';

  @override
  String get couldNotRunRouteDebug => 'Could not run route debug';

  @override
  String get engineHealth => 'Engine health';

  @override
  String get routeDebug => 'Route debug';

  @override
  String get routePrefRecommended => 'Recommended with bike lanes';

  @override
  String get routePrefRecommendedDesc =>
      'Prioritizes bike lanes and cycling infrastructure.';

  @override
  String get routePrefBalanced => 'Balanced route';

  @override
  String get routePrefBalancedDesc =>
      'Balances distance, comfort, and bike infrastructure.';

  @override
  String get routePrefShorter => 'Fastest / shortest';

  @override
  String get routePrefShorterDesc =>
      'Shortest route with less bike-lane priority.';

  @override
  String get planningPreferencesTitle => 'How should we recommend routes?';

  @override
  String get planningRouteTypeHint => 'Choose the style that fits you best.';

  @override
  String get myBike => 'My bike';

  @override
  String get myBikeHint =>
      'We adjust travel time and which paths suit your ride.';

  @override
  String get bikeProfileUrban => 'City bike';

  @override
  String get bikeProfileUrbanDesc => 'Paved streets and everyday city riding.';

  @override
  String get bikeProfileMtb => 'Mountain / gravel';

  @override
  String get bikeProfileMtbDesc =>
      'Comfortable on dirt paths and mixed surfaces.';

  @override
  String get bikeProfileElectric => 'E-bike';

  @override
  String get bikeProfileElectricDesc =>
      'Faster pace with less effort on hills.';

  @override
  String get bikeProfileUpdated => 'Bike preference saved.';

  @override
  String get navigationSettingsTitle => 'During navigation';

  @override
  String get voiceGuidance => 'Voice guidance';

  @override
  String get voiceGuidanceHint =>
      'Spoken turn-by-turn instructions while you ride.';

  @override
  String get voiceLanguage => 'Voice language';

  @override
  String get voiceLanguageSameAsApp => 'Same as app';

  @override
  String get distanceUnits => 'Units';

  @override
  String get distanceUnitsHint =>
      'Distances in routes, navigation, and voice guidance.';

  @override
  String get distanceUnitsKilometers => 'Kilometers';

  @override
  String get distanceUnitsMiles => 'Miles';

  @override
  String inFeet(int feet) {
    return 'In $feet ft';
  }

  @override
  String inMilesDistance(String miles) {
    return 'In $miles mi';
  }

  @override
  String routeDistanceKm(String kilometers) {
    return '$kilometers km';
  }

  @override
  String routeDistanceMi(String miles) {
    return '$miles mi';
  }

  @override
  String ttsInFeet(int feet) {
    return 'In $feet feet';
  }

  @override
  String get serviceUnavailable =>
      'Service unavailable. Please try again later.';

  @override
  String get couldNotConnectApi => 'Could not connect to CycloRoute API';

  @override
  String get requestFailed => 'Something went wrong. Please try again.';

  @override
  String get tooManyRequests => 'Too many requests. Please wait a moment.';

  @override
  String get invalidOrExpiredResetCode => 'Invalid or expired reset code';

  @override
  String get couldNotSaveRoute => 'Could not save this route.';

  @override
  String get pleaseSignInAgainToSaveRoute =>
      'Please sign in again to save this route.';

  @override
  String get couldNotSearchPlaces => 'Could not search places right now.';

  @override
  String get couldNotUploadAnalysis => 'Could not upload analysis';

  @override
  String get routeSavedSuccessfully => 'Route saved successfully.';

  @override
  String get savedRouteDetailTitle => 'Saved route';

  @override
  String get renameSavedRoute => 'Rename route';

  @override
  String get renameSavedRouteHint => 'Route name';

  @override
  String get savedRouteRenamed => 'Route renamed.';

  @override
  String get couldNotRenameSavedRoute => 'Could not rename this route.';

  @override
  String get deleteSavedRoute => 'Delete route';

  @override
  String deleteSavedRouteConfirm(String name) {
    return 'Remove \"$name\" from your saved routes?';
  }

  @override
  String get savedRouteDeleted => 'Route deleted.';

  @override
  String get couldNotDeleteSavedRoute => 'Could not delete this route.';

  @override
  String get savedRouteMissingPayload =>
      'This saved route has no navigation data.';

  @override
  String get noRouteOptionsFound =>
      'No route options were found for those places.';

  @override
  String get chooseOriginWithCoordinates =>
      'Choose an origin with coordinates.';

  @override
  String get chooseDestinationFromSuggestions =>
      'Choose a destination from the suggestions.';

  @override
  String get pleaseSignInToCalculateRoutes =>
      'Please sign in again to calculate routes.';

  @override
  String get locatingYou => 'Locating you';

  @override
  String get locatingYouSubtitle =>
      'Getting your current position to prepare nearby guidance.';

  @override
  String get readyForRouteSearch => 'Ready for route search';

  @override
  String get readyForRouteSearchSubtitle =>
      'Choose a destination and CycloRoute will compare options.';

  @override
  String get routePlanning => 'Route planning';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get needsPermission => 'Needs permission';

  @override
  String get locationPermissionTitle => 'Location access';

  @override
  String get locationPermissionRationale =>
      'CycloRoute uses your location while you use the app to show your position on the map, suggest routes from where you are, and guide you during navigation.';

  @override
  String get locationPermissionDeniedTitle => 'Location still off';

  @override
  String get locationPermissionDeniedMessage =>
      'Without location access you can still search routes manually, but navigation and your position on the map will not work.';

  @override
  String get locationPermissionDeniedForeverTitle =>
      'Enable location in Settings';

  @override
  String get locationPermissionDeniedForeverMessage =>
      'Location permission was blocked. Open app settings and allow location while using the app.';

  @override
  String get locationServiceDisabledTitle => 'Turn on location services';

  @override
  String get locationServiceDisabledMessage =>
      'Your device location is turned off. Enable GPS/location services to use maps and navigation.';

  @override
  String get openAppSettings => 'Open settings';

  @override
  String get openLocationSettings => 'Open location settings';

  @override
  String get enableLocation => 'Enable location';

  @override
  String get locationRequiredForNavigation =>
      'Location access is required to start navigation.';

  @override
  String get searchStillWorks => 'Search still works';

  @override
  String get searchStillWorksSubtitle =>
      'You can type an origin manually if GPS is not available.';

  @override
  String get manualOrigin => 'Manual origin';

  @override
  String get currentPositionReady => 'Current position ready';

  @override
  String get gpsLocked => 'GPS locked';

  @override
  String aboutMeters(int meters) {
    return 'About $meters m';
  }

  @override
  String get youAreMoving => 'You are moving';

  @override
  String get planBeforeRiding => 'Plan before riding';

  @override
  String get keepMapVisible =>
      'Keep the map visible and start navigation only when you\'re ready to ride.';

  @override
  String get searchDestinationCompare =>
      'Search a destination to compare distance and bike infrastructure.';

  @override
  String get standingBy => 'Standing by';

  @override
  String get directionPending => 'Direction pending';

  @override
  String get directionDetected => 'Direction detected';

  @override
  String get headingHelp =>
      'Your heading can help align navigation when a route starts.';

  @override
  String get startMovingCompass => 'Start moving for live GPS updates.';

  @override
  String get bikeInfrastructure => 'Bike infra';

  @override
  String percentBikeInfra(int value) {
    return '$value% bike lanes';
  }

  @override
  String get routeInfraHigh => 'Strong bike lanes';

  @override
  String get routeInfraMedium => 'Mixed infrastructure';

  @override
  String get routeInfraLow => 'Limited bike lanes';

  @override
  String get homeBikeInfraFocus => 'Bike infrastructure';

  @override
  String degrees(int value) {
    return '$value deg';
  }

  @override
  String get navigationTitle => 'Navigating';

  @override
  String get navigationSessionMissing =>
      'Navigation could not start. Choose a route and try again.';

  @override
  String get startNavigation => 'Start navigation';

  @override
  String get couldNotStartNavigation => 'Could not start navigation.';

  @override
  String get recalculatingRoute => 'Recalculating route...';

  @override
  String get routeUpdated => 'Route updated';

  @override
  String get offRoute => 'Off route';

  @override
  String get noTurnByTurnSteps =>
      'Turn-by-turn steps are not available for this route.';

  @override
  String get endRouteTitle => 'End route?';

  @override
  String get endRouteMessage =>
      'Your route is still in progress. End navigation now?';

  @override
  String get endRoute => 'End route';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get arrivedTitle => 'You have arrived';

  @override
  String get arrivedMessage => 'Navigation completed.';

  @override
  String navigatingTo(String destination) {
    return 'Navigating to $destination';
  }

  @override
  String inMeters(int meters) {
    return 'In $meters m';
  }

  @override
  String ttsInMeters(int meters) {
    return 'In $meters meters';
  }

  @override
  String get distance => 'Distance';

  @override
  String get time => 'Time';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String estimatedArrivalTime(String time) {
    return 'Arrive ~$time';
  }

  @override
  String get resumeNavigationTitle => 'Resume navigation?';

  @override
  String resumeNavigationMessage(String destination) {
    return 'You have an active route to $destination.';
  }

  @override
  String get resumeNavigation => 'Resume';

  @override
  String get notNow => 'Not now';

  @override
  String get activeNavigationTitle => 'Navigation in progress';

  @override
  String get activeNavigationTapHint => 'Tap to return to the map';

  @override
  String get navigationNotificationActive => 'Navigation active';

  @override
  String get navigationBackgroundPermissionTitle =>
      'Background location for navigation';

  @override
  String get navigationBackgroundPermissionMessage =>
      'To keep guiding you with the screen off or while using other apps, CycloRoute needs location access in the background during navigation.';

  @override
  String get allowBackgroundLocation => 'Allow in background';

  @override
  String get continueWithLimitedLocation => 'Continue with limited access';

  @override
  String get navigationBackgroundSettingsTitle => 'Enable background location';

  @override
  String get navigationBackgroundSettingsMessageAndroid =>
      'Choose \"Allow all the time\" in app settings so navigation continues when the screen is off.';

  @override
  String get navigationBackgroundSettingsMessageIos =>
      'In Settings, open Location and choose \"Always\" so navigation continues when the screen is locked.';

  @override
  String get navigationLimitedLocationWarning =>
      'Location is limited to while using the app. Guidance may pause when the screen is off.';

  @override
  String get routeOptionsTitle => 'Route options';

  @override
  String routesTo(String destination) {
    return 'Routes to $destination';
  }

  @override
  String get chooseYourRoute => 'Choose your route';

  @override
  String get pickRouteThatFits => 'Pick the route that fits your ride.';

  @override
  String startingFrom(String origin) {
    return 'Starting from $origin.';
  }

  @override
  String get reviewRouteOnMap =>
      'Review the route on the map and compare bike infrastructure.';

  @override
  String get infraComparisonTitle => 'Compare routes';

  @override
  String get infraComparisonHint =>
      'Tap a column to select a route. Highlighted values are best in each row.';

  @override
  String get comparisonMetric => 'Metric';

  @override
  String get cycloScoreLabel => 'Cyclo score';

  @override
  String get selectedRouteSummary => 'Selected route';

  @override
  String get saveRoute => 'Save route';

  @override
  String get noRouteOptionsLoaded => 'No route options were loaded.';

  @override
  String get currentSegmentTitle => 'On this segment';

  @override
  String get conditionGood => 'Good';

  @override
  String get conditionRegular => 'Regular';

  @override
  String get conditionPoor => 'Poor';

  @override
  String get riskLow => 'Low risk';

  @override
  String get riskMedium => 'Medium risk';

  @override
  String get riskHigh => 'High risk';

  @override
  String get infraCycleway => 'Cycleway';

  @override
  String get infraProtectedLane => 'Protected lane';

  @override
  String get infraSharedLane => 'Shared lane';

  @override
  String get infraBikeLane => 'Bike lane';

  @override
  String get infraLivingStreet => 'Living street';

  @override
  String get infraResidential => 'Residential';

  @override
  String get infraPrimary => 'Primary road';

  @override
  String get infraUnknown => 'Unknown infrastructure';

  @override
  String get dismissAlert => 'Dismiss';

  @override
  String get riskAlertTtsPrefix => 'Route alert';

  @override
  String get routeDetailTitle => 'Route details';

  @override
  String get turnByTurnTitle => 'Turn-by-turn directions';

  @override
  String get routeSegmentsTitle => 'Route segments';

  @override
  String get alertsAlongRouteTitle => 'Alerts along route';

  @override
  String get noRouteSegments =>
      'No detailed segments are available for this route.';

  @override
  String get noRouteAlertsOnRoute => 'No alerts on this route.';

  @override
  String get segmentTableInfra => 'Infrastructure';

  @override
  String get segmentTableScore => 'Score';

  @override
  String get segmentTableCondition => 'Condition';

  @override
  String showAllSteps(int count) {
    return 'Show all ($count)';
  }

  @override
  String get showFewerSteps => 'Show fewer';

  @override
  String get reviewerMap => 'Reviewer map';

  @override
  String get mapLayerObstacles => 'Obstacles';

  @override
  String get mapLayerInfrastructure => 'Infrastructure';

  @override
  String get mapLayerCoverage => 'Graph coverage';

  @override
  String get moderationApprove => 'Approve';

  @override
  String get moderationReject => 'Reject / Hide';

  @override
  String get moderationPending => 'Pending';

  @override
  String get reportAwaitingReview => 'Awaiting review';

  @override
  String get communityReportPendingMessage =>
      'Thanks. Your report is pending review before it appears on the map.';

  @override
  String get moderationActive => 'Active';

  @override
  String get moderationHidden => 'Rejected';

  @override
  String get moderationAll => 'All';

  @override
  String get editReport => 'Edit';

  @override
  String get deleteReport => 'Delete';

  @override
  String get confirmDeleteReport => 'Delete this obstacle report?';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get couldNotUpdateReport => 'Could not update report';

  @override
  String get obstacleTimeRemaining => 'Time remaining';

  @override
  String get obstacleVisibleUntilLabel => 'Visible until';

  @override
  String obstacleVisibleUntil(String date) {
    return 'Visible until $date';
  }

  @override
  String get obstacleNoExpiry => 'No expiry date';

  @override
  String get obstacleExpired => 'Expired';

  @override
  String obstacleTimeRemainingDays(int days) {
    return '$days days left';
  }

  @override
  String obstacleTimeRemainingHours(int hours) {
    return '$hours hours left';
  }

  @override
  String obstacleTimeRemainingMinutes(int minutes) {
    return '$minutes minutes left';
  }

  @override
  String get obstacleReportedAt => 'Reported';

  @override
  String get obstacleAuthor => 'Author';

  @override
  String get obstacleActiveDuration => 'Days visible on map';

  @override
  String get analysisResultTitle => 'Analysis result';

  @override
  String get analysisResultSubtitle =>
      'The AI reviewed your photo and updated the cycling map near this location.';

  @override
  String get analysisResultScoreLabel => 'of 100';

  @override
  String get qualityGoodTitle => 'Good infrastructure';

  @override
  String get qualityGoodDescription =>
      'The area looks safe and comfortable for cycling. Nearby routes will favor this segment.';

  @override
  String get qualityRegularTitle => 'Fair infrastructure';

  @override
  String get qualityRegularDescription =>
      'Some elements could be improved. The score was blended into nearby routes with moderate weight.';

  @override
  String get qualityBadTitle => 'Poor infrastructure';

  @override
  String get qualityBadDescription =>
      'The scene shows risks for cyclists (traffic, obstacles, or missing bike infrastructure). Nearby routes were penalized to protect riders.';

  @override
  String get graphImpactTitle => 'Map and routing impact';

  @override
  String get graphImpactDescription =>
      'The engine adjusted street graph edges around your GPS point so future route suggestions reflect what was detected.';

  @override
  String get graphImpactPendingDescription =>
      'The analysis is saved as pending. The graph will only be updated after an admin approves this capture.';

  @override
  String get graphUpdatePendingApproval =>
      'Pending approval — graph not updated yet';

  @override
  String graphEdgesWouldUpdate(int count) {
    return 'Estimated edges on approval: $count';
  }

  @override
  String get infrastructurePendingReviewTitle => 'Awaiting reviewer approval';

  @override
  String get infrastructurePendingReviewBody =>
      'Your capture was analyzed successfully. It will appear on the reviewer map and affect routing only after an admin approves it.';

  @override
  String get infrastructureAdminApproveOnly =>
      'Only an admin can approve this capture and update the routing graph. You can still reject invalid submissions.';

  @override
  String get reportSubmittedForReview =>
      'Submitted for review. The map and routes will update once an admin approves it.';

  @override
  String graphRadiusDetail(int meters) {
    return 'Influence radius: $meters m';
  }

  @override
  String get graphUpdateApplied => 'Graph update applied successfully';

  @override
  String get graphUpdateNotApplied =>
      'Graph update could not be applied (no nearby edges)';

  @override
  String get detectionsSubtitle =>
      'Objects detected by the vision model in your photo:';

  @override
  String get acceptAndGoHome => 'Accept';
}
