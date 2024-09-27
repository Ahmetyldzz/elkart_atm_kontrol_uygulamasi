// ignore_for_file: unused_local_variable
import 'dart:async';
import 'dart:io';
import 'package:atm_kontrol_sistemi/constants/colors.dart';
import 'package:atm_kontrol_sistemi/constants/project_strings.dart';
import 'package:atm_kontrol_sistemi/models/atm_model.dart';
import 'package:atm_kontrol_sistemi/models/fav_model.dart';
import 'package:atm_kontrol_sistemi/screens/homepage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulWidget {
  const WebViewContainer(
      {super.key,
      this.url,
      this.atmModel,
      this.favModel,
      this.id,
      this.password,
      this.localIP});
  final String? url;
  final List<AtmModel>? atmModel;
  final List<FavModel>? favModel;
  final String? id;
  final String? password;
  final String? localIP;

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer>
    with WidgetsBindingObserver {
  late final controller;
  Timer? _timer;
  int _counter = 0;
  static const int _timeoutSeconds = 180;
  bool hereClosed = false;
  bool isExit = false;
  @override
  void initState() {
    _startTimer();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.url.toString()));
    } catch (e) {
      print(e);
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Var olan zamanlayıcıyı iptal et
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _counter++;
        if (_counter >= _timeoutSeconds) {
          _timer?.cancel();
        }
      });
      if (_counter == _timeoutSeconds) {
        _onTimeout();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel(); // Var olan zamanlayıcıyı iptal et
    setState(() {
      _counter = 0; // Sayaç sıfırlanır
    });
    _startTimer(); // Zamanlayıcı yeniden başlatılır
  }

  Future<void> _onTimeout() async {
    _timer?.cancel();
    // Zaman aşımı durumunda yapılacak işlemler
    hereClosed = true;
    await logOut();
    _startTimer(); // Zaman aşımında da zamanlayıcı yeniden başlatılır
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      isExit = true;
      await logOut();
    }
  }

  Future<void> logOut() async {
    try {
      final response = await Dio()
          .get("Url")
          .timeout(Duration(seconds: 30));
      if (response.statusCode == HttpStatus.ok) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(
              atmModel: widget.atmModel,
              id: widget.id,
              password: widget.password,
              checkTimeOut: hereClosed,
              checkExit: isExit,
            ),
          ),
          (route) => false,
        );
      }
      // ignore: unused_catch_clause
    } on DioException catch (e) {
      Navigator.pop(context);
      Navigator.pop(context);
      alertDialog(message: WebViewStrings.faultLogOutAlert);
    } on TimeoutException catch (e) {
      Navigator.pop(context);
      Navigator.pop(context);
      alertDialog(message: AlertStrings.timeoutFaultAlert);
    }
  }

  Future<dynamic> alertDialog({String? message}) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          message ?? "",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: ProjectColors.darkTheme),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmationDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ProjectColors.red,
          leading: IconButton(
              onPressed: () {
                _logOutDialog(
                  context,
                  message: WebViewStrings.exitAlert,
                  yesButton: () {
                    customLoadingShowDialog(
                      message: WebViewStrings.exitLoadingAlert,
                    );
                    logOut();
                  },
                  noButton: () {
                    Navigator.pop(context);
                  },
                );
              },
              icon: Icon(
                Icons.exit_to_app_rounded,
                color: ProjectColors.white,
                size: 36,
              )),
        ),
        body: SizedBox(
          child: Listener(
              onPointerMove: (event) {
                _resetTimer();
              },
              child: WebViewWidget(controller: controller)),
        ),
      ),
    );
  }

  customLoadingShowDialog({String? message, String? path}) async {
    // Future işlemlerinde kullanıcıya bilgi vermek için bir diyalog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => PopScope(
        // Back butonu iptal
        canPop: true,
        child: AlertDialog(
          content: SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.2,
              height: MediaQuery.sizeOf(context).height * 0.25,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message ?? "", //Kullanıcıya verilen bilgi
                    textScaler: TextScaler.linear(0.9),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: ProjectColors.darkTheme,
                        ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.05,
                  ),
                  SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator
                          .adaptive()), // Daha iyi anlaşılması adına bir mesaj ile alakalı bir icon gif
                ],
              ))),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Uyarı',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ProjectColors.darkTheme, fontWeight: FontWeight.bold),
            ),
            content: Text(
              WebViewStrings.backButtonExitAlert,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: ProjectColors.darkTheme,
                    fontSize: 20,
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Hayır',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ProjectColors.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              TextButton(
                onPressed: () async {
                  await logOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Homepage(
                        atmModel: widget.atmModel,
                        id: widget.id,
                        password: widget.password,
                        checkTimeOut: hereClosed,
                        checkExit: isExit,
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 5, left: 5),
                  child: Text('Evet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: ProjectColors.secondaryColor,
                            fontWeight: FontWeight.w600,
                          )),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  _logOutDialog(BuildContext context,
      {String? message,
      void Function()? yesButton,
      void Function()? noButton}) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Text(
            message ?? "",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: ProjectColors.darkTheme),
          ),
        ),
        actions: [
          TextButton(
            onPressed: noButton,
            child: Text(
              "Hayır",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: ProjectColors.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          TextButton(
            onPressed: yesButton,
            child: Text(
              "Evet ",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: ProjectColors.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
