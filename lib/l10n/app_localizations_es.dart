// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'CycloRoute';

  @override
  String get settings => 'Configuración';

  @override
  String get profile => 'Perfil';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma del dispositivo';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get defaultRoutePreference => 'Preferencia de ruta por defecto';

  @override
  String get defaultRoutePreferenceHint =>
      'Esta opción se preselecciona cuando comparas rutas.';

  @override
  String get preferenceUpdated => 'Preferencia de ruta actualizada.';

  @override
  String get couldNotUpdatePreference => 'No se pudo actualizar la preferencia';

  @override
  String get savedRoutes => 'Rutas guardadas';

  @override
  String get routeHistory => 'Historial de rutas';

  @override
  String get reportObstacle => 'Reportar obstáculo';

  @override
  String get collaborativeMap => 'Mapa revisor';

  @override
  String get aiRouteCoverage => 'Cobertura IA de rutas';

  @override
  String get reviewInfrastructure => 'Revisar infraestructura';

  @override
  String get submitInfrastructureCapture => 'Enviar captura de infraestructura';

  @override
  String get infrastructureAdminTitle => 'Administrar infraestructura IA';

  @override
  String get infrastructureAdminSubtitle =>
      'Revisa capturas enviadas por colaboradores, aprueba las válidas para actualizar el grafo o rechaza las incorrectas.';

  @override
  String get infrastructureAdminListTab => 'Cola';

  @override
  String get infrastructureAdminMapTab => 'Mapa';

  @override
  String get infrastructureEmptyPending =>
      'No hay capturas pendientes de revisión.';

  @override
  String get infrastructureEmptyActive => 'No hay capturas activas en el mapa.';

  @override
  String get infrastructureEmptyHidden => 'No hay capturas rechazadas.';

  @override
  String get infrastructureEmptyAll =>
      'Aún no hay capturas de infraestructura IA.';

  @override
  String infrastructureSubmittedBy(String name) {
    return 'Enviado por $name';
  }

  @override
  String get couldNotLoadInfrastructure =>
      'No se pudo cargar la infraestructura IA';

  @override
  String get infrastructureApproveGraphHint =>
      'Al aprobar se actualiza el grafo de rutas. Rechazar oculta la captura sin tocar el grafo.';

  @override
  String get obstacleReports => 'Reportes de obstáculos';

  @override
  String get reviewerTools => 'Herramientas de revisor';

  @override
  String get accessDenied => 'Acceso denegado';

  @override
  String get insufficientRole => 'No tienes permiso para esta acción.';

  @override
  String welcomeUser(String name) {
    return 'Bienvenido, $name';
  }

  @override
  String get whereTo => '¿A dónde?';

  @override
  String get origin => 'Origen';

  @override
  String get destination => 'Destino';

  @override
  String get originHint => 'Ubicación actual u otro lugar';

  @override
  String get destinationHint => 'Escribe un destino';

  @override
  String get searchDestinationHint =>
      'Busca lugares recientes o escribe un destino';

  @override
  String get recentDestinations => 'Destinos recientes';

  @override
  String get recentOrigins => 'Puntos de partida recientes';

  @override
  String get recentDestinationsEmpty =>
      'Tus destinos recientes aparecerán aquí.';

  @override
  String get recentOriginsEmpty =>
      'Tus puntos de partida recientes aparecerán aquí.';

  @override
  String get clear => 'Borrar';

  @override
  String get seeRouteOptions => 'Ver opciones de ruta';

  @override
  String get useCurrentLocation => 'Usar ubicación actual';

  @override
  String get setLocationOnMap => 'Establecer ubicación en el mapa';

  @override
  String get currentLocation => 'Ubicación actual';

  @override
  String get mapSelectedLocation => 'Seleccionado en el mapa';

  @override
  String get confirmLocation => 'Confirmar ubicación';

  @override
  String get dragMapToAdjustPin => 'Arrastra el mapa para ajustar el pin';

  @override
  String get chooseStartingPoint => 'Elige punto de partida';

  @override
  String get gpsLocation => 'Ubicación GPS';

  @override
  String get nearbyAlerts => 'Alertas cercanas';

  @override
  String get checkingArea => 'Revisando zona';

  @override
  String get liveContext => 'Contexto en vivo';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signInSubtitle => 'Inicia sesión para continuar.';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get sessionExpired => 'Tu sesión expiró. Vuelve a iniciar sesión.';

  @override
  String get enterEmailAndPassword => 'Ingresa correo y contraseña';

  @override
  String get invalidCredentials => 'Correo o contraseña incorrectos';

  @override
  String get createAccount => 'Crear una cuenta';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerSubtitle => 'Completa tus datos para empezar.';

  @override
  String get alreadyHaveAccount => 'Ya tengo una cuenta';

  @override
  String get alreadyHaveAccountPrompt => '¿Ya tienes una cuenta? ';

  @override
  String get agreeToTermsPrefix => 'Acepto los ';

  @override
  String get authEntrySubtitle =>
      'Rutas pensadas para ciclistas, con infraestructura en la que puedes confiar.';

  @override
  String get authFeatureBikeInfra => 'Ciclovías primero';

  @override
  String get authFeatureSmartRoutes => '3 opciones de ruta';

  @override
  String get authFeatureTurnByTurn => 'Voz paso a paso';

  @override
  String get homeQuickAccess => 'Acceso rápido';

  @override
  String get homeYourSetup => 'Tu configuración';

  @override
  String get register => 'Registrarse';

  @override
  String get firstNames => 'Nombres';

  @override
  String get lastNames => 'Apellidos';

  @override
  String get phoneNumber => 'Teléfono';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get fillAllFields => 'Completa todos los campos';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get agreeToTerms => 'Debes aceptar los términos y condiciones';

  @override
  String get registrationFailed => 'El registro falló. Inténtalo de nuevo.';

  @override
  String get termsAndConditions => 'Términos y condiciones';

  @override
  String get forgotPasswordTitle => 'Olvidé mi contraseña';

  @override
  String get resetYourPassword => 'Restablece tu contraseña';

  @override
  String get forgotPasswordHint =>
      'Ingresa tu correo y enviaremos un código de 6 dígitos si la cuenta existe.';

  @override
  String get sendResetCode => 'Enviar código';

  @override
  String get checkYourEmail => 'Revisa tu correo';

  @override
  String get continueButton => 'Continuar';

  @override
  String get resetPasswordTitle => 'Restablecer contraseña';

  @override
  String get enterCodeFromEmail => 'Ingresa el código de tu correo';

  @override
  String get resetCodeHint =>
      'Revisa tu bandeja de entrada. El código expira en 15 minutos.';

  @override
  String get sixDigitCode => 'Código de 6 dígitos';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get updatePassword => 'Actualizar contraseña';

  @override
  String get fillAllFieldsReset => 'Completa todos los campos';

  @override
  String get codeMustBeSixDigits => 'El código debe tener 6 dígitos';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordUpdatedSignIn =>
      'Contraseña actualizada. Inicia sesión de nuevo.';

  @override
  String get resetFailed => 'No se pudo restablecer';

  @override
  String get chooseDefaultRoute => 'Elige tu ruta por defecto';

  @override
  String get onboardingRouteHint =>
      'Preseleccionaremos esta opción al comparar rutas. Puedes cambiarla después en Configuración.';

  @override
  String onboardingStepLabel(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get onboardingFinishSetup => 'Empezar a pedalear';

  @override
  String get noProfileLoaded => 'No se cargó el perfil';

  @override
  String get editRoutePreference => 'Editar preferencia de ruta';

  @override
  String get roleCyclist => 'Ciclista';

  @override
  String get roleReviewer => 'Revisor';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleLabel => 'Rol';

  @override
  String get defaultRouteLabel => 'Ruta por defecto';

  @override
  String get phoneLabel => 'Teléfono';

  @override
  String get emailLabel => 'Correo';

  @override
  String get noSavedRoutes => 'Aún no tienes rutas guardadas :(';

  @override
  String get noSavedRoutesHint =>
      'Guarda una ruta desde los resultados o el historial para verla aquí.';

  @override
  String get noRouteHistory => 'Aún no hay rutas en tu historial :(';

  @override
  String get noRouteHistoryHint =>
      'Cuando completes un recorrido, aparecerá aquí.';

  @override
  String get pleaseSignInAgain => 'Vuelve a iniciar sesión';

  @override
  String get couldNotLoadSavedRoutes =>
      'No se pudieron cargar las rutas guardadas';

  @override
  String get couldNotLoadRouteHistory => 'No se pudo cargar el historial';

  @override
  String get routeHistoryDetailTitle => 'Ruta anterior';

  @override
  String get routeHistoryMissingPayload =>
      'Esta ruta del historial no tiene datos de navegación.';

  @override
  String routeHistoryCompletedAt(String date) {
    return 'Completada el $date';
  }

  @override
  String get manualObstacleReport => 'Reportar obstáculo';

  @override
  String get obstacleReportHint =>
      'Marca el punto exacto en el mapa. Otros ciclistas recibirán alertas al pasar cerca durante la navegación.';

  @override
  String get obstacleCategoryTitle => 'Tipo de obstáculo';

  @override
  String get obstacleSeverityTitle => 'Gravedad';

  @override
  String get obstacleCategoryBlockedLane => 'Ciclovía bloqueada';

  @override
  String get obstacleCategoryConstruction => 'Obra o cierre';

  @override
  String get obstacleCategorySurfaceDamage => 'Pavimento dañado';

  @override
  String get obstacleCategoryDebris => 'Escombros en vía';

  @override
  String get obstacleCategoryOther => 'Otro';

  @override
  String get obstacleSeverityLow => 'Baja';

  @override
  String get obstacleSeverityMedium => 'Media';

  @override
  String get obstacleSeverityHigh => 'Alta';

  @override
  String get pinObstacleLocation => 'Ubicación del obstáculo';

  @override
  String get adjustPinOnMap =>
      'Mueve el mapa para colocar el pin con precisión';

  @override
  String get useMyLocation => 'Usar mi ubicación';

  @override
  String get myObstacleReports => 'Mis reportes';

  @override
  String get noMyReportsYet => 'Aún no has reportado obstáculos';

  @override
  String get noMyReportsHint =>
      'Tus reportes ayudan a alertar a otros ciclistas en la zona.';

  @override
  String get communityReportThanks =>
      'Gracias. Otros ciclistas serán alertados cerca de este punto.';

  @override
  String get reportFromNavigation => 'Reportar aquí';

  @override
  String get description => 'Descripción';

  @override
  String get obstacleDescriptionHint => 'Vehículo bloqueando ciclovía...';

  @override
  String get relatedRouteType => 'Tipo de ruta relacionado';

  @override
  String get describeObstacle => 'Describe el obstáculo';

  @override
  String get waitingForGps => 'Esperando ubicación GPS';

  @override
  String get obstacleSubmitted => 'Reporte de obstáculo enviado.';

  @override
  String get couldNotSubmitReport => 'No se pudo enviar el reporte';

  @override
  String get submitReport => 'Enviar reporte';

  @override
  String get noReportsYet => 'Aún no hay reporte de obstáculos :(';

  @override
  String get couldNotLoadReports => 'No se pudieron cargar los reportes';

  @override
  String get couldNotLoadCollaborativeMap =>
      'No se pudo cargar el mapa revisor';

  @override
  String get couldNotLoadCoverage => 'No se pudo cargar la cobertura';

  @override
  String get captureInfrastructure => 'Capturar infraestructura';

  @override
  String get reviewerCaptureHint =>
      'Tu foto y GPS mejoran el mapa colaborativo para todos los ciclistas.';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get takePhotoFirst => 'Toma o elige una foto primero';

  @override
  String get analyzeAndSubmit => 'Analizar y enviar';

  @override
  String get reportImprovedMap => 'Tu reporte mejoró el mapa para todos.';

  @override
  String graphEdgesUpdated(int count) {
    return 'Aristas del grafo actualizadas: $count';
  }

  @override
  String get detections => 'Detecciones';

  @override
  String get engineDiagnostics => 'Diagnóstico del motor';

  @override
  String get reviewerToolsHint =>
      'Solo revisores y administradores pueden acceder a estos endpoints.';

  @override
  String get couldNotLoadEngineHealth =>
      'No se pudo cargar el estado del motor';

  @override
  String get gpsRequiredForDebug =>
      'Se requiere GPS para la ruta de depuración';

  @override
  String get couldNotRunRouteDebug => 'No se pudo ejecutar la depuración';

  @override
  String get engineHealth => 'Estado del motor';

  @override
  String get routeDebug => 'Depuración de ruta';

  @override
  String get routePrefRecommended => 'Recomendada con ciclovías';

  @override
  String get routePrefRecommendedDesc =>
      'Prioriza ciclovías e infraestructura ciclista.';

  @override
  String get routePrefBalanced => 'Ruta balanceada';

  @override
  String get routePrefBalancedDesc =>
      'Equilibra distancia, comodidad e infraestructura ciclista.';

  @override
  String get routePrefShorter => 'Más rápida / corta';

  @override
  String get routePrefShorterDesc =>
      'Ruta más corta con menos prioridad en ciclovías.';

  @override
  String get planningPreferencesTitle => '¿Cómo te recomendamos rutas?';

  @override
  String get planningRouteTypeHint => 'Elige el estilo que más te convenga.';

  @override
  String get myBike => 'Mi bicicleta';

  @override
  String get myBikeHint =>
      'Ajustamos el tiempo de viaje y los caminos según tu bici.';

  @override
  String get bikeProfileUrban => 'Urbana';

  @override
  String get bikeProfileUrbanDesc =>
      'Calles pavimentadas y uso diario en la ciudad.';

  @override
  String get bikeProfileMtb => 'Montaña / gravel';

  @override
  String get bikeProfileMtbDesc =>
      'Cómoda en caminos de tierra y superficies mixtas.';

  @override
  String get bikeProfileElectric => 'Eléctrica';

  @override
  String get bikeProfileElectricDesc =>
      'Ritmo más rápido con menos esfuerzo en subidas.';

  @override
  String get bikeProfileUpdated => 'Preferencia de bicicleta guardada.';

  @override
  String get navigationSettingsTitle => 'Durante la navegación';

  @override
  String get voiceGuidance => 'Voz guiada';

  @override
  String get voiceGuidanceHint =>
      'Instrucciones habladas paso a paso mientras pedaleas.';

  @override
  String get voiceLanguage => 'Idioma de la voz';

  @override
  String get voiceLanguageSameAsApp => 'Igual que la app';

  @override
  String get distanceUnits => 'Unidades';

  @override
  String get distanceUnitsHint =>
      'Distancias en rutas, navegación y voz guiada.';

  @override
  String get distanceUnitsKilometers => 'Kilómetros';

  @override
  String get distanceUnitsMiles => 'Millas';

  @override
  String inFeet(int feet) {
    return 'En $feet pies';
  }

  @override
  String inMilesDistance(String miles) {
    return 'En $miles mi';
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
    return 'En $feet pies';
  }

  @override
  String get serviceUnavailable =>
      'Servicio no disponible. Inténtalo más tarde.';

  @override
  String get couldNotConnectApi =>
      'No se pudo conectar con la API de CycloRoute';

  @override
  String get requestFailed => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get tooManyRequests => 'Demasiadas solicitudes. Espera un momento.';

  @override
  String get invalidOrExpiredResetCode => 'Código inválido o expirado';

  @override
  String get couldNotSaveRoute => 'No se pudo guardar esta ruta.';

  @override
  String get pleaseSignInAgainToSaveRoute =>
      'Vuelve a iniciar sesión para guardar esta ruta.';

  @override
  String get couldNotSearchPlaces =>
      'No se pudieron buscar lugares en este momento.';

  @override
  String get couldNotUploadAnalysis => 'No se pudo subir el análisis';

  @override
  String get routeSavedSuccessfully => 'Ruta guardada correctamente.';

  @override
  String get savedRouteDetailTitle => 'Ruta guardada';

  @override
  String get renameSavedRoute => 'Renombrar ruta';

  @override
  String get renameSavedRouteHint => 'Nombre de la ruta';

  @override
  String get savedRouteRenamed => 'Ruta renombrada.';

  @override
  String get couldNotRenameSavedRoute => 'No se pudo renombrar la ruta.';

  @override
  String get deleteSavedRoute => 'Eliminar ruta';

  @override
  String deleteSavedRouteConfirm(String name) {
    return '¿Quitar \"$name\" de tus rutas guardadas?';
  }

  @override
  String get savedRouteDeleted => 'Ruta eliminada.';

  @override
  String get couldNotDeleteSavedRoute => 'No se pudo eliminar la ruta.';

  @override
  String get savedRouteMissingPayload =>
      'Esta ruta guardada no tiene datos de navegación.';

  @override
  String get noRouteOptionsFound =>
      'No se encontraron opciones de ruta para esos lugares.';

  @override
  String get chooseOriginWithCoordinates => 'Elige un origen con coordenadas.';

  @override
  String get chooseDestinationFromSuggestions =>
      'Elige un destino de las sugerencias.';

  @override
  String get pleaseSignInToCalculateRoutes =>
      'Vuelve a iniciar sesión para calcular rutas.';

  @override
  String get locatingYou => 'Ubicándote';

  @override
  String get locatingYouSubtitle =>
      'Obteniendo tu posición para preparar la guía cercana.';

  @override
  String get readyForRouteSearch => 'Listo para buscar ruta';

  @override
  String get readyForRouteSearchSubtitle =>
      'Elige un destino y CycloRoute comparará opciones.';

  @override
  String get routePlanning => 'Planificación de ruta';

  @override
  String get locationUnavailable => 'Ubicación no disponible';

  @override
  String get needsPermission => 'Requiere permiso';

  @override
  String get locationPermissionTitle => 'Acceso a la ubicación';

  @override
  String get locationPermissionRationale =>
      'CycloRoute usa tu ubicación mientras usas la app para mostrarte en el mapa, sugerir rutas desde donde estás y guiarte durante la navegación.';

  @override
  String get locationPermissionDeniedTitle => 'Ubicación aún desactivada';

  @override
  String get locationPermissionDeniedMessage =>
      'Sin ubicación puedes buscar rutas manualmente, pero la navegación y tu posición en el mapa no funcionarán.';

  @override
  String get locationPermissionDeniedForeverTitle =>
      'Activa la ubicación en Ajustes';

  @override
  String get locationPermissionDeniedForeverMessage =>
      'El permiso de ubicación fue bloqueado. Abre los ajustes de la app y permite la ubicación mientras la usas.';

  @override
  String get locationServiceDisabledTitle =>
      'Activa los servicios de ubicación';

  @override
  String get locationServiceDisabledMessage =>
      'La ubicación del dispositivo está apagada. Activa el GPS para usar mapas y navegación.';

  @override
  String get openAppSettings => 'Abrir ajustes';

  @override
  String get openLocationSettings => 'Abrir ajustes de ubicación';

  @override
  String get enableLocation => 'Activar ubicación';

  @override
  String get locationRequiredForNavigation =>
      'Se necesita acceso a la ubicación para iniciar la navegación.';

  @override
  String get searchStillWorks => 'La búsqueda sigue funcionando';

  @override
  String get searchStillWorksSubtitle =>
      'Puedes escribir un origen manualmente si no hay GPS.';

  @override
  String get manualOrigin => 'Origen manual';

  @override
  String get currentPositionReady => 'Posición actual lista';

  @override
  String get gpsLocked => 'GPS listo';

  @override
  String aboutMeters(int meters) {
    return 'Aprox. $meters m';
  }

  @override
  String get youAreMoving => 'Te estás moviendo';

  @override
  String get planBeforeRiding => 'Planifica antes de pedalear';

  @override
  String get keepMapVisible =>
      'Mantén el mapa visible e inicia navegación solo cuando estés listo para pedalear.';

  @override
  String get searchDestinationCompare =>
      'Busca un destino para comparar distancia e infraestructura ciclista.';

  @override
  String get standingBy => 'En espera';

  @override
  String get directionPending => 'Dirección pendiente';

  @override
  String get directionDetected => 'Dirección detectada';

  @override
  String get headingHelp =>
      'Tu rumbo puede ayudar a alinear la navegación al iniciar una ruta.';

  @override
  String get startMovingCompass =>
      'Muévete para obtener actualizaciones GPS en vivo.';

  @override
  String get bikeInfrastructure => 'Infra ciclista';

  @override
  String percentBikeInfra(int value) {
    return '$value% infra ciclista';
  }

  @override
  String get routeInfraHigh => 'Buena ciclovía';

  @override
  String get routeInfraMedium => 'Infra mixta';

  @override
  String get routeInfraLow => 'Poca infra ciclista';

  @override
  String get homeBikeInfraFocus => 'Infraestructura ciclista';

  @override
  String degrees(int value) {
    return '$value°';
  }

  @override
  String get navigationTitle => 'Navegando';

  @override
  String get navigationSessionMissing =>
      'No se pudo iniciar la navegación. Elige una ruta e inténtalo de nuevo.';

  @override
  String get startNavigation => 'Iniciar navegación';

  @override
  String get couldNotStartNavigation => 'No se pudo iniciar la navegación.';

  @override
  String get recalculatingRoute => 'Recalculando ruta...';

  @override
  String get routeUpdated => 'Ruta actualizada';

  @override
  String get offRoute => 'Fuera de ruta';

  @override
  String get noTurnByTurnSteps =>
      'No hay instrucciones turn-by-turn para esta ruta.';

  @override
  String get endRouteTitle => '¿Terminar ruta?';

  @override
  String get endRouteMessage =>
      'La ruta sigue en curso. ¿Quieres terminar la navegación ahora?';

  @override
  String get endRoute => 'Terminar ruta';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'Aceptar';

  @override
  String get arrivedTitle => 'Has llegado';

  @override
  String get arrivedMessage => 'Navegación completada.';

  @override
  String navigatingTo(String destination) {
    return 'Navegando a $destination';
  }

  @override
  String inMeters(int meters) {
    return 'En $meters m';
  }

  @override
  String ttsInMeters(int meters) {
    return 'En $meters metros';
  }

  @override
  String get distance => 'Distancia';

  @override
  String get time => 'Tiempo';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get resumeNavigationTitle => '¿Reanudar navegación?';

  @override
  String resumeNavigationMessage(String destination) {
    return 'Tienes una ruta activa hacia $destination.';
  }

  @override
  String get resumeNavigation => 'Reanudar';

  @override
  String get notNow => 'Ahora no';

  @override
  String get activeNavigationTitle => 'Navegación en curso';

  @override
  String get activeNavigationTapHint => 'Toca para volver al mapa';

  @override
  String get navigationNotificationActive => 'Navegación activa';

  @override
  String get navigationBackgroundPermissionTitle =>
      'Ubicación en segundo plano';

  @override
  String get navigationBackgroundPermissionMessage =>
      'Para seguir guiándote con la pantalla apagada o mientras usas otras apps, CycloRoute necesita acceso a tu ubicación en segundo plano durante la navegación.';

  @override
  String get allowBackgroundLocation => 'Permitir en segundo plano';

  @override
  String get continueWithLimitedLocation => 'Continuar con acceso limitado';

  @override
  String get navigationBackgroundSettingsTitle =>
      'Activa la ubicación en segundo plano';

  @override
  String get navigationBackgroundSettingsMessageAndroid =>
      'Elige \"Permitir todo el tiempo\" en los ajustes de la app para que la navegación continúe con la pantalla apagada.';

  @override
  String get navigationBackgroundSettingsMessageIos =>
      'En Ajustes, abre Ubicación y elige \"Siempre\" para que la navegación continúe con la pantalla bloqueada.';

  @override
  String get navigationLimitedLocationWarning =>
      'La ubicación está limitada a mientras usas la app. La guía puede pausarse con la pantalla apagada.';

  @override
  String get routeOptionsTitle => 'Opciones de ruta';

  @override
  String routesTo(String destination) {
    return 'Rutas a $destination';
  }

  @override
  String get chooseYourRoute => 'Elige tu ruta';

  @override
  String get pickRouteThatFits =>
      'Elige la ruta que mejor se adapte a tu pedaleo.';

  @override
  String startingFrom(String origin) {
    return 'Desde $origin.';
  }

  @override
  String get reviewRouteOnMap =>
      'Revisa la ruta en el mapa y compara la infraestructura ciclista.';

  @override
  String get infraComparisonTitle => 'Comparar rutas';

  @override
  String get infraComparisonHint =>
      'Toca una columna para elegir. Los mejores valores de cada fila se resaltan.';

  @override
  String get comparisonMetric => 'Métrica';

  @override
  String get cycloScoreLabel => 'Puntaje Cyclo';

  @override
  String get selectedRouteSummary => 'Ruta seleccionada';

  @override
  String get saveRoute => 'Guardar ruta';

  @override
  String get noRouteOptionsLoaded => 'No se cargaron opciones de ruta.';

  @override
  String get currentSegmentTitle => 'En este tramo';

  @override
  String get conditionGood => 'Buena';

  @override
  String get conditionRegular => 'Regular';

  @override
  String get conditionPoor => 'Mala';

  @override
  String get riskLow => 'Riesgo bajo';

  @override
  String get riskMedium => 'Riesgo medio';

  @override
  String get riskHigh => 'Riesgo alto';

  @override
  String get infraCycleway => 'Ciclovía';

  @override
  String get infraProtectedLane => 'Carril protegido';

  @override
  String get infraSharedLane => 'Carril compartido';

  @override
  String get infraBikeLane => 'Ciclovía en calzada';

  @override
  String get infraLivingStreet => 'Calle residencial lenta';

  @override
  String get infraResidential => 'Residencial';

  @override
  String get infraPrimary => 'Vía principal';

  @override
  String get infraUnknown => 'Infraestructura desconocida';

  @override
  String get dismissAlert => 'Descartar';

  @override
  String get riskAlertTtsPrefix => 'Alerta de ruta';

  @override
  String get routeDetailTitle => 'Detalle del trayecto';

  @override
  String get turnByTurnTitle => 'Indicaciones paso a paso';

  @override
  String get routeSegmentsTitle => 'Segmentos del trayecto';

  @override
  String get alertsAlongRouteTitle => 'Alertas en la ruta';

  @override
  String get noRouteSegments => 'No hay segmentos detallados para esta ruta.';

  @override
  String get noRouteAlertsOnRoute => 'No hay alertas en esta ruta.';

  @override
  String get segmentTableInfra => 'Infraestructura';

  @override
  String get segmentTableScore => 'Score';

  @override
  String get segmentTableCondition => 'Estado';

  @override
  String showAllSteps(int count) {
    return 'Ver todos ($count)';
  }

  @override
  String get showFewerSteps => 'Ver menos';

  @override
  String get reviewerMap => 'Mapa revisor';

  @override
  String get mapLayerObstacles => 'Obstáculos';

  @override
  String get mapLayerInfrastructure => 'Infraestructura';

  @override
  String get mapLayerCoverage => 'Cobertura grafo';

  @override
  String get moderationApprove => 'Aprobar';

  @override
  String get moderationReject => 'Rechazar / Ocultar';

  @override
  String get moderationPending => 'Pendiente';

  @override
  String get reportAwaitingReview => 'Pendiente de revisión';

  @override
  String get communityReportPendingMessage =>
      'Gracias. Tu reporte está pendiente de revisión antes de aparecer en el mapa.';

  @override
  String get moderationActive => 'Activos';

  @override
  String get moderationHidden => 'Rechazados';

  @override
  String get moderationAll => 'Todos';

  @override
  String get editReport => 'Editar';

  @override
  String get deleteReport => 'Eliminar';

  @override
  String get confirmDeleteReport => '¿Eliminar este reporte de obstáculo?';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get couldNotUpdateReport => 'No se pudo actualizar el reporte';

  @override
  String get obstacleTimeRemaining => 'Tiempo restante';

  @override
  String get obstacleVisibleUntilLabel => 'Visible hasta';

  @override
  String obstacleVisibleUntil(String date) {
    return 'Visible hasta $date';
  }

  @override
  String get obstacleNoExpiry => 'Sin fecha de caducidad';

  @override
  String get obstacleExpired => 'Caducado';

  @override
  String obstacleTimeRemainingDays(int days) {
    return 'Quedan $days días';
  }

  @override
  String obstacleTimeRemainingHours(int hours) {
    return 'Quedan $hours horas';
  }

  @override
  String obstacleTimeRemainingMinutes(int minutes) {
    return 'Quedan $minutes minutos';
  }

  @override
  String get obstacleReportedAt => 'Reportado';

  @override
  String get obstacleAuthor => 'Autor';

  @override
  String get obstacleActiveDuration => 'Días visible en mapa';

  @override
  String get analysisResultTitle => 'Resultado del análisis';

  @override
  String get analysisResultSubtitle =>
      'La IA revisó tu foto y actualizó el mapa ciclista cerca de esta ubicación.';

  @override
  String get analysisResultScoreLabel => 'de 100';

  @override
  String get qualityGoodTitle => 'Infraestructura buena';

  @override
  String get qualityGoodDescription =>
      'La zona se ve segura y cómoda para pedalear. Las rutas cercanas favorecerán este tramo.';

  @override
  String get qualityRegularTitle => 'Infraestructura regular';

  @override
  String get qualityRegularDescription =>
      'Hay elementos mejorables. La puntuación se integró en rutas cercanas con peso moderado.';

  @override
  String get qualityBadTitle => 'Infraestructura deficiente';

  @override
  String get qualityBadDescription =>
      'La escena muestra riesgos para ciclistas (tráfico, obstáculos o falta de infraestructura). Las rutas cercanas fueron penalizadas para proteger al ciclista.';

  @override
  String get graphImpactTitle => 'Impacto en mapa y rutas';

  @override
  String get graphImpactDescription =>
      'El motor ajustó aristas del grafo cerca de tu GPS para que futuras rutas reflejen lo detectado.';

  @override
  String get graphImpactPendingDescription =>
      'El análisis quedó en pendiente. El grafo solo se actualizará cuando un administrador apruebe esta captura.';

  @override
  String get graphUpdatePendingApproval =>
      'Pendiente de aprobación — grafo aún sin cambios';

  @override
  String graphEdgesWouldUpdate(int count) {
    return 'Aristas estimadas al aprobar: $count';
  }

  @override
  String get infrastructurePendingReviewTitle => 'Pendiente de aprobación';

  @override
  String get infrastructurePendingReviewBody =>
      'Tu captura se analizó correctamente. Aparecerá en el mapa revisor y afectará las rutas solo cuando un administrador la apruebe.';

  @override
  String get infrastructureAdminApproveOnly =>
      'Solo un administrador puede aprobar esta captura y actualizar el grafo de rutas. Aún puedes rechazar envíos inválidos.';

  @override
  String get reportSubmittedForReview =>
      'Enviado a revisión. El mapa y las rutas se actualizarán cuando un administrador lo apruebe.';

  @override
  String graphRadiusDetail(int meters) {
    return 'Radio de influencia: $meters m';
  }

  @override
  String get graphUpdateApplied => 'Actualización del grafo aplicada';

  @override
  String get graphUpdateNotApplied =>
      'No se pudo aplicar al grafo (sin aristas cercanas)';

  @override
  String get detectionsSubtitle =>
      'Objetos detectados por el modelo de visión en tu foto:';

  @override
  String get acceptAndGoHome => 'Aceptar';
}
