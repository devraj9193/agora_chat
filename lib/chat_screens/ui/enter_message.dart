import 'package:agora_chat/utils/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';
import '../../services/agora_chat_service.dart';
import '../../utils/constants.dart';
import 'package:http/http.dart' as http;

class TextFieldWidget extends StatefulWidget {
  final String senderId;
  const TextFieldWidget({super.key, required this.senderId});

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  final formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool showEmojiPicker = false;
  // MessageProvider? messageProvider;
  DateTime? typingTimestamp;
//  AgoraChatService? agoraChatService;

  List<PlatformFile> files = [];
  List<String> filesPath = [];

  File? _image;

  @override
  void initState() {
   // agoraChatService = Provider.of<AgoraChatService>(context, listen: false);
    super.initState();
    // _controller.addListener(_sendSignal);
  }

  @override
  Widget build(BuildContext context) {
    //messageProvider = Provider.of<MessageProvider>(context, listen: false);
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        child: Column(
          children: [
            // Consumer<SignalProvider>(
            //   builder: (_, signalMessages, __) => Container(
            //     padding: const EdgeInsets.only(left: 40, bottom: 5),
            //     alignment: Alignment.centerLeft,
            //     child: TypingIndicator(getTypingIndicatorContent(signalMessages)),
            //   ),
            // ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35.0),
                      boxShadow: const [
                        BoxShadow(
                            offset: Offset(1, 3),
                            blurRadius: 5,
                            color: Colors.grey)
                      ],
                    ),
                    child: TextField(
                      autocorrect: false,
                      enableInteractiveSelection: false,
                      controller: _controller,
                      style: TextStyle(
                          fontFamily: "GothamMedium",
                          color: gBlackColor,
                          fontSize: 10.sp),
                      decoration: InputDecoration(
                          hintText: 'Type a message...',
                          prefixIcon: kIsWeb
                              ? IconButton(
                                  icon: const Icon(Icons.abc_sharp),
                                  onPressed: () {})
                              : IconButton(
                                  icon:
                                      const Icon(Icons.emoji_emotions_outlined),
                                  onPressed: () {
                                    setState(() {
                                      showEmojiPicker = !showEmojiPicker;
                                    });
                                  }),
                          suffixIcon: InkWell(
                            onTap: () {
                              showAttachmentSheet(context);
                            },
                            child: const Icon(
                              Icons.attach_file_sharp,
                              color: gBlackColor,
                            ),
                          ),
                          hintStyle: TextStyle(
                            fontFamily: "GothamBook",
                            color: gBlackColor,
                            fontSize: 10.sp,
                          ),
                          border: InputBorder.none),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final qbService = Provider.of<AgoraChatService>(context, listen: false);
                    qbService.sendFileMessage(widget.senderId, '${files.single.path}');
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                            offset: Offset(1, 3),
                            blurRadius: 5,
                            color: Colors.grey)
                      ],
                      color: gWhiteColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: gBlackColor,
                    ),
                  ),
                ),
              ],
            ),
            showEmojiPicker
                ? Container(
                    height: MediaQuery.of(context).size.height * .3,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: selectEmoji())
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget selectEmoji() {
    return EmojiPicker(
        config: const Config(
            columns: 9, emojiSizeMax: 25, initCategory: Category.SMILEYS),
        onEmojiSelected: (_, emoji) {
          setState(() {
            _controller.text = _controller.text + emoji.emoji;
          });
        });
  }

  showAttachmentSheet(BuildContext context) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        enableDrag: false,
        builder: (ctx) {
          return Wrap(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      decoration: const BoxDecoration(
                          border: Border(
                        bottom: BorderSide(
                          color: gGreyColor,
                          width: 3.0,
                        ),
                      )),
                      child: const Text(
                        'Choose File Source',
                        style: TextStyle(
                          color: gPrimaryColor,
                          fontFamily: 'GothamMedium',
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        iconWithText(Icons.insert_drive_file, 'Document', () {
                          pickFromFile();
                          Navigator.pop(context);
                        }),
                        iconWithText(Icons.camera_enhance_outlined, 'Camera',
                            () {
                          getImageFromCamera();
                          Navigator.pop(context);
                        }),
                        iconWithText(Icons.image, 'Gallery', () {
                          getImageFromCamera(fromCamera: false);
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              )
            ],
          );
        });
  }

  iconWithText(IconData assetName, String optionName, VoidCallback onPress) {
    return GestureDetector(
      onTap: onPress,
      child: SizedBox(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: gPrimaryColor),
              child: Center(
                child: Icon(
                  assetName,
                  color: gMainColor,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              optionName,
              style: TextStyle(
                color: gBlackColor,
                fontSize: 9.sp,
                fontFamily: "GothamBook",
              ),
            )
          ],
        ),
      ),
    );
  }

  getFileSize(File file) {
    var size = file.lengthSync();
    num mb = num.parse((size / (1024 * 1024)).toStringAsFixed(2));
    return mb;
  }

  void pickFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      withReadStream: true,
      type: FileType.any,
      // allowedExtensions: ['pdf', 'jpg', 'png'],
      allowMultiple: false,
    );
    if (result == null) return;

    if (result.files.first.extension!.contains("pdf") ||
        result.files.first.extension!.contains("png") ||
        result.files.first.extension!.contains("jpg")) {
      if (getFileSize(File(result.paths.first!)) <= 10) {
        print("fileSize: ${getFileSize(File(result.paths.first!))}Mb");
        files.add(result.files.first);
        print(files);
      } else {
        buildSnackBar(
          "context",
          "File size must be < 10Mb",
        );
      }
    } else {
      buildSnackBar(
        "context",
        "Please select png/jpg/Pdf files",
      );
    }
    //  sendQbAttachment(files.first.path!, 'doc');
    setState(() {});
  }

  Future getImageFromCamera({bool fromCamera = true}) async {
    var image = await ImagePicker.platform.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 50);

    setState(() {
      _image = File(image!.path);
    });
    //  sendQbAttachment(_image!.path, 'photo');
    print("captured image: $_image");
  }

// void _sendSignal() async {
  //   if (_controller.text.isEmpty) {
  //     await messageProvider!.sendSignal('typing_off', widget.spaceId);
  //   } else if ((typingTimestamp == null ||
  //       _controller.text.length == 1 ||
  //       DateTime.now().difference(typingTimestamp!).inSeconds >=
  //           AgoraChatConfig.indicatorTimeout) &&
  //       _controller.text.isNotEmpty) {
  //     await messageProvider!.sendSignal('typing_on', widget.spaceId);
  //     typingTimestamp = DateTime.now();
  //   }
  // }

  // String getTypingIndicatorContent(SignalProvider signalProvider) {
  //   var typingString = '';
  //   var spaceSignal = signalProvider.signals[widget.spaceId];
  //   if (spaceSignal != null && spaceSignal.message == 'typing_on') {
  //     typingString =
  //     '${AgoraChatConfig.getUserById(AgoraChatConfig.agoraUserId)} is typing...';
  //     signalProvider.signals
  //         .removeWhere((channel, signal) => channel == widget.spaceId);
  //   }
  //   return typingString;
  // }
}
