import 'package:http/http.dart' as http;

class getCaptchApi{

static Future<void> getCaptch()async{
  // var headers = {
  //   'Cookie': '.AspNetCore.Session=CfDJ8BtZbTn47sBBg17MBPTg%2FJMPpTSXB%2FxfvHhO5ugvtge%2BjWb4imXawSxZ4%2BFXVrjt86XLbUkCN2UO9MsAYe7Dq8sVDZob9L16C7K7OvW4E7%2BwlS76H8DaYeQySlaRYbdR38xbv9H9gbwUsRYTDK%2Fv6boDMm230L7b2OxpulIGAURX'
  // };
  var request = http.Request('GET', Uri.parse('https://player.go2market.in:5001/api/GetCaptcha'));

 // request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    print(await response.stream.bytesToString());
  }
  else {
  print(response.reasonPhrase);
  }
}
}