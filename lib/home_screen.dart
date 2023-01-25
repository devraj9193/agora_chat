import 'package:agora_chat/utils/constants.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'models/agora_keys.dart';
import 'services/agora_chat_service.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController agoraUserIdController = TextEditingController();
  TextEditingController agoraUserTokenController = TextEditingController();

  bool isLoading = false;

  AgoraChatService? agoraChatService;

  @override
  void initState() {
    super.initState();
    agoraChatService = Provider.of<AgoraChatService>(context, listen: false);
    _initSDK();
    agoraUserIdController =
        TextEditingController(text: AgoraChatConfig.agoraUserId);
    agoraUserTokenController =
        TextEditingController(text: AgoraChatConfig.agoraUserToken);
    agoraUserIdController.addListener(() {
      setState(() {});
    });
    agoraUserTokenController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    agoraUserIdController.dispose();
    agoraUserTokenController.dispose();
  }

  void _initSDK() async {
    ChatOptions options = ChatOptions(
      appKey: AgoraChatConfig.appKey,
      autoLogin: false,
    );
    await ChatClient.getInstance.init(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: gWhiteColor,
        automaticallyImplyLeading: false,
        title: Text(
          "AGORA",
          style: TextStyle(
            color: kTextColor,
            fontSize: 10.sp,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              await agoraChatService?.signOut();
              Get.to(() => const HomeScreen());
            },
            child: const Icon(
              Icons.exit_to_app_sharp,
              color: gBlackColor,
            ),
          ),
          SizedBox(width: 2.w)
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  buildForm() {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            TextFormField(
              controller: agoraUserIdController,
              cursorColor: gMainColor,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.mail_outline_sharp,
                  color: gMainColor,
                  size: 15.sp,
                ),
                hintText: "Email",
                hintStyle: TextStyle(
                  fontFamily: "GothamBook",
                  color: gMainColor,
                  fontSize: 10.sp,
                ),
              ),
              style: TextStyle(
                  fontFamily: "GothamMedium",
                  color: gMainColor,
                  fontSize: 9.sp),
              textInputAction: TextInputAction.next,
              textAlign: TextAlign.start,
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 5.h),
            TextFormField(
              keyboardType: TextInputType.name,
              cursorColor: kSecondaryColor,
              controller: agoraUserTokenController,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                  fontFamily: "GothamMedium",
                  color: gMainColor,
                  fontSize: 9.sp),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock_outline_sharp,
                  color: gMainColor,
                  size: 15.sp,
                ),
                hintText: "Password",
                hintStyle: TextStyle(
                  fontFamily: "GothamBook",
                  color: gMainColor,
                  fontSize: 10.sp,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            GestureDetector(
              onTap: () async {
                print(agoraUserIdController.text.toString());
                print(agoraUserTokenController.text.toString());
                agoraChatService?.signIn(
                  agoraUserIdController.text.toString(),
                  agoraUserTokenController.text.toString(),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: gPrimaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Agora Login',
                  style: TextStyle(
                    color: gWhiteColor,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
