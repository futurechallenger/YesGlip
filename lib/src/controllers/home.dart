import 'package:angel_framework/angel_framework.dart';
import '../utils/utils.dart';

@Expose('/')
class HomeController extends Controller {
  @Expose('/')
  launch(RequestContext req, ResponseContext res) async {
    // res.write('hello world controller');
    await res.render('index', {'title': 'First render'});
  }

  @Expose('/home')
  home(ResponseContext res) async {
    await res.render('home', {'title': 'Home Page'});
  }

  @Expose('/tool/verify', method: 'POST')
  verifyExternal(RequestContext req, ResponseContext res) async {
    res.headers['X-Frame-Options'] = 'ALLOW-FROM https://instructure.com';
    try {
      print('request: headers: ${req.headers}');

      await req.parseBody();
      final params = req.bodyAsMap;

      // res.headers['X-Frame-Options'] = 'ALLOW-FROM https://instructure.com';
      // res.headers['Content-Security-Policy'] = 'frame-ancestors https://*.instructure.com';
      await res.render('index', {'title': 'First render', 'params': params});
    } catch (e) {
      print('ERROR: ${e}');
      res.redirect('/error.html');
    }
  }

  @Expose('/shared')
  shared(ResponseContext res) {
    res.json({
      "status": 'OK',
      'message': 'This pair of key/secret is just for test',
      'shared': {
        'key': utils.createCryptoRandomString(32),
        'secret': utils.createCryptoRandomString(32)
      }
    });
  }
}
