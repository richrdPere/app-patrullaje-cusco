
// import 'dart:io';

class Environment {
  // ApiKeys
  static String giphyApikey = 'ZIAgzfBiYJAQ7xBGmATKUPcPzsw0hEa3';
  static String giphyUrl = 'https://api.giphy.com/v1';
  static String googleMapsAPI = 'AIzaSyAfgODid5cBNr3nkD289YVVoWKyn5Raqz0';

  // Backend
  // // - Emulador
  // static String mainUrl = Platform.isAndroid
  //     ? 'http://10.0.2.2:4000/api'
  //     : 'http://localhost:4000/api';

  // static String socketUrl = Platform.isAndroid
  //     ? 'http://10.0.2.2:4000'
  //     : 'http://localhost:4000';

  // - Celular real - CASA
  // static String mainUrl = 'http://192.168.0.235:4000/api';
  // static String socketUrl = 'http://192.168.0.235:4000';

  // - Celular real - UNSAAC
  static String mainUrl = 'http://192.168.0.135:4000/api';
  static String socketUrl = 'http://192.168.0.135:4000';
}
