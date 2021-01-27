/*
Created NB 5/2020

Object to store data for macro keys

This information is stored on an HTTP server, 
and the client requests that information.
The connection to that server can be found in the
http_provider.dart file

As this list grows, it may be better to break down
further based on actionType

Providers functions for converting to and from JSON.
This is needed because I am both sending and recieving JSON
data from the HttpServer with GET and POST fucntions implemented.
*/
class Macro {
  final String title;
  final String text;
  final int singleColor;
  final int firstGradientColor;
  final int secondGradientColor;
  final int fontColor;
  final double fontSize;
  final double topPosition;
  final double leftPosition;
  final String fontSelection;
  final int leftSelection;
  final String pickedImage;
  final String actionType;
  final String action;

  Macro(
      this.title,
      this.text,
      this.singleColor,
      this.firstGradientColor,
      this.secondGradientColor,
      this.fontColor,
      this.fontSize,
      this.topPosition,
      this.leftPosition,
      this.fontSelection,
      this.leftSelection,
      this.pickedImage,
      this.actionType,
      this.action);

  Macro.fromJson(Map<dynamic, dynamic> parsedJson)
      : title = parsedJson['title'],
        text = parsedJson['text'],
        singleColor = parsedJson['singleColor'],
        firstGradientColor = parsedJson['firstGradientColor'],
        secondGradientColor = parsedJson['secondGradientColor'],
        fontColor = parsedJson['fontColor'],
        fontSize = parsedJson['fontSize'],
        topPosition = parsedJson['topPosition'],
        leftPosition = parsedJson['leftPosition'],
        fontSelection = parsedJson['fontSelection'],
        leftSelection = parsedJson['leftSelection'],
        pickedImage = parsedJson['pickedImage'],
        actionType = parsedJson['actionType'],
        action = parsedJson['action'];

  Map<dynamic, dynamic> toJson() => {
        'title': title,
        'text': text,
        'singleColor': singleColor,
        'firstGradientColor': firstGradientColor,
        'secondGradientColor': secondGradientColor,
        'fontColor': fontColor,
        'fontSize': fontSize,
        'topPosition': topPosition,
        'leftPosition': leftPosition,
        'fontSelection': fontSelection,
        'leftSelection': leftSelection,
        'pickedImage': pickedImage,
        'actionType': actionType,
        'action': action
      };

  //Macro({this.userId, this.id, this.title, this.completed});

  // Macro.fromJson(Map<dynamic, dynamic> parsedJson)
  //     : userId = parsedJson['ns'],
  //       id = parsedJson['id'],
  //       title = parsedJson['title'],
  //       completed = parsedJson['completed'];
}
