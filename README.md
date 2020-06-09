# LMSify

There are lot of LMS, and we can develop one for nearly all of them. Because there’s a standard that lots of platforms are follow. You can check out the standard from imsglobal.org. First of all, there are some concepts we need to make it clear.
TP: Tool Provider, the LTI is a tool provider. It’s also called external tool.
TC: Tool Consumer, it’s the canvas, LMS.
Prepare for development
There are couple versions of LTI standards, the sample below will adapt v1.1. When you first develop LTI, a free account is good to have. You can register one here. Once it’s done, you can create a course to test. In the “settings” of the course.
Start to develop
I’m going to develop a app that is a little compllicated than a “Hello, world”. I’m about to print all parameters in the launch request. The Launch Request is a request that canvas will send to you after a user hit the link of your LTI app. The parameters in the launch request are basically all information what you can get from canvas for you LTI app.
Any programming language is OK. I’m a fan of flutter, which can be used to develop mobile(android and ios), web, and desktop. Web and desktop are in beta though. So the language is Dart. I choose the angel framework, a express like web framework to develop a web server. If you can not use Dart, it’s OK. The code is easy to read, it works just like express, or even sprintboot. All are path and corresponding handler relationship. Not like PHP, it really confuses me.
You can take advantage of the cli of the angel framework to create a project from different kinds of builerplate. Of you can create the project yourself. Or you can just fork my project fromm here.
A Dart project is more like a nodejs project. Dependencies are listed in a “package” file named pubspec.yaml. In a web server in dart, code are all in lib/srcdirectory. The main.dart is in bin directory, which is the start of a project.
Please notice that code below is not working code, just a part of it. The working ones are in my repo.
In bin/main.dart, app is created and configured:
main() async {
  load();
  Angel app = new Angel(reflector: MirrorsReflector());
  await app.configure(jael(fs.directory('views'))); /* 1 */
  await app.configure(new HomeController().configureServer);    /* 2 */
  /* 3 */
  app.all('*', (req, res) {
    res.headers['X-Frame-Options'] = 'ALLOW-FROM https://*.instructure.com';
    return true;
  });
  /* 4 */
  var vDir = VirtualDirectory(app, fs, source: fs.directory('static'));
  app.fallback(vDir.handleRequest);
}
/* 1 / Use the jael template engine to render pages / 2 / Config the controller to handle requests. Controllers are like path and handler pairs:
// If the request url is like: https://my_app.com, it will be handled by `launch` method.
@Expose('/')
class HomeController extends Controller {
  @Expose('/')
  launch(RequestContext req, ResponseContext res) async {
    await res.render('index', {'title': 'First render'});
  }
}
/* 3 */ A middleware here. This is something I do really need to remind you. When a html page is about to loaded in an iframe, if the header included X-Frame-Optionsand it’s value is always SAMEORIGIN, you page will never show in the iframe. The statement may not right, but I did not find a way to get rid of it. What my point here is that the wrong value can make it work. OH MAN, this’s definitely not recommended!!!
/* 4 */ Make the server serve static contents.
Now, if you have a handler return “hello, world!”, you can set it in canvas and read those words. Let’s make it a little more complicated by adding a controller.
It seems set routes by controllers is not a recommended way in angel framework. But I'm just gonna enjoy the OOP programming.
import 'package:angel_framework/angel_framework.dart';
@Expose('/')
class HomeController extends Controller {
  @Expose('/tool/verify', method: 'POST')
  verifyExternal(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();    /* 1 */
      final params = req.bodyAsMap;
      await res.render('index', {'title': 'First render', 'params': params});
    } catch (e) {
      print('ERROR: ${e}');
      res.redirect('/error.html'); /* 2 */
    }
  }
}
/* 1 / Parse the body to get its value from req.bodyAsMap. / 2 */ This is why server static config is needed in app configuration.
When parameters in launch requst comes, it’s renderd in the index.jael page, like:
<extend src="layout.jael">
  <block name="content">
    <i if=params == null>There are no values</i>
    <ul if=params!= null>
      <li for-each=params.keys as="k">
        <span>{{k}} - {{params[k]}}</span>
      </li>
    </ul>
    <div>{{title}}</div>
  </block>
</extend>
You can see the extend, block and if, for-each directives, these are jael template engine keywords. But I'm not going to go that far.
Now your LTI is OK to show parameters, after you config it in canvas. Parameters are like:
context_title - Algorithm
custom_canvas_api_domain - canvas.instructure.com
custom_canvas_course_id - XXXXXX
custom_canvas_enrollment_state - active
custom_canvas_user_id - XXXXXX
custom_canvas_user_login_id - XXXXXXXXXXX
custom_canvas_workflow_state - claimed
launch_presentation_document_target - iframe
