// ignore_for_file: use_build_context_synchronously, unused_catch_clause
import 'dart:async';
import 'dart:io';
import 'package:atm_kontrol_sistemi/constants/web_url.dart';
import 'package:atm_kontrol_sistemi/models/atm_model.dart';
import 'package:atm_kontrol_sistemi/models/user_models.dart';
import 'package:atm_kontrol_sistemi/screens/homepage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:atm_kontrol_sistemi/constants/colors.dart';
import 'package:atm_kontrol_sistemi/constants/project_sizes.dart';
import 'package:atm_kontrol_sistemi/constants/project_strings.dart';
import 'package:atm_kontrol_sistemi/widgets/login_page_widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late Dio _dio;
  late final FToast ftoast;
  List<AtmModel>? atmList = [];
  bool _isLoading = false;
  int? color;

  @override
  initState() {
    ftoast = FToast();
    ftoast.init(context);
    super.initState();
    _dio = Dio(BaseOptions(baseUrl: WebUrl.baseUrl));
  }

  isLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  customShowDialog({String? message}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.25,
              height: MediaQuery.sizeOf(context).height * 0.3,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message ?? "",
                    textScaler: TextScaler.linear(1),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: ProjectColors.darkTheme,
                        ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.05,
                  ),
                  CircularProgressIndicator.adaptive(),
                ],
              ))),
        ),
      ),
    );
  }

  Future<void> postUser(UserModel model) async {
    try {
      customShowDialog(message: "Giriş bekleniyor ...");
      final response = await _dio
          .post("Url", data: model.toJson())
          .timeout(Duration(seconds: 30));
      if (response.statusCode == HttpStatus.ok) {
        final datas = response.data;
        if (datas is List) {
          atmList = datas.map((e) => AtmModel.fromJson(e)).toList();
          atmList?.sort();
        }

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => Homepage(
                atmModel: atmList,
                id: idController.text,
                password: passwordController.text,
                checkTimeOut: false,
                checkExit: false,
              ),
            ),
            (route) => false);
      }
      // accepted hatalı giriş için kullanılan kod
      if (response.statusCode == HttpStatus.accepted) {
        Navigator.pop(context);
        loginPageAlertDialog(context,
            message: LoginPageStrings.loginFaultEnterAlertText);
      }
    } on TimeoutException catch (e) {
      Navigator.pop(context);
      loginPageAlertDialog(context, message: AlertStrings.timeoutFaultAlert);
    } on DioException catch (e) {
      Navigator.pop(context);
      loginPageAlertDialog(context,
          message: LoginPageStrings.loginConnectionFaultAlertText);
    } catch (e) {
      Navigator.pop(context);
      loginPageAlertDialog(context,
          message: HomePageStrings.homePageUnknownExecption);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: ProjectColors.textTheme,
        body: _isLoading
            ? CircularProgressIndicator.adaptive()
            : Container(
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage(
                            "assets/images/desktop-background.png"))),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.2,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.sizeOf(context).height * 0.02),
                            child: Row(
                              children: [
                                Spacer(),
                                Expanded(
                                  child: CustomTextField(
                                    textEditingController: idController,
                                    hinText: LoginPageStrings.idHintText,
                                    iconData: Icons.manage_accounts,
                                    isObscure: false,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.sizeOf(context).height * 0.02),
                            child: Row(
                              children: [
                                Spacer(),
                                Expanded(
                                  child: CustomTextField(
                                    textEditingController: passwordController,
                                    hinText: LoginPageStrings.passwordHintText,
                                    iconData: Icons.key,
                                    isObscure: true,
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.sizeOf(context).height * 0.02),
                            child: CustomButton(
                              title: LoginPageStrings.loginButtonText,
                              onPressed: () async {
                                if (idController.text.isNotEmpty &&
                                    passwordController.text.isNotEmpty) {
                                  UserModel userModel = UserModel(
                                      username: idController.text,
                                      password: passwordController.text);
                                  try {
                                    await postUser(userModel);
                                  } on DioException catch (e) {
                                    Navigator.pop(context);
                                    loginPageAlertDialog(context,
                                        message: LoginPageStrings
                                            .loginConnectionFaultAlertText);
                                  }
                                } else {
                                  loginPageAlertDialog(context,
                                      message:
                                          LoginPageStrings.alertDialogueText);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }

  Future<dynamic> loginPageAlertDialog(BuildContext context,
      {String? message}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(BorderRadiusSizes.highRadius)),
          content: Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.sizeOf(context).height * 0.01,
                horizontal: MediaQuery.sizeOf(context).width * 0.01),
            child: Text(
              message ?? "",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: ProjectColors.darkTheme,
                  ),
            ),
          ),
        );
      },
    );
  }
}
