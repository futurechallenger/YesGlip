import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/http.dart';
import 'package:lmsify/src/controllers/home.dart';
import 'package:angel_container/mirrors.dart';
import 'package:angel_jael/angel_jael.dart';
import 'package:angel_static/angel_static.dart';
// import 'package:angel_file_service/angel_file_service.dart';
import 'package:file/local.dart';

main() async {
  // var app = Angel();
  Angel app = new Angel(reflector: MirrorsReflector());

  var fs = LocalFileSystem();

  await app.configure(jael(fs.directory('views')));
  await app.configure(new HomeController().configureServer);

  var vDir = VirtualDirectory(app, fs, source: fs.directory('static'));
  app.fallback(vDir.handleRequest);

  var http = AngelHttp(app);
  await http.startServer('localhost', 3000);
}