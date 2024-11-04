// redirect_helper_web.dart

import 'dart:html' as html;

void redirectToCheckout(String url) {
  html.window.location.href = url;
}
