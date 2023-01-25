import 'package:agora_chat/chat_screens/ui/enter_message.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../services/agora_chat_service.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  const ChatScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? _messageContent;
  final List<String> _logText = [];

  ScrollController? _scrollController;

  AgoraChatService? agoraChatService;

  @override
  void initState() {
    super.initState();
    _addChatListener();
    agoraChatService = Provider.of<AgoraChatService>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController?.addListener(_scrollListener);
    final result = agoraChatService?.loadingMessage("ganesh00");
    print("RESULT: $result");
  }

  void _addChatListener() {
    ChatClient.getInstance.chatManager.addEventHandler(
      "UNIQUE_HANDLER_ID",
      ChatEventHandler(onMessagesReceived: onMessagesReceived),
    );
  }

  void _scrollListener() {
    double? maxScroll = _scrollController?.position.maxScrollExtent;
    double? currentScroll = _scrollController?.position.pixels;
    if (maxScroll == currentScroll && agoraChatService!.hasMore == true) {
      agoraChatService!.loadingMessage("ganesh00" ?? '');
    }
  }

  @override
  void dispose() {
    ChatClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("LENGTH: ${_logText.length}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: gWhiteColor,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
              onTap: () async {
                await agoraChatService?.signOut();
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: gBlackColor,
                size: 2.h,
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                radius: 2.h,
                backgroundImage:
                    const AssetImage("assets/images/Ellipse 232.png"),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              widget.userName,
              style: TextStyle(
                color: kTextColor,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.blueGrey[50]),
        child: Column(
          children: [
            Expanded(
              child: RawScrollbar(
                  isAlwaysShown: false,
                  thickness: 3,
                  controller: _scrollController,
                  radius: const Radius.circular(3),
                  thumbColor: gMainColor,
                  child: StreamBuilder(
                    stream: AgoraChatService().stream.stream
                        .asBroadcastStream(),
                    builder: (_, snapshot) {
                      print("snap.data: ${snapshot.data}");
                      if (snapshot.hasData) {
                        return buildMessageList(
                            snapshot.data as List<ChatMessage>);
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )),
            ),
            const TextFieldWidget(
              senderId: 'ganesh00',
            ),
          ], // Column children
        ),
      ),
    );
  }

  buildMessageList(List<ChatMessage> messageList) {
    return GroupedListView<ChatMessage, DateTime>(
      elements: messageList,
      order: GroupedListOrder.DESC,
      reverse: true,
      floatingHeader: true,
      useStickyGroupSeparators: true,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      groupBy: (ChatMessage message) {
        DateTime dt = DateTime.fromMillisecondsSinceEpoch(message.localTime);
        print("DateTime: $dt");
        return DateTime(dt.year, dt.month, dt.day);
      },
      // padding: EdgeInsets.symmetric(horizontal: 0.w),
      groupHeaderBuilder: (ChatMessage message) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7, bottom: 7),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: const BoxDecoration(
              color: Color(0xffd9e3f7),
              borderRadius: BorderRadius.all(
                Radius.circular(11),
              ),
            ),
            child: Text(
              _buildHeaderDate(message.localTime),
              style: TextStyle(
                fontFamily: "GothamBook",
                color: gBlackColor,
                fontSize: 8.sp,
              ),
            ),
          ),
        ],
      ),
      itemBuilder: (context, ChatMessage message) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(
          //     child: message.isIncoming
          //         ? _generateAvatarFromName(message.senderName)
          //         : null),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                crossAxisAlignment: (message.from != widget.userName)
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  IntrinsicWidth(
                    child: (message.body.type != "file")
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            // overflow: Overflow.visible,
                            // clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    left: 2.w, right: 2.w, bottom: 0.5.h),
                                constraints: BoxConstraints(maxWidth: 70.w),
                                margin: (message.from != widget.userName)
                                    ? EdgeInsets.only(
                                        top: 0.5.h, bottom: 0.5.h, left: 5)
                                    : EdgeInsets.only(
                                        top: 0.5.h, bottom: 0.5.h, right: 5),
                                // padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                                decoration: BoxDecoration(
                                  color: (message.from != widget.userName)
                                      ? gWhiteColor
                                      : gChatMeColor,
                                  boxShadow: (message.from != widget.userName)
                                      ? [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            offset: const Offset(2, 4),
                                            blurRadius: 10,
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            offset: const Offset(2, 4),
                                            blurRadius: 10,
                                          ),
                                        ],
                                  borderRadius: BorderRadius.circular(7),
                                  // BorderRadius.only(
                                  //     topLeft: const Radius.circular(18),
                                  //     topRight: const Radius.circular(18),
                                  //     bottomLeft: message.isIncoming
                                  //         ? const Radius.circular(0)
                                  //         : const Radius.circular(18),
                                  //     bottomRight: message.isIncoming
                                  //         ? const Radius.circular(18)
                                  //         : const Radius.circular(0),),
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "${message.body.type}",
                                        style: TextStyle(
                                            fontFamily: "GothamBook",
                                            height: 1.5,
                                            color: gBlackColor,
                                            fontSize: 10.sp),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 0.5.h),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children:
                                              _buildNameTimeHeader(message),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    // FutureBuilder(
                    //         future: _quickBloxService!.getQbAttachmentUrl(
                    //             message.qbMessage.attachments!.first!.id!),
                    //         builder: (_, imgUrl) {
                    //           print('imgUrl.hasError: ${imgUrl.hasError}');
                    //           if (imgUrl.hasData) {
                    //             QBFile? _file;
                    //             print(
                    //                 "imgUrl.runtimeType: ${imgUrl.data.runtimeType}");
                    //             _file = (imgUrl.data as Map)['file'];
                    //             // print('_file!.name: ${_file!.name}');
                    //             return Column(
                    //               crossAxisAlignment:
                    //                   CrossAxisAlignment.stretch,
                    //               children: [
                    //                 GestureDetector(
                    //                   onTap: () {
                    //                     if (message.qbMessage.attachments!
                    //                             .first!.type ==
                    //                         'application/pdf') {
                    //                       Navigator.push(
                    //                           context,
                    //                           PageRouteBuilder(
                    //                             opaque: false, // set to false
                    //                             pageBuilder: (_, __, ___) {
                    //                               return MealPdf(
                    //                                 pdfLink: (imgUrl.data
                    //                                     as Map)['url'],
                    //                               );
                    //                             },
                    //                           ));
                    //                     } else {
                    //                       Navigator.push(
                    //                           context,
                    //                           PageRouteBuilder(
                    //                             opaque: false, // set to false
                    //                             pageBuilder: (_, __, ___) {
                    //                               return showImageFullScreen(
                    //                                   (imgUrl.data
                    //                                       as Map)['url']);
                    //                             },
                    //                           ));
                    //                     }
                    //                   },
                    //                   child: Container(
                    //                     height: message.qbMessage.attachments!
                    //                                 .first!.type ==
                    //                             'application/pdf'
                    //                         ? null
                    //                         : 200,
                    //                     width: message.qbMessage.attachments!
                    //                                 .first!.type ==
                    //                             'application/pdf'
                    //                         ? null
                    //                         : 200,
                    //                     padding: EdgeInsets.only(
                    //                         left: 16,
                    //                         right: 16,
                    //                         top: 13,
                    //                         bottom: 13),
                    //                     constraints:
                    //                         BoxConstraints(maxWidth: 70.w),
                    //                     margin: message.isIncoming
                    //                         ? EdgeInsets.only(
                    //                             top: 1.h, bottom: 1.h, left: 5)
                    //                         : EdgeInsets.only(
                    //                             top: 1.h,
                    //                             bottom: 1.h,
                    //                             right: 5),
                    //                     // padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                    //                     decoration: (message.qbMessage
                    //                                 .attachments!.first!.type ==
                    //                             'application/pdf')
                    //                         ? BoxDecoration(
                    //                             color: message.isIncoming
                    //                                 ? gGreyColor
                    //                                     .withOpacity(0.2)
                    //                                 : gSecondaryColor,
                    //                             borderRadius: BorderRadius.only(
                    //                                 topLeft:
                    //                                     Radius.circular(18),
                    //                                 topRight:
                    //                                     Radius.circular(18),
                    //                                 bottomLeft: message.isIncoming
                    //                                     ? Radius.circular(0)
                    //                                     : Radius.circular(18),
                    //                                 bottomRight: message.isIncoming
                    //                                     ? Radius.circular(18)
                    //                                     : Radius.circular(0)))
                    //                         : BoxDecoration(
                    //                             image: DecorationImage(
                    //                                 filterQuality:
                    //                                     FilterQuality.high,
                    //                                 fit: BoxFit.fill,
                    //                                 image: CachedNetworkImageProvider((imgUrl.data as Map)['url'])),
                    //                             boxShadow: [BoxShadow(color: gGreyColor.withOpacity(0.5), blurRadius: 0.2)],
                    //                             borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: message.isIncoming ? Radius.circular(0) : Radius.circular(18), bottomRight: message.isIncoming ? Radius.circular(18) : Radius.circular(0))),
                    //                     child: (message.qbMessage.attachments!
                    //                                 .first!.type ==
                    //                             'application/pdf')
                    //                         ? (_file != null)
                    //                             ? Row(
                    //                                 mainAxisSize:
                    //                                     MainAxisSize.min,
                    //                                 children: [
                    //                                   Expanded(
                    //                                     child: Text(
                    //                                       _file.name ?? '',
                    //                                       maxLines: 2,
                    //                                       style: TextStyle(
                    //                                           fontSize: 10.sp,
                    //                                           fontFamily:
                    //                                               'GothamMedium',
                    //                                           color:
                    //                                               gWhiteColor),
                    //                                     ),
                    //                                   ),
                    //                                   IconButton(
                    //                                     icon: Icon(
                    //                                       Icons.download,
                    //                                       color: Colors.white,
                    //                                     ),
                    //                                     onPressed: () async {
                    //                                       if (_file != null) {
                    //                                         await _quickBloxService!
                    //                                             .downloadFile(
                    //                                                 (imgUrl.data
                    //                                                         as Map)[
                    //                                                     'url'],
                    //                                                 _file.name!)
                    //                                             .then((value) {
                    //                                           File file =
                    //                                               value as File;
                    //                                           showSnackbar(
                    //                                               context,
                    //                                               "file saved to ${file.path}");
                    //                                         }).onError((error,
                    //                                                 stackTrace) {
                    //                                           showSnackbar(
                    //                                               context,
                    //                                               "file download error");
                    //                                         });
                    //                                       }
                    //                                     },
                    //                                   )
                    //                                 ],
                    //                               )
                    //                             : null
                    //                         : null,
                    //                   ),
                    //                 ),
                    //                 Row(
                    //                   mainAxisSize: MainAxisSize.min,
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment.spaceBetween,
                    //                   children: _buildNameTimeHeader(message),
                    //                 )
                    //               ],
                    //             );
                    //           } else {
                    //             print("imgUrl.error: ${imgUrl.error}");
                    //             return SizedBox.shrink(
                    //                 child: Text('Not found'));
                    //           }
                    //           return SizedBox.shrink();
                    //         }),
                  )
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(top: 2.h),
          //   child: PopupMenuButton(
          //     offset: const Offset(0, 10),
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(5)),
          //     itemBuilder: (context) => [
          //       PopupMenuItem(
          //         child: GestureDetector(
          //           onTap: () {
          //             print("${message.qbMessage.body}");
          //             openDialog("${message.qbMessage.body}");
          //           },
          //           child: Row(
          //             children: [
          //               Icon(
          //                 Icons.shortcut_sharp,
          //                 color: gBlackColor,
          //                 size: 2.h,
          //               ),
          //               SizedBox(width: 2.w),
          //               Text(
          //                 "Forward",
          //                 style: TextStyle(
          //                     fontFamily: "GothamBook",
          //                     color: gBlackColor,
          //                     fontSize: 9.sp),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //     child: Icon(
          //       Icons.more_vert_sharp,
          //       size: 2.h,
          //       color: gGreyColor.withOpacity(0.5),
          //     ),
          //   ),
          // ),
        ],
      ),
      controller: _scrollController,
    );
  }

  String _buildHeaderDate(int? timeStamp) {
    String completedDate = "";
    DateFormat dayFormat = DateFormat("d MMMM");
    DateFormat lastYearFormat = DateFormat("dd.MM.yy");

    DateTime now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    var yesterday = DateTime(now.year, now.month, now.day - 1);

    timeStamp ??= 0;
    DateTime messageTime =
    DateTime.fromMicrosecondsSinceEpoch(timeStamp * 1000);
    DateTime messageDate =
    DateTime(messageTime.year, messageTime.month, messageTime.day);

    if (today == messageDate) {
      completedDate = "Today";
    } else if (yesterday == messageDate) {
      completedDate = "Yesterday";
    } else if (now.year == messageTime.year) {
      completedDate = dayFormat.format(messageTime);
    } else {
      completedDate = lastYearFormat.format(messageTime);
    }
    return completedDate;
  }


  List<Widget> _buildNameTimeHeader(message) {
    return <Widget>[
      // const Padding(padding: EdgeInsets.only(left: 16)),
      // _buildSenderName(message),
      // const Padding(padding: EdgeInsets.only(left: 7)),
      // const Expanded(child: SizedBox.shrink()),
      //  const Padding(padding: EdgeInsets.only(left: 3)),
      _buildDateSent(message),
      Padding(padding: EdgeInsets.only(left: 1.w)),
      message.isIncoming
          ? const SizedBox.shrink()
          : _buildMessageStatus(message),
    ];
  }

  Widget _buildMessageStatus(message) {
    var deliveredIds = message.qbMessage.deliveredIds;
    var readIds = message.qbMessage.readIds;
    // if (_dialogType == QBChatDialogTypes.PUBLIC_CHAT) {
    //   return SizedBox.shrink();
    // }
    if (readIds != null && readIds.length > 1) {
      return const Icon(
        Icons.done_all,
        color: Colors.blue,
        size: 14,
      );
    } else if (deliveredIds != null && deliveredIds.length > 1) {
      return const Icon(Icons.done_all, color: gGreyColor, size: 14);
    } else {
      return const Icon(Icons.done, color: gGreyColor, size: 14);
    }
  }

  Widget _buildSenderName(message) {
    return Text(message.senderName ?? "No name",
        maxLines: 1,
        style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black54));
  }

  Widget _buildDateSent(message) {
    // print("DateTime:${message.qbMessage.dateSent!}");
    return Text(
      _buildTime(message.qbMessage.dateSent!),
      maxLines: 1,
      style: TextStyle(
        fontSize: 7.sp,
        color: gTextColor,
        fontFamily: "GothamBook",
      ),
    );
  }

  String _buildTime(int timeStamp) {
    DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(timeStamp * 1000);
    String amPm = 'AM';
    if (dateTime.hour >= 12) {
      amPm = 'PM';
    }

    String hour = dateTime.hour.toString();
    if (dateTime.hour > 12) {
      hour = (dateTime.hour - 12).toString();
    }

    String minute = dateTime.minute.toString();
    if (dateTime.minute < 10) {
      minute = '0${dateTime.minute}';
    }
    return '$hour:$minute  $amPm';
  }

  void onMessagesReceived(List<ChatMessage> messages) {
    for (var msg in messages) {
      print("Loaded Messages: ${msg.body}");
      switch (msg.body.type) {
        case MessageType.TXT:
          {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            _addLogToConsole(
              "receive text message: ${body.content}, from: ${msg.from}",
            );
          }
          break;
        case MessageType.IMAGE:
          {
            _addLogToConsole(
              "receive image message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.VIDEO:
          {
            _addLogToConsole(
              "receive video message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.LOCATION:
          {
            _addLogToConsole(
              "receive location message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.VOICE:
          {
            _addLogToConsole(
              "receive voice message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.FILE:
          {
            _addLogToConsole(
              "receive image message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.CUSTOM:
          {
            _addLogToConsole(
              "receive custom message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.CMD:
          {
            // Receiving command messages does not trigger the `onMessagesReceived` event, but triggers the `onCmdMessagesReceived` event instead.
          }
          break;
      }
    }
  }

  void _addLogToConsole(String log) {
    _logText.add(_timeString + ": " + log);
    setState(() {
      // _scrollController?.jumpTo(_scrollController?.position.maxScrollExtent);
    });
  }

  String get _timeString {
    return DateTime.now().toString().split(".").first;
  }
}
