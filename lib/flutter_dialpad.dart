library flutter_dialpad;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter_dtmf/flutter_dtmf.dart';

enum WhichTextField {
  first,
  second,
}

class DialPad extends StatefulWidget {
  final ValueSetter<String>? makeCall;
  final ValueSetter<String>? keyPressed;
  final bool? hideDialButton;
  final bool? hideSubtitle;
  // buttonColor is the color of the button on the dial pad. defaults to Colors.gray
  final Color? buttonColor;
  final Color? buttonTextColor;
  final Color? dialButtonColor;
  final Color? dialButtonIconColor;
  final IconData? dialButtonIcon;
  final Color? backspaceButtonIconColor;
  final Color? dialOutputTextColor;
  // outputMask is the mask applied to the output text. Defaults to (000) 000-0000
  final String? outputMask;
  final bool? enableDtmf;

  /// here is where I made some updates on the package
  final double? buttonClipOvalRadius;
  final double? titleFontSize;
  final double? subTitleFontSize;
  final double? starIconSize;
  final double? callIconSize;
  final double? hashIconSize;
  final double? dialOutputTextFontSize;
  final double? deleteButtonSize;
  final double? plusFontSize;
  final double? heightSearchBar;
  final InputDecoration? inputDecoration;
  final Color? searchContainerColor;
  final double? searchIconSize;
  // final List<String> searchResults;
  final BoxConstraints constraints;
  final List<String> searchHistory;

  DialPad(
      {this.makeCall,
      this.keyPressed,
      this.hideDialButton,
      this.hideSubtitle = false,
      this.outputMask,
      this.buttonColor,
      this.buttonTextColor = Colors.white,
      this.dialButtonColor,
      this.dialButtonIconColor,
      this.dialButtonIcon,
      this.dialOutputTextColor,
      this.backspaceButtonIconColor,
      this.enableDtmf,
      this.buttonClipOvalRadius = 48,
      this.titleFontSize = 15,
      this.subTitleFontSize = 8,
      this.starIconSize = 35,
      this.callIconSize = 22,
      this.hashIconSize = 20,
      this.dialOutputTextFontSize = 20,
      this.deleteButtonSize = 30,
      this.plusFontSize = 4,
      this.inputDecoration = const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      this.searchContainerColor = Colors.white,
      this.heightSearchBar = 40,
      this.searchIconSize,
      // this.searchResults = const [],
      this.constraints = const BoxConstraints(minWidth: 310, maxHeight: 380),
      this.searchHistory = const []});

  @override
  _DialPadState createState() => _DialPadState();
}

class _DialPadState extends State<DialPad> {
  MaskedTextController? textEditingController;
  TextEditingController? pinTextEditingController;
  SearchController? searchController;
  late FocusNode myNumberFocusNode;
  late FocusNode myPinFocusNode;

