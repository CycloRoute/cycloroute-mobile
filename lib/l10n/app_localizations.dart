import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'CycloRoute'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @defaultRoutePreference.
  ///
  /// In en, this message translates to:
  /// **'Default route preference'**
  String get defaultRoutePreference;

  /// No description provided for @defaultRoutePreferenceHint.
  ///
  /// In en, this message translates to:
  /// **'This option is preselected when you compare routes.'**
  String get defaultRoutePreferenceHint;

  /// No description provided for @preferenceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Default route preference updated.'**
  String get preferenceUpdated;

  /// No description provided for @couldNotUpdatePreference.
  ///
  /// In en, this message translates to:
  /// **'Could not update preference'**
  String get couldNotUpdatePreference;

  /// No description provided for @savedRoutes.
  ///
  /// In en, this message translates to:
  /// **'Saved routes'**
  String get savedRoutes;

  /// No description provided for @routeHistory.
  ///
  /// In en, this message translates to:
  /// **'Route history'**
  String get routeHistory;

  /// No description provided for @reportObstacle.
  ///
  /// In en, this message translates to:
  /// **'Report obstacle'**
  String get reportObstacle;

  /// No description provided for @collaborativeMap.
  ///
  /// In en, this message translates to:
  /// **'Reviewer map'**
  String get collaborativeMap;

  /// No description provided for @aiRouteCoverage.
  ///
  /// In en, this message translates to:
  /// **'AI route coverage'**
  String get aiRouteCoverage;

  /// No description provided for @reviewInfrastructure.
  ///
  /// In en, this message translates to:
  /// **'Review infrastructure'**
  String get reviewInfrastructure;

  /// No description provided for @submitInfrastructureCapture.
  ///
  /// In en, this message translates to:
  /// **'Submit infrastructure capture'**
  String get submitInfrastructureCapture;

  /// No description provided for @infrastructureAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage AI infrastructure'**
  String get infrastructureAdminTitle;

  /// No description provided for @infrastructureAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review captures submitted by collaborators, approve valid ones to update the routing graph, or reject invalid submissions.'**
  String get infrastructureAdminSubtitle;

  /// No description provided for @infrastructureAdminListTab.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get infrastructureAdminListTab;

  /// No description provided for @infrastructureAdminMapTab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get infrastructureAdminMapTab;

  /// No description provided for @infrastructureEmptyPending.
  ///
  /// In en, this message translates to:
  /// **'No captures waiting for review.'**
  String get infrastructureEmptyPending;

  /// No description provided for @infrastructureEmptyActive.
  ///
  /// In en, this message translates to:
  /// **'No active captures on the map.'**
  String get infrastructureEmptyActive;

  /// No description provided for @infrastructureEmptyHidden.
  ///
  /// In en, this message translates to:
  /// **'No rejected captures.'**
  String get infrastructureEmptyHidden;

  /// No description provided for @infrastructureEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'No AI infrastructure captures yet.'**
  String get infrastructureEmptyAll;

  /// No description provided for @infrastructureSubmittedBy.
  ///
  /// In en, this message translates to:
  /// **'Submitted by {name}'**
  String infrastructureSubmittedBy(String name);

  /// No description provided for @couldNotLoadInfrastructure.
  ///
  /// In en, this message translates to:
  /// **'Could not load AI infrastructure'**
  String get couldNotLoadInfrastructure;

  /// No description provided for @infrastructureApproveGraphHint.
  ///
  /// In en, this message translates to:
  /// **'Approving updates the routing graph. Rejecting hides the capture without changing the graph.'**
  String get infrastructureApproveGraphHint;

  /// No description provided for @obstacleReports.
  ///
  /// In en, this message translates to:
  /// **'Obstacle reports'**
  String get obstacleReports;

  /// No description provided for @reviewerTools.
  ///
  /// In en, this message translates to:
  /// **'Reviewer tools'**
  String get reviewerTools;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get accessDenied;

  /// No description provided for @insufficientRole.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get insufficientRole;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeUser(String name);

  /// No description provided for @whereTo.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereTo;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @originHint.
  ///
  /// In en, this message translates to:
  /// **'Current location or another place'**
  String get originHint;

  /// No description provided for @destinationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a destination'**
  String get destinationHint;

  /// No description provided for @searchDestinationHint.
  ///
  /// In en, this message translates to:
  /// **'Search recent places or enter a destination'**
  String get searchDestinationHint;

  /// No description provided for @recentDestinations.
  ///
  /// In en, this message translates to:
  /// **'Recent destinations'**
  String get recentDestinations;

  /// No description provided for @recentOrigins.
  ///
  /// In en, this message translates to:
  /// **'Recent starting points'**
  String get recentOrigins;

  /// No description provided for @recentDestinationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your recent destinations will appear here.'**
  String get recentDestinationsEmpty;

  /// No description provided for @recentOriginsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your recent starting points will appear here.'**
  String get recentOriginsEmpty;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @seeRouteOptions.
  ///
  /// In en, this message translates to:
  /// **'See route options'**
  String get seeRouteOptions;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @setLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Set location on map'**
  String get setLocationOnMap;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @mapSelectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected on map'**
  String get mapSelectedLocation;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get confirmLocation;

  /// No description provided for @dragMapToAdjustPin.
  ///
  /// In en, this message translates to:
  /// **'Drag the map to adjust the pin'**
  String get dragMapToAdjustPin;

  /// No description provided for @chooseStartingPoint.
  ///
  /// In en, this message translates to:
  /// **'Choose starting point'**
  String get chooseStartingPoint;

  /// No description provided for @gpsLocation.
  ///
  /// In en, this message translates to:
  /// **'GPS location'**
  String get gpsLocation;

  /// No description provided for @nearbyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Nearby alerts'**
  String get nearbyAlerts;

  /// No description provided for @checkingArea.
  ///
  /// In en, this message translates to:
  /// **'Checking area'**
  String get checkingArea;

  /// No description provided for @liveContext.
  ///
  /// In en, this message translates to:
  /// **'Live context'**
  String get liveContext;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue.'**
  String get signInSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @enterEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password'**
  String get enterEmailAndPassword;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your details to get started.'**
  String get registerSubtitle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @agreeToTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreeToTermsPrefix;

  /// No description provided for @authEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Routes designed for cyclists, with infrastructure you can trust.'**
  String get authEntrySubtitle;

  /// No description provided for @authFeatureBikeInfra.
  ///
  /// In en, this message translates to:
  /// **'Bike lanes first'**
  String get authFeatureBikeInfra;

  /// No description provided for @authFeatureSmartRoutes.
  ///
  /// In en, this message translates to:
  /// **'3 route options'**
  String get authFeatureSmartRoutes;

  /// No description provided for @authFeatureTurnByTurn.
  ///
  /// In en, this message translates to:
  /// **'Turn-by-turn voice'**
  String get authFeatureTurnByTurn;

  /// No description provided for @homeQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get homeQuickAccess;

  /// No description provided for @homeYourSetup.
  ///
  /// In en, this message translates to:
  /// **'Your setup'**
  String get homeYourSetup;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @firstNames.
  ///
  /// In en, this message translates to:
  /// **'First names'**
  String get firstNames;

  /// No description provided for @lastNames.
  ///
  /// In en, this message translates to:
  /// **'Last names'**
  String get lastNames;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the terms and conditions'**
  String get agreeToTerms;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPassword;

  /// No description provided for @forgotPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send a 6-digit code if the account exists.'**
  String get forgotPasswordHint;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send reset code'**
  String get sendResetCode;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @enterCodeFromEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your email'**
  String get enterCodeFromEmail;

  /// No description provided for @resetCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for the 6-digit code. It expires in 15 minutes.'**
  String get resetCodeHint;

  /// No description provided for @sixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get sixDigitCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @fillAllFieldsReset.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFieldsReset;

  /// No description provided for @codeMustBeSixDigits.
  ///
  /// In en, this message translates to:
  /// **'The code must have 6 digits'**
  String get codeMustBeSixDigits;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordUpdatedSignIn.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Sign in again.'**
  String get passwordUpdatedSignIn;

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'Reset failed'**
  String get resetFailed;

  /// No description provided for @chooseDefaultRoute.
  ///
  /// In en, this message translates to:
  /// **'Choose your default route'**
  String get chooseDefaultRoute;

  /// No description provided for @onboardingRouteHint.
  ///
  /// In en, this message translates to:
  /// **'We will preselect this option when you compare routes. You can change it later in Settings.'**
  String get onboardingRouteHint;

  /// No description provided for @onboardingStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepLabel(int current, int total);

  /// No description provided for @onboardingFinishSetup.
  ///
  /// In en, this message translates to:
  /// **'Start riding'**
  String get onboardingFinishSetup;

  /// No description provided for @noProfileLoaded.
  ///
  /// In en, this message translates to:
  /// **'No profile loaded'**
  String get noProfileLoaded;

  /// No description provided for @editRoutePreference.
  ///
  /// In en, this message translates to:
  /// **'Edit route preference'**
  String get editRoutePreference;

  /// No description provided for @roleCyclist.
  ///
  /// In en, this message translates to:
  /// **'Cyclist'**
  String get roleCyclist;

  /// No description provided for @roleReviewer.
  ///
  /// In en, this message translates to:
  /// **'Reviewer'**
  String get roleReviewer;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @defaultRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Default route'**
  String get defaultRouteLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @noSavedRoutes.
  ///
  /// In en, this message translates to:
  /// **'No saved routes yet :('**
  String get noSavedRoutes;

  /// No description provided for @noSavedRoutesHint.
  ///
  /// In en, this message translates to:
  /// **'Save a route from results or history to see it here.'**
  String get noSavedRoutesHint;

  /// No description provided for @noRouteHistory.
  ///
  /// In en, this message translates to:
  /// **'No routes in your history yet :('**
  String get noRouteHistory;

  /// No description provided for @noRouteHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'When you finish a ride, it will show up here.'**
  String get noRouteHistoryHint;

  /// No description provided for @pleaseSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again'**
  String get pleaseSignInAgain;

  /// No description provided for @couldNotLoadSavedRoutes.
  ///
  /// In en, this message translates to:
  /// **'Could not load saved routes'**
  String get couldNotLoadSavedRoutes;

  /// No description provided for @couldNotLoadRouteHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load route history'**
  String get couldNotLoadRouteHistory;

  /// No description provided for @routeHistoryDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Past route'**
  String get routeHistoryDetailTitle;

  /// No description provided for @routeHistoryMissingPayload.
  ///
  /// In en, this message translates to:
  /// **'This past route has no navigation data.'**
  String get routeHistoryMissingPayload;

  /// No description provided for @routeHistoryCompletedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed on {date}'**
  String routeHistoryCompletedAt(String date);

  /// No description provided for @manualObstacleReport.
  ///
  /// In en, this message translates to:
  /// **'Report obstacle'**
  String get manualObstacleReport;

  /// No description provided for @obstacleReportHint.
  ///
  /// In en, this message translates to:
  /// **'Pin the exact spot on the map. Other cyclists get alerts when riding nearby.'**
  String get obstacleReportHint;

  /// No description provided for @obstacleCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Obstacle type'**
  String get obstacleCategoryTitle;

  /// No description provided for @obstacleSeverityTitle.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get obstacleSeverityTitle;

  /// No description provided for @obstacleCategoryBlockedLane.
  ///
  /// In en, this message translates to:
  /// **'Blocked bike lane'**
  String get obstacleCategoryBlockedLane;

  /// No description provided for @obstacleCategoryConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction or closure'**
  String get obstacleCategoryConstruction;

  /// No description provided for @obstacleCategorySurfaceDamage.
  ///
  /// In en, this message translates to:
  /// **'Damaged pavement'**
  String get obstacleCategorySurfaceDamage;

  /// No description provided for @obstacleCategoryDebris.
  ///
  /// In en, this message translates to:
  /// **'Debris on road'**
  String get obstacleCategoryDebris;

  /// No description provided for @obstacleCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get obstacleCategoryOther;

  /// No description provided for @obstacleSeverityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get obstacleSeverityLow;

  /// No description provided for @obstacleSeverityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get obstacleSeverityMedium;

  /// No description provided for @obstacleSeverityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get obstacleSeverityHigh;

  /// No description provided for @pinObstacleLocation.
  ///
  /// In en, this message translates to:
  /// **'Obstacle location'**
  String get pinObstacleLocation;

  /// No description provided for @adjustPinOnMap.
  ///
  /// In en, this message translates to:
  /// **'Move the map to place the pin accurately'**
  String get adjustPinOnMap;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @myObstacleReports.
  ///
  /// In en, this message translates to:
  /// **'My reports'**
  String get myObstacleReports;

  /// No description provided for @noMyReportsYet.
  ///
  /// In en, this message translates to:
  /// **'You have not reported any obstacles yet'**
  String get noMyReportsYet;

  /// No description provided for @noMyReportsHint.
  ///
  /// In en, this message translates to:
  /// **'Your reports help warn other cyclists in the area.'**
  String get noMyReportsHint;

  /// No description provided for @communityReportThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks. Other cyclists will be alerted near this spot.'**
  String get communityReportThanks;

  /// No description provided for @reportFromNavigation.
  ///
  /// In en, this message translates to:
  /// **'Report here'**
  String get reportFromNavigation;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @obstacleDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Vehicle blocking bike lane...'**
  String get obstacleDescriptionHint;

  /// No description provided for @relatedRouteType.
  ///
  /// In en, this message translates to:
  /// **'Related route type'**
  String get relatedRouteType;

  /// No description provided for @describeObstacle.
  ///
  /// In en, this message translates to:
  /// **'Please describe the obstacle'**
  String get describeObstacle;

  /// No description provided for @waitingForGps.
  ///
  /// In en, this message translates to:
  /// **'Waiting for GPS location'**
  String get waitingForGps;

  /// No description provided for @obstacleSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Obstacle report submitted.'**
  String get obstacleSubmitted;

  /// No description provided for @couldNotSubmitReport.
  ///
  /// In en, this message translates to:
  /// **'Could not submit report'**
  String get couldNotSubmitReport;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get submitReport;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No obstacle reports yet :('**
  String get noReportsYet;

  /// No description provided for @couldNotLoadReports.
  ///
  /// In en, this message translates to:
  /// **'Could not load reports'**
  String get couldNotLoadReports;

  /// No description provided for @couldNotLoadCollaborativeMap.
  ///
  /// In en, this message translates to:
  /// **'Could not load reviewer map'**
  String get couldNotLoadCollaborativeMap;

  /// No description provided for @couldNotLoadCoverage.
  ///
  /// In en, this message translates to:
  /// **'Could not load coverage'**
  String get couldNotLoadCoverage;

  /// No description provided for @captureInfrastructure.
  ///
  /// In en, this message translates to:
  /// **'Capture street infrastructure'**
  String get captureInfrastructure;

  /// No description provided for @reviewerCaptureHint.
  ///
  /// In en, this message translates to:
  /// **'Your photo and GPS help improve the collaborative map for all cyclists.'**
  String get reviewerCaptureHint;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @takePhotoFirst.
  ///
  /// In en, this message translates to:
  /// **'Take or choose a photo first'**
  String get takePhotoFirst;

  /// No description provided for @analyzeAndSubmit.
  ///
  /// In en, this message translates to:
  /// **'Analyze and submit'**
  String get analyzeAndSubmit;

  /// No description provided for @reportImprovedMap.
  ///
  /// In en, this message translates to:
  /// **'Your report improved the map for everyone.'**
  String get reportImprovedMap;

  /// No description provided for @graphEdgesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Graph edges updated: {count}'**
  String graphEdgesUpdated(int count);

  /// No description provided for @detections.
  ///
  /// In en, this message translates to:
  /// **'Detections'**
  String get detections;

  /// No description provided for @engineDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Engine diagnostics'**
  String get engineDiagnostics;

  /// No description provided for @reviewerToolsHint.
  ///
  /// In en, this message translates to:
  /// **'Only reviewers and admins can access these endpoints.'**
  String get reviewerToolsHint;

  /// No description provided for @couldNotLoadEngineHealth.
  ///
  /// In en, this message translates to:
  /// **'Could not load engine health'**
  String get couldNotLoadEngineHealth;

  /// No description provided for @gpsRequiredForDebug.
  ///
  /// In en, this message translates to:
  /// **'GPS location required for debug route'**
  String get gpsRequiredForDebug;

  /// No description provided for @couldNotRunRouteDebug.
  ///
  /// In en, this message translates to:
  /// **'Could not run route debug'**
  String get couldNotRunRouteDebug;

  /// No description provided for @engineHealth.
  ///
  /// In en, this message translates to:
  /// **'Engine health'**
  String get engineHealth;

  /// No description provided for @routeDebug.
  ///
  /// In en, this message translates to:
  /// **'Route debug'**
  String get routeDebug;

  /// No description provided for @routePrefRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended with bike lanes'**
  String get routePrefRecommended;

  /// No description provided for @routePrefRecommendedDesc.
  ///
  /// In en, this message translates to:
  /// **'Prioritizes bike lanes and cycling infrastructure.'**
  String get routePrefRecommendedDesc;

  /// No description provided for @routePrefBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced route'**
  String get routePrefBalanced;

  /// No description provided for @routePrefBalancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Balances distance, comfort, and bike infrastructure.'**
  String get routePrefBalancedDesc;

  /// No description provided for @routePrefShorter.
  ///
  /// In en, this message translates to:
  /// **'Fastest / shortest'**
  String get routePrefShorter;

  /// No description provided for @routePrefShorterDesc.
  ///
  /// In en, this message translates to:
  /// **'Shortest route with less bike-lane priority.'**
  String get routePrefShorterDesc;

  /// No description provided for @planningPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'How should we recommend routes?'**
  String get planningPreferencesTitle;

  /// No description provided for @planningRouteTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the style that fits you best.'**
  String get planningRouteTypeHint;

  /// No description provided for @myBike.
  ///
  /// In en, this message translates to:
  /// **'My bike'**
  String get myBike;

  /// No description provided for @myBikeHint.
  ///
  /// In en, this message translates to:
  /// **'We adjust travel time and which paths suit your ride.'**
  String get myBikeHint;

  /// No description provided for @bikeProfileUrban.
  ///
  /// In en, this message translates to:
  /// **'City bike'**
  String get bikeProfileUrban;

  /// No description provided for @bikeProfileUrbanDesc.
  ///
  /// In en, this message translates to:
  /// **'Paved streets and everyday city riding.'**
  String get bikeProfileUrbanDesc;

  /// No description provided for @bikeProfileMtb.
  ///
  /// In en, this message translates to:
  /// **'Mountain / gravel'**
  String get bikeProfileMtb;

  /// No description provided for @bikeProfileMtbDesc.
  ///
  /// In en, this message translates to:
  /// **'Comfortable on dirt paths and mixed surfaces.'**
  String get bikeProfileMtbDesc;

  /// No description provided for @bikeProfileElectric.
  ///
  /// In en, this message translates to:
  /// **'E-bike'**
  String get bikeProfileElectric;

  /// No description provided for @bikeProfileElectricDesc.
  ///
  /// In en, this message translates to:
  /// **'Faster pace with less effort on hills.'**
  String get bikeProfileElectricDesc;

  /// No description provided for @bikeProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Bike preference saved.'**
  String get bikeProfileUpdated;

  /// No description provided for @navigationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'During navigation'**
  String get navigationSettingsTitle;

  /// No description provided for @voiceGuidance.
  ///
  /// In en, this message translates to:
  /// **'Voice guidance'**
  String get voiceGuidance;

  /// No description provided for @voiceGuidanceHint.
  ///
  /// In en, this message translates to:
  /// **'Spoken turn-by-turn instructions while you ride.'**
  String get voiceGuidanceHint;

  /// No description provided for @voiceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Voice language'**
  String get voiceLanguage;

  /// No description provided for @voiceLanguageSameAsApp.
  ///
  /// In en, this message translates to:
  /// **'Same as app'**
  String get voiceLanguageSameAsApp;

  /// No description provided for @distanceUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get distanceUnits;

  /// No description provided for @distanceUnitsHint.
  ///
  /// In en, this message translates to:
  /// **'Distances in routes, navigation, and voice guidance.'**
  String get distanceUnitsHint;

  /// No description provided for @distanceUnitsKilometers.
  ///
  /// In en, this message translates to:
  /// **'Kilometers'**
  String get distanceUnitsKilometers;

  /// No description provided for @distanceUnitsMiles.
  ///
  /// In en, this message translates to:
  /// **'Miles'**
  String get distanceUnitsMiles;

  /// No description provided for @inFeet.
  ///
  /// In en, this message translates to:
  /// **'In {feet} ft'**
  String inFeet(int feet);

  /// No description provided for @inMilesDistance.
  ///
  /// In en, this message translates to:
  /// **'In {miles} mi'**
  String inMilesDistance(String miles);

  /// No description provided for @routeDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{kilometers} km'**
  String routeDistanceKm(String kilometers);

  /// No description provided for @routeDistanceMi.
  ///
  /// In en, this message translates to:
  /// **'{miles} mi'**
  String routeDistanceMi(String miles);

  /// No description provided for @ttsInFeet.
  ///
  /// In en, this message translates to:
  /// **'In {feet} feet'**
  String ttsInFeet(int feet);

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable. Please try again later.'**
  String get serviceUnavailable;

  /// No description provided for @couldNotConnectApi.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to CycloRoute API'**
  String get couldNotConnectApi;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get requestFailed;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment.'**
  String get tooManyRequests;

  /// No description provided for @invalidOrExpiredResetCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired reset code'**
  String get invalidOrExpiredResetCode;

  /// No description provided for @couldNotSaveRoute.
  ///
  /// In en, this message translates to:
  /// **'Could not save this route.'**
  String get couldNotSaveRoute;

  /// No description provided for @pleaseSignInAgainToSaveRoute.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to save this route.'**
  String get pleaseSignInAgainToSaveRoute;

  /// No description provided for @couldNotSearchPlaces.
  ///
  /// In en, this message translates to:
  /// **'Could not search places right now.'**
  String get couldNotSearchPlaces;

  /// No description provided for @couldNotUploadAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Could not upload analysis'**
  String get couldNotUploadAnalysis;

  /// No description provided for @routeSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Route saved successfully.'**
  String get routeSavedSuccessfully;

  /// No description provided for @savedRouteDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved route'**
  String get savedRouteDetailTitle;

  /// No description provided for @renameSavedRoute.
  ///
  /// In en, this message translates to:
  /// **'Rename route'**
  String get renameSavedRoute;

  /// No description provided for @renameSavedRouteHint.
  ///
  /// In en, this message translates to:
  /// **'Route name'**
  String get renameSavedRouteHint;

  /// No description provided for @savedRouteRenamed.
  ///
  /// In en, this message translates to:
  /// **'Route renamed.'**
  String get savedRouteRenamed;

  /// No description provided for @couldNotRenameSavedRoute.
  ///
  /// In en, this message translates to:
  /// **'Could not rename this route.'**
  String get couldNotRenameSavedRoute;

  /// No description provided for @deleteSavedRoute.
  ///
  /// In en, this message translates to:
  /// **'Delete route'**
  String get deleteSavedRoute;

  /// No description provided for @deleteSavedRouteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from your saved routes?'**
  String deleteSavedRouteConfirm(String name);

  /// No description provided for @savedRouteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Route deleted.'**
  String get savedRouteDeleted;

  /// No description provided for @couldNotDeleteSavedRoute.
  ///
  /// In en, this message translates to:
  /// **'Could not delete this route.'**
  String get couldNotDeleteSavedRoute;

  /// No description provided for @savedRouteMissingPayload.
  ///
  /// In en, this message translates to:
  /// **'This saved route has no navigation data.'**
  String get savedRouteMissingPayload;

  /// No description provided for @noRouteOptionsFound.
  ///
  /// In en, this message translates to:
  /// **'No route options were found for those places.'**
  String get noRouteOptionsFound;

  /// No description provided for @chooseOriginWithCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Choose an origin with coordinates.'**
  String get chooseOriginWithCoordinates;

  /// No description provided for @chooseDestinationFromSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Choose a destination from the suggestions.'**
  String get chooseDestinationFromSuggestions;

  /// No description provided for @pleaseSignInToCalculateRoutes.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to calculate routes.'**
  String get pleaseSignInToCalculateRoutes;

  /// No description provided for @locatingYou.
  ///
  /// In en, this message translates to:
  /// **'Locating you'**
  String get locatingYou;

  /// No description provided for @locatingYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Getting your current position to prepare nearby guidance.'**
  String get locatingYouSubtitle;

  /// No description provided for @readyForRouteSearch.
  ///
  /// In en, this message translates to:
  /// **'Ready for route search'**
  String get readyForRouteSearch;

  /// No description provided for @readyForRouteSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a destination and CycloRoute will compare options.'**
  String get readyForRouteSearchSubtitle;

  /// No description provided for @routePlanning.
  ///
  /// In en, this message translates to:
  /// **'Route planning'**
  String get routePlanning;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @needsPermission.
  ///
  /// In en, this message translates to:
  /// **'Needs permission'**
  String get needsPermission;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location access'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionRationale.
  ///
  /// In en, this message translates to:
  /// **'CycloRoute uses your location while you use the app to show your position on the map, suggest routes from where you are, and guide you during navigation.'**
  String get locationPermissionRationale;

  /// No description provided for @locationPermissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location still off'**
  String get locationPermissionDeniedTitle;

  /// No description provided for @locationPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Without location access you can still search routes manually, but navigation and your position on the map will not work.'**
  String get locationPermissionDeniedMessage;

  /// No description provided for @locationPermissionDeniedForeverTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable location in Settings'**
  String get locationPermissionDeniedForeverTitle;

  /// No description provided for @locationPermissionDeniedForeverMessage.
  ///
  /// In en, this message translates to:
  /// **'Location permission was blocked. Open app settings and allow location while using the app.'**
  String get locationPermissionDeniedForeverMessage;

  /// No description provided for @locationServiceDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services'**
  String get locationServiceDisabledTitle;

  /// No description provided for @locationServiceDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Your device location is turned off. Enable GPS/location services to use maps and navigation.'**
  String get locationServiceDisabledMessage;

  /// No description provided for @openAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openAppSettings;

  /// No description provided for @openLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open location settings'**
  String get openLocationSettings;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get enableLocation;

  /// No description provided for @locationRequiredForNavigation.
  ///
  /// In en, this message translates to:
  /// **'Location access is required to start navigation.'**
  String get locationRequiredForNavigation;

  /// No description provided for @searchStillWorks.
  ///
  /// In en, this message translates to:
  /// **'Search still works'**
  String get searchStillWorks;

  /// No description provided for @searchStillWorksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can type an origin manually if GPS is not available.'**
  String get searchStillWorksSubtitle;

  /// No description provided for @manualOrigin.
  ///
  /// In en, this message translates to:
  /// **'Manual origin'**
  String get manualOrigin;

  /// No description provided for @currentPositionReady.
  ///
  /// In en, this message translates to:
  /// **'Current position ready'**
  String get currentPositionReady;

  /// No description provided for @gpsLocked.
  ///
  /// In en, this message translates to:
  /// **'GPS locked'**
  String get gpsLocked;

  /// No description provided for @aboutMeters.
  ///
  /// In en, this message translates to:
  /// **'About {meters} m'**
  String aboutMeters(int meters);

  /// No description provided for @youAreMoving.
  ///
  /// In en, this message translates to:
  /// **'You are moving'**
  String get youAreMoving;

  /// No description provided for @planBeforeRiding.
  ///
  /// In en, this message translates to:
  /// **'Plan before riding'**
  String get planBeforeRiding;

  /// No description provided for @keepMapVisible.
  ///
  /// In en, this message translates to:
  /// **'Keep the map visible and start navigation only when you\'re ready to ride.'**
  String get keepMapVisible;

  /// No description provided for @searchDestinationCompare.
  ///
  /// In en, this message translates to:
  /// **'Search a destination to compare distance and bike infrastructure.'**
  String get searchDestinationCompare;

  /// No description provided for @standingBy.
  ///
  /// In en, this message translates to:
  /// **'Standing by'**
  String get standingBy;

  /// No description provided for @directionPending.
  ///
  /// In en, this message translates to:
  /// **'Direction pending'**
  String get directionPending;

  /// No description provided for @directionDetected.
  ///
  /// In en, this message translates to:
  /// **'Direction detected'**
  String get directionDetected;

  /// No description provided for @headingHelp.
  ///
  /// In en, this message translates to:
  /// **'Your heading can help align navigation when a route starts.'**
  String get headingHelp;

  /// No description provided for @startMovingCompass.
  ///
  /// In en, this message translates to:
  /// **'Start moving for live GPS updates.'**
  String get startMovingCompass;

  /// No description provided for @bikeInfrastructure.
  ///
  /// In en, this message translates to:
  /// **'Bike infra'**
  String get bikeInfrastructure;

  /// No description provided for @percentBikeInfra.
  ///
  /// In en, this message translates to:
  /// **'{value}% bike lanes'**
  String percentBikeInfra(int value);

  /// No description provided for @routeInfraHigh.
  ///
  /// In en, this message translates to:
  /// **'Strong bike lanes'**
  String get routeInfraHigh;

  /// No description provided for @routeInfraMedium.
  ///
  /// In en, this message translates to:
  /// **'Mixed infrastructure'**
  String get routeInfraMedium;

  /// No description provided for @routeInfraLow.
  ///
  /// In en, this message translates to:
  /// **'Limited bike lanes'**
  String get routeInfraLow;

  /// No description provided for @homeBikeInfraFocus.
  ///
  /// In en, this message translates to:
  /// **'Bike infrastructure'**
  String get homeBikeInfraFocus;

  /// No description provided for @degrees.
  ///
  /// In en, this message translates to:
  /// **'{value} deg'**
  String degrees(int value);

  /// No description provided for @navigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigating'**
  String get navigationTitle;

  /// No description provided for @navigationSessionMissing.
  ///
  /// In en, this message translates to:
  /// **'Navigation could not start. Choose a route and try again.'**
  String get navigationSessionMissing;

  /// No description provided for @startNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start navigation'**
  String get startNavigation;

  /// No description provided for @couldNotStartNavigation.
  ///
  /// In en, this message translates to:
  /// **'Could not start navigation.'**
  String get couldNotStartNavigation;

  /// No description provided for @recalculatingRoute.
  ///
  /// In en, this message translates to:
  /// **'Recalculating route...'**
  String get recalculatingRoute;

  /// No description provided for @routeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Route updated'**
  String get routeUpdated;

  /// No description provided for @offRoute.
  ///
  /// In en, this message translates to:
  /// **'Off route'**
  String get offRoute;

  /// No description provided for @noTurnByTurnSteps.
  ///
  /// In en, this message translates to:
  /// **'Turn-by-turn steps are not available for this route.'**
  String get noTurnByTurnSteps;

  /// No description provided for @endRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'End route?'**
  String get endRouteTitle;

  /// No description provided for @endRouteMessage.
  ///
  /// In en, this message translates to:
  /// **'Your route is still in progress. End navigation now?'**
  String get endRouteMessage;

  /// No description provided for @endRoute.
  ///
  /// In en, this message translates to:
  /// **'End route'**
  String get endRoute;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @arrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'You have arrived'**
  String get arrivedTitle;

  /// No description provided for @arrivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Navigation completed.'**
  String get arrivedMessage;

  /// No description provided for @navigatingTo.
  ///
  /// In en, this message translates to:
  /// **'Navigating to {destination}'**
  String navigatingTo(String destination);

  /// No description provided for @inMeters.
  ///
  /// In en, this message translates to:
  /// **'In {meters} m'**
  String inMeters(int meters);

  /// No description provided for @ttsInMeters.
  ///
  /// In en, this message translates to:
  /// **'In {meters} meters'**
  String ttsInMeters(int meters);

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @resumeNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume navigation?'**
  String get resumeNavigationTitle;

  /// No description provided for @resumeNavigationMessage.
  ///
  /// In en, this message translates to:
  /// **'You have an active route to {destination}.'**
  String resumeNavigationMessage(String destination);

  /// No description provided for @resumeNavigation.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeNavigation;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @activeNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation in progress'**
  String get activeNavigationTitle;

  /// No description provided for @activeNavigationTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to return to the map'**
  String get activeNavigationTapHint;

  /// No description provided for @navigationNotificationActive.
  ///
  /// In en, this message translates to:
  /// **'Navigation active'**
  String get navigationNotificationActive;

  /// No description provided for @navigationBackgroundPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Background location for navigation'**
  String get navigationBackgroundPermissionTitle;

  /// No description provided for @navigationBackgroundPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'To keep guiding you with the screen off or while using other apps, CycloRoute needs location access in the background during navigation.'**
  String get navigationBackgroundPermissionMessage;

  /// No description provided for @allowBackgroundLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow in background'**
  String get allowBackgroundLocation;

  /// No description provided for @continueWithLimitedLocation.
  ///
  /// In en, this message translates to:
  /// **'Continue with limited access'**
  String get continueWithLimitedLocation;

  /// No description provided for @navigationBackgroundSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable background location'**
  String get navigationBackgroundSettingsTitle;

  /// No description provided for @navigationBackgroundSettingsMessageAndroid.
  ///
  /// In en, this message translates to:
  /// **'Choose \"Allow all the time\" in app settings so navigation continues when the screen is off.'**
  String get navigationBackgroundSettingsMessageAndroid;

  /// No description provided for @navigationBackgroundSettingsMessageIos.
  ///
  /// In en, this message translates to:
  /// **'In Settings, open Location and choose \"Always\" so navigation continues when the screen is locked.'**
  String get navigationBackgroundSettingsMessageIos;

  /// No description provided for @navigationLimitedLocationWarning.
  ///
  /// In en, this message translates to:
  /// **'Location is limited to while using the app. Guidance may pause when the screen is off.'**
  String get navigationLimitedLocationWarning;

  /// No description provided for @routeOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Route options'**
  String get routeOptionsTitle;

  /// No description provided for @routesTo.
  ///
  /// In en, this message translates to:
  /// **'Routes to {destination}'**
  String routesTo(String destination);

  /// No description provided for @chooseYourRoute.
  ///
  /// In en, this message translates to:
  /// **'Choose your route'**
  String get chooseYourRoute;

  /// No description provided for @pickRouteThatFits.
  ///
  /// In en, this message translates to:
  /// **'Pick the route that fits your ride.'**
  String get pickRouteThatFits;

  /// No description provided for @startingFrom.
  ///
  /// In en, this message translates to:
  /// **'Starting from {origin}.'**
  String startingFrom(String origin);

  /// No description provided for @reviewRouteOnMap.
  ///
  /// In en, this message translates to:
  /// **'Review the route on the map and compare bike infrastructure.'**
  String get reviewRouteOnMap;

  /// No description provided for @infraComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare routes'**
  String get infraComparisonTitle;

  /// No description provided for @infraComparisonHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a column to select a route. Highlighted values are best in each row.'**
  String get infraComparisonHint;

  /// No description provided for @comparisonMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get comparisonMetric;

  /// No description provided for @cycloScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Cyclo score'**
  String get cycloScoreLabel;

  /// No description provided for @selectedRouteSummary.
  ///
  /// In en, this message translates to:
  /// **'Selected route'**
  String get selectedRouteSummary;

  /// No description provided for @saveRoute.
  ///
  /// In en, this message translates to:
  /// **'Save route'**
  String get saveRoute;

  /// No description provided for @noRouteOptionsLoaded.
  ///
  /// In en, this message translates to:
  /// **'No route options were loaded.'**
  String get noRouteOptionsLoaded;

  /// No description provided for @currentSegmentTitle.
  ///
  /// In en, this message translates to:
  /// **'On this segment'**
  String get currentSegmentTitle;

  /// No description provided for @conditionGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get conditionGood;

  /// No description provided for @conditionRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get conditionRegular;

  /// No description provided for @conditionPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get conditionPoor;

  /// No description provided for @riskLow.
  ///
  /// In en, this message translates to:
  /// **'Low risk'**
  String get riskLow;

  /// No description provided for @riskMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium risk'**
  String get riskMedium;

  /// No description provided for @riskHigh.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get riskHigh;

  /// No description provided for @infraCycleway.
  ///
  /// In en, this message translates to:
  /// **'Cycleway'**
  String get infraCycleway;

  /// No description provided for @infraProtectedLane.
  ///
  /// In en, this message translates to:
  /// **'Protected lane'**
  String get infraProtectedLane;

  /// No description provided for @infraSharedLane.
  ///
  /// In en, this message translates to:
  /// **'Shared lane'**
  String get infraSharedLane;

  /// No description provided for @infraBikeLane.
  ///
  /// In en, this message translates to:
  /// **'Bike lane'**
  String get infraBikeLane;

  /// No description provided for @infraLivingStreet.
  ///
  /// In en, this message translates to:
  /// **'Living street'**
  String get infraLivingStreet;

  /// No description provided for @infraResidential.
  ///
  /// In en, this message translates to:
  /// **'Residential'**
  String get infraResidential;

  /// No description provided for @infraPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary road'**
  String get infraPrimary;

  /// No description provided for @infraUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown infrastructure'**
  String get infraUnknown;

  /// No description provided for @dismissAlert.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissAlert;

  /// No description provided for @riskAlertTtsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Route alert'**
  String get riskAlertTtsPrefix;

  /// No description provided for @routeDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Route details'**
  String get routeDetailTitle;

  /// No description provided for @turnByTurnTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn-by-turn directions'**
  String get turnByTurnTitle;

  /// No description provided for @routeSegmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Route segments'**
  String get routeSegmentsTitle;

  /// No description provided for @alertsAlongRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts along route'**
  String get alertsAlongRouteTitle;

  /// No description provided for @noRouteSegments.
  ///
  /// In en, this message translates to:
  /// **'No detailed segments are available for this route.'**
  String get noRouteSegments;

  /// No description provided for @noRouteAlertsOnRoute.
  ///
  /// In en, this message translates to:
  /// **'No alerts on this route.'**
  String get noRouteAlertsOnRoute;

  /// No description provided for @segmentTableInfra.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure'**
  String get segmentTableInfra;

  /// No description provided for @segmentTableScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get segmentTableScore;

  /// No description provided for @segmentTableCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get segmentTableCondition;

  /// No description provided for @showAllSteps.
  ///
  /// In en, this message translates to:
  /// **'Show all ({count})'**
  String showAllSteps(int count);

  /// No description provided for @showFewerSteps.
  ///
  /// In en, this message translates to:
  /// **'Show fewer'**
  String get showFewerSteps;

  /// No description provided for @reviewerMap.
  ///
  /// In en, this message translates to:
  /// **'Reviewer map'**
  String get reviewerMap;

  /// No description provided for @mapLayerObstacles.
  ///
  /// In en, this message translates to:
  /// **'Obstacles'**
  String get mapLayerObstacles;

  /// No description provided for @mapLayerInfrastructure.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure'**
  String get mapLayerInfrastructure;

  /// No description provided for @mapLayerCoverage.
  ///
  /// In en, this message translates to:
  /// **'Graph coverage'**
  String get mapLayerCoverage;

  /// No description provided for @moderationApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get moderationApprove;

  /// No description provided for @moderationReject.
  ///
  /// In en, this message translates to:
  /// **'Reject / Hide'**
  String get moderationReject;

  /// No description provided for @moderationPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get moderationPending;

  /// No description provided for @reportAwaitingReview.
  ///
  /// In en, this message translates to:
  /// **'Awaiting review'**
  String get reportAwaitingReview;

  /// No description provided for @communityReportPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Thanks. Your report is pending review before it appears on the map.'**
  String get communityReportPendingMessage;

  /// No description provided for @moderationActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get moderationActive;

  /// No description provided for @moderationHidden.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get moderationHidden;

  /// No description provided for @moderationAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get moderationAll;

  /// No description provided for @editReport.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editReport;

  /// No description provided for @deleteReport.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteReport;

  /// No description provided for @confirmDeleteReport.
  ///
  /// In en, this message translates to:
  /// **'Delete this obstacle report?'**
  String get confirmDeleteReport;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @couldNotUpdateReport.
  ///
  /// In en, this message translates to:
  /// **'Could not update report'**
  String get couldNotUpdateReport;

  /// No description provided for @obstacleTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get obstacleTimeRemaining;

  /// No description provided for @obstacleVisibleUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Visible until'**
  String get obstacleVisibleUntilLabel;

  /// No description provided for @obstacleVisibleUntil.
  ///
  /// In en, this message translates to:
  /// **'Visible until {date}'**
  String obstacleVisibleUntil(String date);

  /// No description provided for @obstacleNoExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry date'**
  String get obstacleNoExpiry;

  /// No description provided for @obstacleExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get obstacleExpired;

  /// No description provided for @obstacleTimeRemainingDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String obstacleTimeRemainingDays(int days);

  /// No description provided for @obstacleTimeRemainingHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours left'**
  String obstacleTimeRemainingHours(int hours);

  /// No description provided for @obstacleTimeRemainingMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes left'**
  String obstacleTimeRemainingMinutes(int minutes);

  /// No description provided for @obstacleReportedAt.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get obstacleReportedAt;

  /// No description provided for @obstacleAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get obstacleAuthor;

  /// No description provided for @obstacleActiveDuration.
  ///
  /// In en, this message translates to:
  /// **'Days visible on map'**
  String get obstacleActiveDuration;

  /// No description provided for @analysisResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis result'**
  String get analysisResultTitle;

  /// No description provided for @analysisResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The AI reviewed your photo and updated the cycling map near this location.'**
  String get analysisResultSubtitle;

  /// No description provided for @analysisResultScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'of 100'**
  String get analysisResultScoreLabel;

  /// No description provided for @qualityGoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Good infrastructure'**
  String get qualityGoodTitle;

  /// No description provided for @qualityGoodDescription.
  ///
  /// In en, this message translates to:
  /// **'The area looks safe and comfortable for cycling. Nearby routes will favor this segment.'**
  String get qualityGoodDescription;

  /// No description provided for @qualityRegularTitle.
  ///
  /// In en, this message translates to:
  /// **'Fair infrastructure'**
  String get qualityRegularTitle;

  /// No description provided for @qualityRegularDescription.
  ///
  /// In en, this message translates to:
  /// **'Some elements could be improved. The score was blended into nearby routes with moderate weight.'**
  String get qualityRegularDescription;

  /// No description provided for @qualityBadTitle.
  ///
  /// In en, this message translates to:
  /// **'Poor infrastructure'**
  String get qualityBadTitle;

  /// No description provided for @qualityBadDescription.
  ///
  /// In en, this message translates to:
  /// **'The scene shows risks for cyclists (traffic, obstacles, or missing bike infrastructure). Nearby routes were penalized to protect riders.'**
  String get qualityBadDescription;

  /// No description provided for @graphImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'Map and routing impact'**
  String get graphImpactTitle;

  /// No description provided for @graphImpactDescription.
  ///
  /// In en, this message translates to:
  /// **'The engine adjusted street graph edges around your GPS point so future route suggestions reflect what was detected.'**
  String get graphImpactDescription;

  /// No description provided for @graphImpactPendingDescription.
  ///
  /// In en, this message translates to:
  /// **'The analysis is saved as pending. The graph will only be updated after an admin approves this capture.'**
  String get graphImpactPendingDescription;

  /// No description provided for @graphUpdatePendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval — graph not updated yet'**
  String get graphUpdatePendingApproval;

  /// No description provided for @graphEdgesWouldUpdate.
  ///
  /// In en, this message translates to:
  /// **'Estimated edges on approval: {count}'**
  String graphEdgesWouldUpdate(int count);

  /// No description provided for @infrastructurePendingReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Awaiting reviewer approval'**
  String get infrastructurePendingReviewTitle;

  /// No description provided for @infrastructurePendingReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Your capture was analyzed successfully. It will appear on the reviewer map and affect routing only after an admin approves it.'**
  String get infrastructurePendingReviewBody;

  /// No description provided for @infrastructureAdminApproveOnly.
  ///
  /// In en, this message translates to:
  /// **'Only an admin can approve this capture and update the routing graph. You can still reject invalid submissions.'**
  String get infrastructureAdminApproveOnly;

  /// No description provided for @reportSubmittedForReview.
  ///
  /// In en, this message translates to:
  /// **'Submitted for review. The map and routes will update once an admin approves it.'**
  String get reportSubmittedForReview;

  /// No description provided for @graphRadiusDetail.
  ///
  /// In en, this message translates to:
  /// **'Influence radius: {meters} m'**
  String graphRadiusDetail(int meters);

  /// No description provided for @graphUpdateApplied.
  ///
  /// In en, this message translates to:
  /// **'Graph update applied successfully'**
  String get graphUpdateApplied;

  /// No description provided for @graphUpdateNotApplied.
  ///
  /// In en, this message translates to:
  /// **'Graph update could not be applied (no nearby edges)'**
  String get graphUpdateNotApplied;

  /// No description provided for @detectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Objects detected by the vision model in your photo:'**
  String get detectionsSubtitle;

  /// No description provided for @acceptAndGoHome.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptAndGoHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
