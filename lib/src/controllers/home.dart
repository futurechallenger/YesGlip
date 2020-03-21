import 'package:angel_framework/angel_framework.dart';

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
}