  WhichTextField firstOrSecond = WhichTextField.first;
  var _value = "";
  var _symbol = "";
  var mainTitle = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "＃"];
  var subTitle = [
    "",
    "ABC",
    "DEF",
    "GHI",
    "JKL",
    "MNO",
    "PQRS",
    "TUV",
    "WXYZ",
    null,
    "+",
    null
  ];

  void checkFocus() {
    if (myNumberFocusNode.hasFocus) {
      firstOrSecond = WhichTextField.first;
    } else if (myPinFocusNode.hasFocus) {
      firstOrSecond = WhichTextField.second;
    }
  }

  @override
  void initState() {
    textEditingController = MaskedTextController(
        mask: widget.outputMask != null ? widget.outputMask : '(000) 000-0000');
    searchController = SearchController();
    pinTextEditingController = TextEditingController();
    myNumberFocusNode = FocusNode()
      ..addListener(() {
        checkFocus();
      });
    myPinFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    textEditingController!.dispose();
    searchController!.dispose();
    pinTextEditingController!.dispose();
    myNumberFocusNode.dispose();
    super.dispose();
  }

  Future<List<String>> search(String value) {
    var suggestions = widget.searchHistory.where((searchResult) {
      final result = searchResult.toLowerCase();
      final input = value.toLowerCase();
      return result.contains(input);
    }).toList();

    return Future.value(suggestions);
  }

  _setText(String? value) async {
    if (firstOrSecond == WhichTextField.first) {
      if ((widget.enableDtmf == null || widget.enableDtmf!) && value != null)
        FlutterDtmf.playTone(
            digits: value.trim(), samplingRate: 8000, durationMs: 160);

      if (widget.keyPressed != null) widget.keyPressed!(value!);

      setState(() {
        _value += value!;
        textEditingController!.text = _value;
      });
    } else {
      setState(() {
        _symbol += value!;
        pinTextEditingController!.text = _symbol;
      });
    }
  }

  List<Widget> _getDialerButtons() {
    var rows = <Widget>[];
    var items = <Widget>[];

    for (var i = 0; i < mainTitle.length; i++) {
      if (i % 3 == 0 && i > 0) {
        rows.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items));
        rows.add(SizedBox(
          height: 12,
        ));
        items = <Widget>[];
      }

      items.add(DialButton(
        title: mainTitle[i],
        subtitle: subTitle[i],
        hideSubtitle: widget.hideSubtitle!,
        color: widget.buttonColor,
        textColor: widget.buttonTextColor,
        onTap: (value) {
          if (_value.length > 14) return;
          _setText(value);
        },
        buttonClipOvalRadius: widget.buttonClipOvalRadius,
        titleFontSize: widget.titleFontSize,
        subTitleFontSize: widget.subTitleFontSize,
        starIconSize: widget.starIconSize,
        callIconSize: widget.callIconSize,
        hashIconSize: widget.hashIconSize,
        plusFontSize: widget.plusFontSize,
      ));
    }
    //To Do: Fix this workaround for last row
    rows.add(
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items));
    rows.add(SizedBox(
      height: 12,
    ));

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * 0.09852217;

    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(height: 6),
          SizedBox(
            height: widget.heightSearchBar ?? 41,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: widget.searchContainerColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: SearchAnchor(
                              viewConstraints: widget.constraints,
                              searchController: searchController,
                              viewHintText: 'search...',
                              builder: (BuildContext context,
                                  SearchController controller) {
                                return IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    size: widget.searchIconSize,
                                  ),
                                  onPressed: () {
                                    controller.openView();
                                  },
                                );
                              },
                              suggestionsBuilder: (BuildContext context,
                                  SearchController controller) {
                                final searchFuture = search(controller.text);
                                return [
                                  FutureBuilder<List<String>>(
                                    future: searchFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        List<String>? list = snapshot.data;
                                        if (list != null) {
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: list.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return ListTile(
                                                title: Text(list[index]),
                                                onTap: () {
                                                  setState(() {
                                                    controller
                                                        .closeView(list[index]);
                                                  });
                                                },
                                              );
                                            },
                                          );
                                        }
                                      }
                                      return const LinearProgressIndicator();
                                    },
                                  )
                                ];

                                // return List<ListTile>.generate(
                                //     widget.searchHistory.length, (int index) {
                                //   final item = widget.searchHistory[index];
                                //   return ListTile(
                                //     title: Text(item),
                                //     onTap: () {
                                //       setState(() {
                                //         widget.makeCall!(item);
                                //         controller.closeView(item);
                                //       });
                                //     },
                                //   );
                                // });
                              }),

                          //  IconButton(
                          //                   onPressed: (){
                          //                   showSearch(context: context, delegate: MySearchDelegate(widget.searchResults));
                          // },
                          //  icon: Icon(Icons.search, ),),
                        )),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      // readOnly: true,
                      onChanged: (val) {
                        setState(() {
                          _value = val;
                        });
                      },
                      style: TextStyle(
                          color: widget.dialOutputTextColor ?? Colors.black,
                          fontSize:
                              widget.dialOutputTextFontSize ?? sizeFactor / 2),
                      textAlign: TextAlign.center,
                      decoration: widget.inputDecoration ??
                          InputDecoration(border: InputBorder.none),
                      controller: textEditingController,
                      focusNode: myNumberFocusNode,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 3,
          ),
          SizedBox(
            height: widget.heightSearchBar ?? 41,
            child: Row(children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_symbol.isNotEmpty) {
                        widget.makeCall!(_symbol);
                      }
                    },
                    child: Text(
                      'Ext/Pin:',
                    ),
                    style: ElevatedButton.styleFrom().copyWith(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8, right: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      if (mainTitle.contains(val)) {
                        setState(() {
                          _symbol = val;
                        });
                      }
                    },
                    style: TextStyle(
                        color: widget.dialOutputTextColor ?? Colors.black,
                        fontSize:
                            widget.dialOutputTextFontSize ?? sizeFactor / 2),
                    textAlign: TextAlign.center,
                    decoration: widget.inputDecoration ??
                        InputDecoration(border: InputBorder.none),
                    controller: pinTextEditingController,
                    focusNode: myPinFocusNode,
                  ),
                ),
              )
            ]),
          ),
          SizedBox(
            height: 6,
          ),
          ..._getDialerButtons(),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Expanded(
                child: widget.hideDialButton != null && widget.hideDialButton!
                    ? Container()
                    : Center(
                        child: DialButton(
                          icon: widget.dialButtonIcon != null
                              ? widget.dialButtonIcon
                              : Icons.phone,
                          color: widget.dialButtonColor != null
                              ? widget.dialButtonColor!
                              : Colors.green,
                          hideSubtitle: widget.hideSubtitle!,
                          onTap: (value) {
                            if (_value.isNotEmpty || _symbol.isNotEmpty) {
                              widget.makeCall!(_value);
                            }
                          },
                          buttonClipOvalRadius: widget.buttonClipOvalRadius,
                          titleFontSize: widget.titleFontSize,
                          subTitleFontSize: widget.subTitleFontSize,
                          starIconSize: widget.starIconSize,
                          callIconSize: widget.callIconSize,
                          hashIconSize: widget.hashIconSize,
                          plusFontSize: widget.plusFontSize,
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                    padding:
                        EdgeInsets.only(right: screenSize.height * 0.03685504),
                    child: GestureDetector(
                      child: Icon(
                        Icons.backspace,
                        size: widget.deleteButtonSize ?? sizeFactor / 2,
                        color: _value.length > 0
                            ? widget.backspaceButtonIconColor ??
                                Theme.of(context).colorScheme.error
                            : Colors.white24,
                      ),
                      onTap: _value.length > 0
                          ? () {
                              if (_value.length > 0) {
                                setState(() {
                                  _value =
                                      _value.substring(0, _value.length - 1);
                                  textEditingController!.text = _value;
                                });
                              }
                            }
                          : null,
                      onLongPress: _value.length > 0
                          ? () {
                              setState(() {
                                textEditingController!.clear();
                                _value = "";
                              });
                            }
                          : null,
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DialButton extends StatefulWidget {
  final Key? key;
  final String? title;
  final String? subtitle;
  final bool hideSubtitle;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final Color? iconColor;
  final ValueSetter<String?>? onTap;
  final bool? shouldAnimate;

  /// here is where I made some updates on the package
  final double? buttonClipOvalRadius;
  final double? titleFontSize;
  final double? subTitleFontSize;
  final double? starIconSize;
  final double? callIconSize;
  final double? hashIconSize;
  final double? plusFontSize;

  DialButton({
    this.key,
    this.title,
    this.subtitle,
    this.hideSubtitle = false,
    this.color,
    this.textColor,
    this.icon,
    this.iconColor,
    this.shouldAnimate,
    this.onTap,
    this.buttonClipOvalRadius = 60,
    this.titleFontSize = 12,
    this.subTitleFontSize = 10,
    this.starIconSize = 15,
    this.callIconSize = 15,
    this.hashIconSize = 12,
    this.plusFontSize,
  });

  @override
  _DialButtonState createState() => _DialButtonState();
}

class _DialButtonState extends State<DialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _colorTween;
  Timer? _timer;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _colorTween = ColorTween(
            begin: widget.color != null ? widget.color : Colors.white24,
            end: Colors.white)
        .animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
    if ((widget.shouldAnimate == null || widget.shouldAnimate!) &&
        _timer != null) _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * 0.09852217;

    return GestureDetector(
      onTap: () {
        if (this.widget.onTap != null) this.widget.onTap!(widget.title);

        if (widget.shouldAnimate == null || widget.shouldAnimate!) {
          if (_animationController.status == AnimationStatus.completed) {
            _animationController.reverse();
          } else {
            _animationController.forward();
            _timer = Timer(const Duration(milliseconds: 200), () {
              setState(() {
                _animationController.reverse();
              });
            });
          }
        }
      },
      child: ClipOval(
        child: AnimatedBuilder(
          animation: _colorTween,
          builder: (context, child) => Container(
            color: _colorTween.value,
            height: widget.buttonClipOvalRadius ?? sizeFactor,
            width: widget.buttonClipOvalRadius ?? sizeFactor,
            child: Center(
                child: widget.icon == null
                    ? widget.subtitle != null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                widget.title!,
                                style: TextStyle(
                                    fontSize:
                                        widget.titleFontSize ?? sizeFactor / 2,
                                    color: widget.textColor != null
                                        ? widget.textColor
                                        : Colors.white),
                              ),
                              if (!widget.hideSubtitle)
                                Text(widget.subtitle!,
                                    style: TextStyle(
                                        fontSize: widget.subtitle == "+"
                                            ? widget.subTitleFontSize! +
                                                widget.plusFontSize!
                                            : widget.subTitleFontSize,
                                        color: widget.textColor != null
                                            ? widget.textColor
                                            : Colors.white))
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                                top: widget.title == "*" ? 6 : 0),
                            child: Text(
                              widget.title!,
                              style: TextStyle(
                                  fontSize: widget.title == "*" &&
                                          widget.subtitle == null
                                      ? widget.starIconSize ??
                                          screenSize.height * 0.0862069
                                      : widget.hashIconSize ?? sizeFactor / 2,
                                  color: widget.textColor != null
                                      ? widget.textColor
                                      : Colors.white),
                            ))
                    : Icon(widget.icon,
                        size: widget.callIconSize ?? sizeFactor / 2,
                        color: widget.iconColor != null
                            ? widget.iconColor
                            : Colors.white)),
          ),
        ),
      ),
    );
  }
}


