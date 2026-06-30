import 'dart:html' as html;

void replaceWebHash(String route) {
  final normalized = route.startsWith('/') ? route : '/$route';
  html.window.history.replaceState(null, '', '#$normalized');
}