// class MySearchDelegate extends SearchDelegate{
//   MySearchDelegate(this.searchResults);
//   List<String> searchResults ;
//    @override
//   List<Widget>? buildActions(BuildContext context)  =>[ IconButton(onPressed: (){
//     if (query.isEmpty) {
//        close(context, null);
//     }else{
//     query = '';
//     }
//   }, icon: Icon(Icons.clear))];

//   @override
//   Widget? buildLeading(BuildContext context)  => IconButton(onPressed: () => close(context, null), icon: Icon(Icons.arrow_back));

//   @override
//   Widget buildResults(BuildContext context) {
//     // TODO: implement buildResults
//     throw UnimplementedError();
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     List<String> suggestions= [];
//     if(query.isNotEmpty){
//        suggestions = searchResults.where((searchResult){
//     final result = searchResult.toLowerCase();
//     final input = query.toLowerCase();
//     return result.contains(input);
//    }).toList();
//     }else{
//       suggestions = searchResults;
//     }
//    return ListView.builder(itemCount: suggestions.length,
//    itemBuilder: (context, index){
//     final suggestion = suggestions[index];

//     return ListTile(
//       title: Text(suggestion),
//       onTap: (){
//         query = suggestion;
//         // showResults(context);
//       },
//     );
//    },
//    );
//   }

// }
