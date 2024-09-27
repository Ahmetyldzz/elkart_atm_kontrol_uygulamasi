// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously, unused_catch_clause
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:dart_ping/dart_ping.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:atm_kontrol_sistemi/constants/colors.dart';
import 'package:atm_kontrol_sistemi/constants/project_sizes.dart';
import 'package:atm_kontrol_sistemi/constants/project_strings.dart';
import 'package:atm_kontrol_sistemi/constants/web_url.dart';
import 'package:atm_kontrol_sistemi/models/atm_model.dart';
import 'package:atm_kontrol_sistemi/models/fav_model.dart';
import 'package:atm_kontrol_sistemi/screens/login_page.dart';
import 'package:atm_kontrol_sistemi/screens/web_view.dart';
import 'package:atm_kontrol_sistemi/widgets/home_page_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage(
      {super.key,
      this.atmModel,
      this.id,
      this.password,
      this.checkTimeOut,
      this.checkExit});
  final List<AtmModel>? atmModel;
  final String? id;
  final String? password;
  final bool? checkTimeOut;
  final bool? checkExit;
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late FToast fToast = FToast();
  late Dio _dio;
  String? _message;
  Isolate? isolate;
  ReceivePort? receivePort;
  StreamSubscription? receivePortSubscription;
  List<AtmModel>? tempAllList = [];
  List<AtmModel>? tempFavList = [];
  List<FavModel>? allFavList = [];
  List<AtmModel>? favList = [];
  bool _isLoading = false;
  bool _isCheckLoading = false;
  int pageCounter = 0;
  int statusPageCounter = 0;
  int statusPageCounterFav = 0;
  int listBy = 0;
  int? initColor;
  int statusCode = 0;
  List<String> urls = [];
  List<String>? splittedList = [];
  List<String>? atmTitleList = [];
  List<String>? atmCountList = [];
  List<String>? unSortedAtmTitleList = [];
  List<String>? unSortedAtmCountList = [];
  String? listByTitle = HomePageStrings.listByMakeDate;

  Timer? _timer;
  int _counter = 0;
  static const int _timeoutSeconds = 10;

  @override
  initState() {
    _loadValue();
    _setItem();
    addSplittedByList();
    setUrls();
    WidgetsBinding.instance.addObserver(this);
    _dio = Dio(BaseOptions(baseUrl: WebUrl.baseUrl));
    FavModel favModel = FavModel(userId: widget.atmModel?[0].userId);
    getAllFavorite(favModel);
    checkBool();
    _startTimer();
    startIsolate();
    checkExit();

    fToast.init(context);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      if (AppLifecycleState.paused == state) {
        //Uygulama pasue durumuna geçtiğinde isolate işlemleri kapanıyor.
        receivePort?.close();
        isolate?.kill(priority: Isolate.immediate);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    receivePortSubscription?.cancel();
    receivePort?.close();
    isolate?.kill(priority: Isolate.immediate);
    super.dispose();
  }

  // Ping atma işleminde dönen circular progress için bir sayaç.
  void _startTimer() {
    if (_isCheckLoading == false) {
      isCheckLoading();
      _counter = 0;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _counter++;
            if (_counter == _timeoutSeconds) {
              isCheckLoading();
              _timer?.cancel();
            }
          });
        }
      });
    }
  }

  // Ping işlemi yapılmaya devam ediyor mu etmiyor mu kontrol
  void isCheckLoading() {
    setState(() {
      _isCheckLoading = !_isCheckLoading;
    });
  }

  addSplittedByList() {
    //Başlık'ta yapım sırasına veya atm ismine göre sıralamak için ayırma işlemi
    for (var i = 0; i < (widget.atmModel?.length ?? 0); i++) {
      splittedList = widget.atmModel?[i].baslik?.split("-");
      for (var element in splittedList ?? []) {
        if (element is String) {
          if (element.startsWith("A")) {
            atmCountList?.add(element);
            unSortedAtmCountList?.add(element);
          } else {
            atmTitleList?.add(element);
            unSortedAtmTitleList?.add(element);
          }
        }
      }

      for (var element in unSortedAtmTitleList ?? []) {
        widget.atmModel?[i].name = element;
      }
      for (var element in unSortedAtmCountList ?? []) {
        widget.atmModel?[i].makeCount = element;
      }
    }
  }

  String turkishSortKey(String input) {
    const turkishAlphabet = {
      '0': '01',
      '1': '02',
      '2': '03',
      '3': '04',
      '4': '05',
      '5': '06',
      '6': '07',
      '7': '08',
      '8': '09',
      '9': '09',
      'a': '10',
      'b': '11',
      'c': '12',
      'ç': '13',
      'd': '14',
      'e': '15',
      'f': '16',
      'g': '17',
      'ğ': '18',
      'h': '19',
      'ı': '20',
      'i': '21',
      'j': '22',
      'k': '23',
      'l': '24',
      'm': '25',
      'n': '26',
      'o': '27',
      'ö': '28',
      'p': '29',
      'r': '30',
      's': '31',
      'ş': '32',
      't': '33',
      'u': '34',
      'ü': '35',
      'v': '36',
      'y': '37',
      'z': '38',
    };

    return input
        .toLowerCase()
        .split('')
        .map((char) => turkishAlphabet[char] ?? char)
        .join('');
  }

  splitList(int caseCount) {
    //Popup menu için cardların başlıklarını değiştirme
    switch (caseCount) {
      case 0: // Yapım sırasına göre listeleme
        for (int x = 0; x < (tempAllList?.length ?? 0); x++) {
          tempAllList?[x].baslik =
              "${tempAllList?[x].makeCount}-${tempAllList?[x].name}";
          tempAllList?[x].baslik?.toLowerCase();
        }
        tempAllList?.sort();
        listBy = 0;
      case 1: // Atm ismine göre sıralama
        for (int x = 0; x < (tempAllList?.length ?? 0); x++) {
          tempAllList?[x].baslik = "${tempAllList?[x].name}";
          tempAllList?[x].baslik?.toLowerCase();
        }
        tempAllList?.sort((a, b) => turkishSortKey(a.baslik ?? "")
            .compareTo(turkishSortKey(b.baslik ?? "")));

        listBy = 1;
        break;
      default:
    }

    setState(() {});
  }

  setUrls() {
    //Atm'lerin ip'lerini bir listeye aktarma işlemi
    for (var i = 0; i < (widget.atmModel?.length ?? 0); i++) {
      urls.add(widget.atmModel?[i].disIP1.toString() ?? "");
      urls.add(widget.atmModel?[i].disIP2.toString() ?? "");
    }
  }

  Future<void> startIsolate() async {
    // Bir isolate kullanarak ping atma işlemi
    if (widget.atmModel?.isNotEmpty ?? false) {
      receivePort = ReceivePort();
      try {
        isolate = await Isolate.spawn(periodicServiceCall, [
          receivePort!.sendPort,
          urls
        ]); // Gönderilen veri atm'lerin tüm ip'leri
        receivePort!.listen(
          (data) {
            setState(() {
              if (data is Map) {
                for (var i = 0; i < (tempAllList?.length ?? 0); i++) {
                  if (data["url"] ==
                          tempAllList?[i]
                              .disIP1 && // atm'lerin kablolu ağına atılan ping'in true olup olmadığını kontrol etmek
                      data["data"] == true) {
                    tempAllList?[i].isConnectionSuccesCable = true;
                  } else if (data["url"] ==
                          tempAllList?[i]
                              .disIP1 && // atm'lerin kablolu ağına atılan ping'in false olup olmadığını kontrol etmek
                      data["data"] == false) {
                    tempAllList?[i].isConnectionSuccesCable = false;
                  }
                  if (data["url"] ==
                          tempAllList?[i]
                              .disIP2 && //atm'lerin kablosuz ağına atılan ping'in true olup olmadığını kontrol etmek
                      data["data"] == true) {
                    tempAllList?[i].isConnectionSuccesWireless = true;
                  } else if (data["url"] ==
                          tempAllList?[i]
                              .disIP2 && //atm'lerin kablosuz ağına atılan ping'in false olup olmadığını kontrol etmek
                      data["data"] == false) {
                    tempAllList?[i].isConnectionSuccesWireless = false;
                  }
                }
              }

              Future.delayed(
                Duration(seconds: 15),
                () {
                  isolate?.kill();
                },
              );
            });
          },
        );
      } catch (e) {}
    }
  }

  Future<void> checkBool() async {
    //Kullanıcı operatör ekranıda 5dk boyunca ekrana dokunmazsa timeouta düşer ve bu sayfaya yönlendirme yapar.
    await Future.delayed(Duration(milliseconds: 300));

    if (widget.checkTimeOut == true) {
      alertMessageDialog(
        context,
        message: HomePageStrings.timeOutOperationScreen,
      ); // Bu yönlendirmeyi Kullanıcıya bildirmek için bir diyalog.
    }
  }

  Future<void> checkExit() async {
    //Kullanıcı operatör ekranını kapatmadan tableti pasue durumuna geçirebilir.
    await Future.delayed(Duration(milliseconds: 300));

    if (widget.checkExit == true) {
      alertMessageDialog(
        context,
        message: HomePageStrings.checkExitMessage,
      ); //Bu durumda kullanıcı operatör ekranından anasayfaya yönlendirilir ve bu kullanıcıya bir diyalogla bildirilir
    }
  }

  Future<void> _loadValue() async {
    // SharedPreferences kullanarak kullanıcın kayıt ettiği temayı uygulama başlangıcında uygulamak.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      initColor = (prefs.getInt('initColor') ?? 0);
    });
    setColors(initColor ?? 1);
  }

  // SharedPreferences'a değeri kaydet
  Future<void> _saveValue(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('initColor', value);
  }

  setColors(int color) {
    // Tema ayarlaması
    setState(() {
      switch (color) {
        case 0:
          ProjectColors.primaryColor = ProjectColors.primaryColor1;
          ProjectColors.secondaryColor = ProjectColors.secondaryColor1;
          ProjectColors.textTheme = ProjectColors.textTheme1;
          _saveValue(0);
        case 1:
          ProjectColors.primaryColor = ProjectColors.primaryColor2;
          ProjectColors.secondaryColor = ProjectColors.secondaryColor2;
          ProjectColors.textTheme = ProjectColors.textTheme2;
          _saveValue(1);
        case 2:
          ProjectColors.primaryColor = ProjectColors.primaryColor3;
          ProjectColors.secondaryColor = ProjectColors.secondaryColor3;
          ProjectColors.textTheme = ProjectColors.textTheme3;
          _saveValue(2);
        case 3:
          ProjectColors.primaryColor = ProjectColors.primaryColor4;
          ProjectColors.secondaryColor = ProjectColors.secondaryColor4;
          ProjectColors.textTheme = ProjectColors.textTheme4;
          _saveValue(3);
          break;
        default:
          ProjectColors.primaryColor = ProjectColors.midBlue;
      }
    });
  }

  setFavs() {
    //Gelen favoriler listesindeki atm id'lerine göre favorileri seçip bir atm modeline ekleme.
    favList?.clear();
    isLoading();
    for (var i = 0; i < (allFavList?.length ?? 0); i++) {
      for (var j = 0; j < (widget.atmModel?.length ?? 0); j++) {
        if (allFavList?[i].otomasyonId == widget.atmModel?[j].id) {
          favList?.add(widget.atmModel?[j] ?? AtmModel());
        }
      }
    }
    setFavStar(); // Card'daki favori yıldız iconunun durmunu günceleme
    _setFavItem(); // Favoriler listesini geçici bir listeye aktarma
    isLoading();
  }

  setFavStar() {
    //Card'daki favori yıldız iconunun durmunu günceleme
    for (var i = 0; i < (widget.atmModel?.length ?? 0); i++) {
      widget.atmModel?[i].isFav = false;
    }
    if (favList?.isNotEmpty ?? false) {
      for (var i = 0; i < (favList?.length ?? 0); i++) {
        for (var j = 0; j < (widget.atmModel?.length ?? 0); j++) {
          if (widget.atmModel?[j].id == favList?[i].id) {
            widget.atmModel?[j].isFav = true;
          }
        }
      }
    } else {
      for (var i = 0; i < (widget.atmModel?.length ?? 0); i++) {
        widget.atmModel?[i].isFav = false;
      }
    }
  }

  _setItem() {
    // Tüm atm listesini geçici bir listeye aktarmak
    tempAllList = widget.atmModel!;
    startIsolate();
  }

  _setFavItem() {
    // Tüm favoriler listesini geçici bir listeye aktarmak
    tempFavList = favList!;
  }

  showToast(message, {int? toastDuration}) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: ProjectColors.darkTheme,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check,
            color: ProjectColors.textTheme,
          ),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: ProjectColors.textTheme,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: toastDuration ?? 0),
    );
  }

  isLoading() {
    // Future işlemleri için işlemin bitip bitmediği kontrolü
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  customLoadingShowDialog({String? message, String? path}) async {
    // Future işlemlerinde kullanıcıya bilgi vermek için bir diyalog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(
        // Back butonu iptal
        canPop: false,
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
                    textScaler: TextScaler.linear(0.7),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: ProjectColors.darkTheme,
                        ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.05,
                  ),
                  Image.asset(path ??
                      ""), // Daha iyi anlaşılması adına bir mesaj ile alakalı bir icon gif
                ],
              ))),
        ),
      ),
    );
  }

  Future<dynamic> backButtonExitDialog(BuildContext context) {
    // Kullanıcı geri butonuna bastığında uyarı amaçlı bir diyalog
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.25,
                height: MediaQuery.sizeOf(context).height * 0.15,
                child: Column(
                  children: [
                    Expanded(
                      child: Text(
                        HomePageStrings.exitAlertMessage,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: ProjectColors.darkTheme, fontSize: 18),
                      ),
                    ),
                    Expanded(
                        child: Image.asset("assets/images/exit_icon_gif.gif")),
                  ],
                ),
              ),
              actions: [
                CustomTextButton(
                  text: "Hayır",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CustomTextButton(
                  text: "Evet",
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                )
              ],
            ));
  }

  Future<dynamic> alertMessageDialog(BuildContext context, {String? message}) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.2,
          height: MediaQuery.sizeOf(context).height * 0.25,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.sizeOf(context).height * 0.02),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      textScaler: TextScaler.linear(0.75),
                      message ?? "",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: ProjectColors.darkTheme,
                              ),
                    ),
                  ),
                  Expanded(
                      child: Image.asset("assets/images/error_icon_gif.gif")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkAuthority(BuildContext context,
      {String? path, String? localIP, String? toastMessage}) async {
    Dio _dio = Dio();
    _dio.options.followRedirects = false;
    _dio.options.validateStatus = (status) {
      // Dönen cevap bir html sayfası ve yönlendirme ve 302 dönüyor.
      if (status != null) {
        //302'i  DioException fırlatıyor.
        return (status < 400); // Onun için 302'i hata görmemesi için.
      }
      return false;
    };
    final response = await _dio
        .post(
          path ??
              "", //Burada yönledirilecek link için bir yetki kontrol yapılıyor.
        )
        .timeout(Duration(seconds: 30));
    if (response.statusCode == 200) {
      if (response.data.runtimeType == String) {
        alertMessageDialog(context, message: response.data);
      } else {}
    }
    if (response.statusCode == 302) {
      // Bu dönen cevabın bir yönlendirme (302) olduğu anlama geliyor.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewContainer(
            //Eğer yetki kontrolünden başarılı bir şekilde geçmişse  WebViewContainer sayfasına yönlendiriliyor.
            atmModel: widget.atmModel,
            id: widget.id,
            password: widget.password,
            localIP: localIP,
            url: path,
          ),
        ),
      );
      showToast(
        toastDuration: 5,
        toastMessage,
      );
    }
  }

  Future<void> getAllFavorite(FavModel model) async {
    // Tüm favoriler listesini api'den çekmek için kullanılan future işlem
    try {
      isLoading();
      final response = await _dio
          .get("Url", data: model.toJson())
          .timeout(Duration(seconds: 60));
      if (response.statusCode == HttpStatus.ok) {
        final datas = response.data;
        if (datas is String) {
          // Son kalan favoriler listesini sildiği zaman listeyi temizleme.
          if (allFavList?.length == 1) {
            allFavList?.clear();
          }
          setFavs(); // Favoriler durum güncelleme
          setActiveOrPassiveFav();
        }
        if (datas is List) {
          allFavList = datas.map((e) => FavModel.fromJson(e)).toList();
          allFavList?.sort();
          setFavs();
          setActiveOrPassiveFav();
        }
        isLoading();
      }
    } on DioException catch (e) {
      alertMessageDialog(context,
          message: HomePageStrings.getFavConnectionFaultMessage);
    } on TimeoutException catch (e) {
      alertMessageDialog(
        context,
        message: AlertStrings.timeoutFaultAlert,
      );
    }
  }

  Future<void> addDeleteOrUpdateFavorite(FavModel model,
      {String? atmName}) async {
    // Kullanıcı favoriler listesinde ekleme çıkarma veya favoriler listesinde kullanıcnın yaptığı sıralama güncellemesi.
    isLoading();
    try {
      final response = await _dio // Favoriler işlemi için 'post' isteği
          .post("Url", data: model.toJson())
          .timeout(Duration(seconds: 30));
      if (response.statusCode == HttpStatus.ok) {
        // 1 Başarılı favori eklendi
        if (response.data["value"] == "1") {
          getAllFavorite(model);
          setFavs();
          showToast("$atmName ${HomePageStrings.susccessfulyAddToFav}",
              toastDuration: 2);
        }
        //güncelleme yapıldığında 2 dönüyor.
        else if (response.data["value"] == "2") {
          //diğer durumda silme işlemi yapıyor
        } else {
          getAllFavorite(model);
          setFavs();
          showToast(
              "$atmName ${HomePageStrings.successfulyRemoveFromFavMessage}",
              toastDuration: 2);
        }
      }
    } on DioException catch (e) {
      alertMessageDialog(
        context,
        message: HomePageStrings.addFavConnectionFaultMessage,
      );
    } on TimeoutException catch (e) {
      alertMessageDialog(
        context,
        message: AlertStrings.timeoutFaultAlert,
      );
    }
    isLoading();
  }

  Future<int?> checkConnection(
      // Verilen url'de bir bağlantı var mı yok mu, onun kontrolü
      {String? ip,
      String? message,
      String? path}) async {
    customLoadingShowDialog(message: message, path: path);
    try {
      final response = await Dio()
          .get("Url") 
          .timeout(Duration(seconds: 15));
      statusCode = response.statusCode ?? 0;
      return response.statusCode;
    } on TimeoutException catch (e) {
      throw DioException(requestOptions: RequestOptions());
    }
  }

  void searchBox(String query) {
    // Atm'listesinde arama yapma
    List<AtmModel> results = [];
    List<AtmModel>? deneme = setActiveOrPassive();

    if (deneme?.isNotEmpty ?? false) {
      results = deneme!
          .where((element) =>
              element.baslik!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        tempAllList = results;
      });
    }
  }

  void searchFavBox(String query) {
    // Favoriler listesinde arama yapma
    List<AtmModel> results = [];
    List<AtmModel>? deneme = setActiveOrPassiveFav();
    if (deneme?.isNotEmpty ?? false) {
      results = deneme!
          .where((element) =>
              element.baslik!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        tempFavList = results;
      });
    }
  }

  List<AtmModel>? setActiveOrPassive() {
    // Atm'listelerinde kullanıcı sadece aktif olan veya pasif olan atm'leri görmesi
    switch (statusPageCounter) {
      case 0:
        return resetAllActiveOrPassive(); //Tüm atm'leri görüntüleme
      case 1:
        return selectActive(); // Aktif olan atm'leri görüntüleme
      case 2:
        return selectPassive(); // Pasif olan atm'leri görüntüleme
      default:
        ProjectColors.primaryColor = ProjectColors.midBlue;
    }
    return null;
  }

  List<AtmModel>? selectActive() {
    List<AtmModel> result = [];
    if (widget.atmModel?.isNotEmpty ?? false) {
      result = widget.atmModel!.where(
        (element) {
          // Atm'lerin kablolu veya kablosuz bağlanıtlarını kontrol ederek aktif olanları görüntüleme
          return !((element.isConnectionSuccesCable == false ||
                  element.isConnectionSuccesCable == null) &&
              (element.isConnectionSuccesWireless == false ||
                  element.isConnectionSuccesWireless == null));
        },
      ).toList();
      setState(() {
        tempAllList = result;
      });
    }
    return result;
  }

  List<AtmModel>? selectPassive() {
    List<AtmModel> result = [];
    if (widget.atmModel?.isNotEmpty ?? false) {
      result = widget.atmModel!.where(
        (element) {
          // Atm'lerin kablolu veya kablosuz bağlanıtlarını kontrol ederek pasif olanları görüntüleme
          return ((element.isConnectionSuccesCable == false ||
                  element.isConnectionSuccesCable == null) &&
              (element.isConnectionSuccesWireless == false ||
                  element.isConnectionSuccesWireless == null));
        },
      ).toList();
      setState(() {
        tempAllList = result;
      });
    }
    return result;
  }

  List<AtmModel>? resetAllActiveOrPassive() {
    // TÜm atm'leri listeleme
    List<AtmModel> result = [];
    if (widget.atmModel?.isNotEmpty ?? false) {
      result = widget.atmModel!.where(
        (element) {
          return true;
        },
      ).toList();
      setState(() {
        tempAllList = result;
      });
    }
    return result;
  }

  List<AtmModel>? setActiveOrPassiveFav() {
    // Favoriler'de aktif, pasif veya hepsini görüntüleme
    switch (statusPageCounterFav) {
      case 0:
        return resetAllActiveOrPassiveFav();
      case 1:
        return selectActiveFav();
      case 2:
        return selectPassiveFav();
      default:
        ProjectColors.primaryColor = ProjectColors.midBlue;
    }
    return null;
  }

  List<AtmModel>? selectActiveFav() {
    List<AtmModel> result = [];
    if (favList?.isNotEmpty ?? false) {
      result = favList!.where(
        (element) {
          // Favorilerde kablolu veya kablosuz ağını kontrol edip aktif olanları görüntüleme
          return !((element.isConnectionSuccesCable == false ||
                  element.isConnectionSuccesCable == null) &&
              (element.isConnectionSuccesWireless == false ||
                  element.isConnectionSuccesWireless == null));
        },
      ).toList();
      result.sort();
      setState(() {
        tempFavList = result;
      });
    }
    return result;
  }

  List<AtmModel>? selectPassiveFav() {
    List<AtmModel> result = [];
    if (favList?.isNotEmpty ?? false) {
      result = favList!.where(
        (element) {
          // Favorilerde kablolu veya kablosuz ağını kontrol edip pasif olanları görüntüleme
          return ((element.isConnectionSuccesCable == false ||
                  element.isConnectionSuccesCable == null) &&
              (element.isConnectionSuccesWireless == false ||
                  element.isConnectionSuccesWireless == null));
        },
      ).toList();
      result.sort();

      setState(() {
        tempFavList = result;
      });
    }
    return result;
  }

  List<AtmModel>? resetAllActiveOrPassiveFav() {
    List<AtmModel> result = [];
    if (favList?.isNotEmpty ?? false) {
      result = favList!.where(
        (element) {
          // Favorilerde tüm atm'leri görüntüleme
          return true;
        },
      ).toList();
      setState(() {
        tempFavList = result;
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          // Tablet geri butonuna basıldığında kullanıcıya çıkması uyarısını verme
          backButtonExitDialog(context);
        },
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(
                  FocusNode()); // Klavyednin odağını kaybettiriyor.
            },
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.12,
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                child: Image.asset(ImagePaths.goraImage)),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.04,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.01,
                            ),
                            Icon(
                              Icons.account_circle_outlined,
                              color: ProjectColors.secondaryColor,
                              size: MediaQuery.sizeOf(context).width * 0.03,
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.01,
                            ),
                            Text(
                                "${widget.atmModel?[0].userName} ${widget.atmModel?[0].userSurname?.toUpperCase()}"),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02,
                            ),
                            customPopUpMenu(), // Tema ayarı için popup menu
                            AppBarLogOut(), // Çıkış yapma butonu
                          ],
                        ),
                      ],
                    ),
                    floating: false,
                    pinned: false,
                    snap: false,
                    bottom: TabBar(
                      labelColor: ProjectColors.secondaryColor,
                      indicatorColor: ProjectColors.secondaryColor,
                      overlayColor:
                          MaterialStatePropertyAll(ProjectColors.overlayColor),
                      tabs: const <Tab>[
                        Tab(
                          text: "Tüm Atmler",
                        ),
                        Tab(text: "Favoriler"),
                      ], // <-- total of 2 tabs
                    ),
                  ),
                ];
              },
              body: Padding(
                padding: PaddinSizes.OuterFramePadding,
                child: TabBarView(children: [
                  _firstTabBaView(context),
                  _secondTabBarView(context),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _secondTabBarView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TitleText(
                      titleText: HomePageStrings.favATm,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: SearchTextField(
                      onChanged: (p1) => searchFavBox(p1),
                    ),
                  ),
                  Spacer(
                    flex: 3,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _isCheckLoading
                      ? Expanded(
                          flex: 45,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.sizeOf(context).width *
                                            0.02),
                                child: LoadingCircleProgress(),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          flex: 45,
                          child: RefreshButton(
                            onPressed: () {
                              startIsolate();
                              _startTimer();
                            },
                          ),
                        ),
                  Expanded(
                    flex: 55,
                    child: Row(
                      children: [
                        Spacer(
                          flex: 60,
                        ),
                        Expanded(
                          flex: 38,
                          child: SalomonBottomBar(
                            margin: EdgeInsets.zero,
                            itemPadding: EdgeInsets.zero,
                            selectedColorOpacity: 0.0,
                            currentIndex: statusPageCounterFav,
                            onTap: (pageIndex) {
                              setState(() {
                                statusPageCounterFav = pageIndex;
                                setActiveOrPassiveFav();
                              });
                            },
                            items: [
                              SalomonBottomBarItem(
                                icon: StatusSwitchChip(
                                  chipColor: statusPageCounterFav == 0
                                      ? ProjectColors.black
                                      : ProjectColors.white,
                                  text: "Hepsi",
                                  textIconColor: statusPageCounterFav == 0
                                      ? ProjectColors.white
                                      : ProjectColors.black,
                                  icon: Icons.all_inclusive_rounded,
                                ),
                                title: SizedBox(),
                              ),
                              SalomonBottomBarItem(
                                icon: StatusSwitchChip(
                                  chipColor: statusPageCounterFav == 1
                                      ? ProjectColors.checkIsAvaliableColor
                                      : ProjectColors.white,
                                  text: "Aktif",
                                  textIconColor: statusPageCounterFav == 1
                                      ? ProjectColors.white
                                      : ProjectColors.checkIsAvaliableColor,
                                  icon: Icons.cloud_done_rounded,
                                ),
                                title: SizedBox(),
                              ),
                              SalomonBottomBarItem(
                                icon: StatusSwitchChip(
                                  chipColor: statusPageCounterFav == 2
                                      ? ProjectColors.checkIsNotAvaliableColor
                                      : ProjectColors.white,
                                  text: "Pasif",
                                  textIconColor: statusPageCounterFav == 2
                                      ? ProjectColors.white
                                      : ProjectColors.checkIsNotAvaliableColor,
                                  icon: Icons.cloud_off_rounded,
                                ),
                                title: SizedBox(),
                              ),
                            ],
                          ),
                        ),
                        Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.02,
                  ),
                  Container(
                    color: ProjectColors.secondaryColor,
                    width: double.maxFinite,
                    height: MediaQuery.sizeOf(context).height * 0.0015,
                    child: Text(""),
                  ),
                ],
              ),
              _isLoading
                  ? Center(child: CircularProgressIndicator.adaptive())
                  : Expanded(
                      child: ReorderableGridView.builder(
                        dragEnabled: (statusPageCounterFav ==
                                    1 || // Favoriler listesinde pasif ve aktif görünümlerde kaydırma iptali
                                statusPageCounterFav == 2)
                            ? false
                            : true,
                        onReorder: (oldIndex, newIndex) async {
                          // Favoriler listesinde kaydırarak sıralama yapılabilme
                          AtmModel changeItem = tempFavList
                                  ?.removeAt(oldIndex) ??
                              AtmModel(); // Kaydırılan item silip yeni indexe ekleme
                          tempFavList?.insert(newIndex, changeItem);
                          List<FavModel> changedList = [];
                          if (oldIndex > newIndex) {
                            // Değişen item'ların indexlerini güncelleme
                            for (int x = newIndex; x <= oldIndex; x++) {
                              FavModel changedItem = FavModel(
                                  index: x.toString(),
                                  userId: tempFavList?[0].userId,
                                  otomasyonId: tempFavList?[x].id,
                                  status: 2);
                              changedList.add(changedItem);
                            }
                          } else {
                            for (int x = oldIndex; x <= newIndex; x++) {
                              FavModel changedItem = FavModel(
                                  index: x.toString(),
                                  userId: tempFavList?[0].userId,
                                  otomasyonId: tempFavList?[x].id,
                                  status: 2);
                              changedList.add(changedItem);
                            }
                          }
                          try {
                            for (var i = 0; i < changedList.length; i++) {
                              await addDeleteOrUpdateFavorite(changedList[i]);
                              setState(() {});
                            }
                            FavModel favModel = FavModel(
                              userId: tempAllList?[0].userId,
                            );
                            getAllFavorite(favModel);
                            setFavs();
                          } catch (e) {
                            alertMessageDialog(
                              context,
                              message:
                                  "Favorilerde değişkilik yapılamadı. Lütfen tekrar deneyiniz!",
                            );
                          }
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5),
                        itemCount: tempFavList?.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            key: ValueKey(index),
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.sizeOf(context).height * 0.015,
                                horizontal:
                                    MediaQuery.sizeOf(context).width * 0.01),
                            child: Stack(
                              children: [
                                CustomCommonUsedButton(
                                  iconData: Icons.star,
                                  deleteFav: () {
                                    FavModel favModel = FavModel(
                                      userId: tempAllList?[index].userId,
                                      otomasyonId: tempFavList?[index].id,
                                      status: 0,
                                    );
                                    addDeleteOrUpdateFavorite(favModel,
                                        atmName: tempFavList?[index].baslik);
                                  },
                                  textColor: (tempFavList?[index]
                                              .isConnectionSuccesCable ??
                                          false)
                                      ? ProjectColors.checkIsAvaliableColor
                                      : ProjectColors.checkIsNotAvaliableColor,
                                  path: (tempFavList?[index]
                                              .isConnectionSuccesCable ??
                                          false)
                                      ? "rj45_green_icon2.png"
                                      : "rj45_red_icon2.png",
                                  checkActiveOrPassive: ((tempFavList?[index]
                                              .isConnectionSuccesCable ??
                                          false) ||
                                      (tempFavList?[index]
                                              .isConnectionSuccesWireless ??
                                          false)),
                                  checkConnectionIconColorWireless:
                                      (tempFavList?[index]
                                                  .isConnectionSuccesWireless ??
                                              false)
                                          ? ProjectColors.checkIsAvaliableColor
                                          : ProjectColors
                                              .checkIsNotAvaliableColor,
                                  checkIconWireless: (tempFavList?[index]
                                              .isConnectionSuccesWireless ??
                                          false)
                                      ? Icons.wifi
                                      : Icons.wifi_off_rounded,
                                  contentTitle: tempFavList?[index].baslik,
                                  contentSubTitleIp1:
                                      (tempFavList?[index].disIP1?.isNotEmpty ??
                                              false)
                                          ? (tempFavList?[index].disIP1)
                                          : "Tanımlanmamış",
                                  contentSubTitleIp2:
                                      (tempFavList?[index].disIP2?.isNotEmpty ??
                                              false)
                                          ? (tempFavList?[index].disIP2)
                                          : "Tanımlanmamış",
                                  onTap: () async {
                                    if (tempFavList?[index]
                                            .disIP1
                                            ?.isNotEmpty ??
                                        false) {
                                      try {
                                        _message = AlertStrings.cableIsLoading;
                                        final response = await checkConnection(
                                            ip: tempFavList?[index].disIP1,
                                            message:
                                                "${tempFavList?[index].baslik} operatör ekranı'nın $_message",
                                            path:
                                                "assets/images/ethernet_icon_gif.gif");
                                        /* if (_isDialogOpen == false) {
                                        return;
                                      } */
                                        if (response == HttpStatus.ok) {
                                          // burada istek yolla devam eden abone işlemi bulunmakta

                                          try {
                                            final response = await Dio()
                                                .get(
                                                    "Url")
                                                .timeout(Duration(seconds: 30));
                                            if (response.statusCode == 200) {
                                              final datas = response.data;
                                              if (datas[HomePageStrings
                                                      .isAvaliableResponseMessageKey] ==
                                                  HomePageStrings
                                                      .isAvaliableResponseMessageFalse) {
                                                Navigator.pop(context);
                                                alertMessageDialog(
                                                  context,
                                                  message: HomePageStrings
                                                      .isNotAvaliableMessage,
                                                );
                                              }
                                              if (datas[HomePageStrings
                                                      .isAvaliableResponseMessageKey] ==
                                                  HomePageStrings
                                                      .isAvaliableResponseMessageTrue) {
                                                Navigator.pop(context);
                                                try {
                                                  await checkAuthority(context,
                                                      path:
                                                          "Url",
                                                      localIP:
                                                          tempFavList?[index]
                                                              .disIP1,
                                                      toastMessage:
                                                          "${tempFavList?[index].baslik} operatör ekranının ${AlertStrings.cableLoadedToast}");
                                                } on DioException catch (e) {
                                                  alertMessageDialog(context,
                                                      message:
                                                          "Bağlantı hatası!");
                                                }
                                              }
                                            }
                                          } on DioException catch (e) {
                                            alertMessageDialog(
                                              context,
                                              message: HomePageStrings
                                                  .isAvaliableChekConnectionCableFault,
                                            );
                                          } on TimeoutException catch (e) {
                                            alertMessageDialog(
                                              context,
                                              message: AlertStrings
                                                  .timeoutFaultAlert,
                                            );
                                          }
                                        }
                                      } on DioException catch (e) {
                                        Navigator.pop(context);
                                        if (tempFavList?[index]
                                                .disIP2
                                                ?.isNotEmpty ??
                                            false) {
                                          try {
                                            _message =
                                                AlertStrings.wirelessIsLoading;
                                            final response = await checkConnection(
                                                ip: tempFavList?[index].disIP2,
                                                message:
                                                    "${tempFavList?[index].baslik} operatör ekranı'nın $_message",
                                                path:
                                                    "assets/images/wifi_icon_gif.gif");
                                            if (response == HttpStatus.ok) {
                                              try {
                                                final response = await Dio()
                                                    .get(
                                                        "Url")
                                                    .timeout(
                                                        Duration(seconds: 30));
                                                if (response.statusCode ==
                                                    200) {
                                                  final datas = response.data;
                                                  if (datas[HomePageStrings
                                                          .isAvaliableResponseMessageKey] ==
                                                      HomePageStrings
                                                          .isAvaliableResponseMessageFalse) {
                                                    Navigator.pop(context);
                                                    alertMessageDialog(
                                                      context,
                                                      message: HomePageStrings
                                                          .isNotAvaliableMessage,
                                                    );
                                                  }
                                                  if (datas[HomePageStrings
                                                          .isAvaliableResponseMessageKey] ==
                                                      HomePageStrings
                                                          .isAvaliableResponseMessageTrue) {
                                                    Navigator.pop(context);
                                                    try {
                                                      await checkAuthority(
                                                          context,
                                                          path:
                                                              "Url",
                                                          localIP: tempFavList?[
                                                                  index]
                                                              .disIP2,
                                                          toastMessage:
                                                              "${tempFavList?[index].baslik} operatör ekranının ${AlertStrings.wirelessLoadedToast}");
                                                    } on DioException catch (e) {
                                                      alertMessageDialog(
                                                          context,
                                                          message:
                                                              "Bağlantı hatası!");
                                                    }
                                                  }
                                                }
                                              } on DioException catch (e) {
                                                alertMessageDialog(
                                                  context,
                                                  message: HomePageStrings
                                                      .isAvaliableCheckConnectionWirelessFault,
                                                );
                                              } on TimeoutException catch (e) {
                                                alertMessageDialog(
                                                  context,
                                                  message: AlertStrings
                                                      .timeoutFaultAlert,
                                                );
                                              }
                                            }
                                          } on DioException catch (e) {
                                            Navigator.pop(context);
                                            alertMessageDialog(
                                              context,
                                              message: HomePageStrings
                                                  .wirelessAndCableConnectionFault,
                                            );
                                          }
                                        } else {
                                          alertMessageDialog(
                                            context,
                                            message: HomePageStrings
                                                .noWirelessCableConnectionFault,
                                          );
                                        }
                                      }
                                    } else {
                                      if (tempFavList?[index]
                                              .disIP2
                                              ?.isNotEmpty ??
                                          false) {
                                        try {
                                          _message =
                                              AlertStrings.wirelessIsLoading;
                                          final response = await checkConnection(
                                              ip: tempFavList?[index].disIP2,
                                              message:
                                                  "${tempFavList?[index].baslik} operatör ekranı'nın $_message",
                                              path:
                                                  "assets/images/wifi_icon_gif.gif");
                                          if (response == HttpStatus.ok) {
                                            try {
                                              final response = await Dio()
                                                  .get(
                                                      "Url")
                                                  .timeout(
                                                      Duration(seconds: 30));
                                              if (response.statusCode == 200) {
                                                final datas = response.data;
                                                if (datas[HomePageStrings
                                                        .isAvaliableResponseMessageKey] ==
                                                    HomePageStrings
                                                        .isAvaliableResponseMessageFalse) {
                                                  Navigator.pop(context);
                                                  alertMessageDialog(
                                                    context,
                                                    message: HomePageStrings
                                                        .isNotAvaliableMessage,
                                                  );
                                                }
                                                if (datas[HomePageStrings
                                                        .isAvaliableResponseMessageKey] ==
                                                    HomePageStrings
                                                        .isAvaliableResponseMessageTrue) {
                                                  Navigator.pop(context);
                                                  try {
                                                    await checkAuthority(
                                                        context,
                                                        path:
                                                            "Url",
                                                        localIP:
                                                            tempFavList?[index]
                                                                .disIP2,
                                                        toastMessage:
                                                            "${tempFavList?[index].baslik} operatör ekranının ${AlertStrings.wirelessLoadedToast}");
                                                  } on DioException catch (e) {
                                                    alertMessageDialog(context,
                                                        message:
                                                            "Bağlantı hatası!");
                                                  }
                                                }
                                              }
                                            } on DioException catch (e) {
                                              alertMessageDialog(
                                                context,
                                                message: HomePageStrings
                                                    .isAvaliableCheckConnectionWirelessFault,
                                              );
                                            } on TimeoutException catch (e) {
                                              alertMessageDialog(
                                                context,
                                                message: AlertStrings
                                                    .timeoutFaultAlert,
                                              );
                                            }
                                          }
                                        } on DioException catch (e) {
                                          Navigator.pop(context);
                                          alertMessageDialog(
                                            context,
                                            message: HomePageStrings
                                                .wirelessAndCableConnectionFault,
                                          );
                                        }
                                      } else {
                                        alertMessageDialog(
                                          context,
                                          message:
                                              HomePageStrings.bothNoConnection,
                                        );
                                      }
                                    }
                                  },
                                ),
                                Visibility(
                                  visible: (!((tempFavList?[index]
                                              .isConnectionSuccesCable ??
                                          false) ||
                                      (tempFavList?[index]
                                              .isConnectionSuccesWireless ??
                                          false))),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                100, 0, 0, 0),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        height: double.maxFinite,
                                        width: double.maxFinite,
                                        child: Text(""),
                                      ),
                                      Center(
                                        child: Transform.scale(
                                            scale: 0.4,
                                            child: Image.asset(
                                                "assets/images/no_connection_gif.gif")),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              addDeleteOrUpdateFavorite(
                                                  FavModel(
                                                      otomasyonId:
                                                          tempFavList?[index]
                                                              .id,
                                                      userId:
                                                          tempFavList?[index]
                                                              .userId,
                                                      index: favList?.length
                                                          .toString(),
                                                      status: 0),
                                                  atmName: tempFavList?[index]
                                                      .baslik);
                                            },
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.05,
                                              height: MediaQuery.sizeOf(context)
                                                      .height *
                                                  0.08,
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  _firstTabBaView(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 30,
              child: Row(
                children: [
                  Expanded(
                    flex: 60,
                    child: Text(
                      HomePageStrings.allAtmTitle,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: ProjectColors.secondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                  Spacer(
                    flex: 40,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 40,
              child: SearchTextField(
                onChanged: (p1) => searchBox(p1),
              ),
            ),
            Spacer(
              flex: 15,
            ),
            Expanded(
              flex: 15,
              child: SalomonBottomBar(
                selectedColorOpacity: 0.1,
                itemPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width * 0.000,
                    vertical: MediaQuery.sizeOf(context).height * 0.000),
                selectedItemColor: ProjectColors.secondaryColor,
                unselectedItemColor: ProjectColors.darkTheme,
                currentIndex: pageCounter,
                onTap: (pageIndex) {
                  setState(() {
                    pageCounter = pageIndex;
                  });
                },
                items: [
                  SalomonBottomBarItem(
                    icon: Icon(Icons.view_comfy_alt_rounded),
                    title: SizedBox(),
                  ),
                  SalomonBottomBarItem(
                    icon: Icon(Icons.view_headline_rounded),
                    title: SizedBox(),
                  ),
                ],
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                flex: 4,
                child: Row(
                  children: [
                    _isCheckLoading
                        ? Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.sizeOf(context).width *
                                            0.02),
                                child: LoadingCircleProgress(),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              RefreshButton(onPressed: () {
                                startIsolate();
                                _startTimer();
                              }),
                            ],
                          ),
                    PopupMenuButton(
                      icon: IconTextRow(
                        text: listByTitle,
                      ),
                      itemBuilder: (context) {
                        return [
                          listByMenuItem(
                              onTap: () {
                                splitList(0);
                                listByTitle = HomePageStrings.listByMakeDate;
                              },
                              title: HomePageStrings.listByMakeDate),
                          listByMenuItem(
                              onTap: () {
                                splitList(1);
                                listByTitle = HomePageStrings.listByName;
                              },
                              title: HomePageStrings.listByName),
                        ];
                      },
                    ),
                  ],
                )),
            Expanded(
              flex: 6,
              child: Row(
                children: [
                  Spacer(
                    flex: 65,
                  ),
                  Expanded(
                    flex: 33,
                    child: SalomonBottomBar(
                      margin: EdgeInsets.zero,
                      itemPadding: EdgeInsets.zero,
                      selectedColorOpacity: 0.0,
                      currentIndex: statusPageCounter,
                      onTap: (pageIndex) {
                        setState(() {
                          statusPageCounter = pageIndex;
                          setActiveOrPassive();
                        });
                      },
                      items: [
                        SalomonBottomBarItem(
                          icon: StatusSwitchChip(
                            chipColor: statusPageCounter == 0
                                ? ProjectColors.black
                                : ProjectColors.white,
                            text: "Hepsi",
                            textIconColor: statusPageCounter == 0
                                ? ProjectColors.white
                                : ProjectColors.black,
                            icon: Icons.all_inclusive_rounded,
                          ),
                          title: SizedBox(),
                        ),
                        SalomonBottomBarItem(
                          icon: StatusSwitchChip(
                            chipColor: statusPageCounter == 1
                                ? ProjectColors.checkIsAvaliableColor
                                : ProjectColors.white,
                            text: "Aktif",
                            textIconColor: statusPageCounter == 1
                                ? ProjectColors.white
                                : ProjectColors.checkIsAvaliableColor,
                            icon: Icons.cloud_done_rounded,
                          ),
                          title: SizedBox(),
                        ),
                        SalomonBottomBarItem(
                          icon: StatusSwitchChip(
                            chipColor: statusPageCounter == 2
                                ? ProjectColors.checkIsNotAvaliableColor
                                : ProjectColors.white,
                            text: "Pasif",
                            textIconColor: statusPageCounter == 2
                                ? ProjectColors.white
                                : ProjectColors.checkIsNotAvaliableColor,
                            icon: Icons.cloud_off_rounded,
                          ),
                          title: SizedBox(),
                        ),
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.02,
        ),
        Container(
          color: ProjectColors.secondaryColor,
          width: double.maxFinite,
          height: MediaQuery.sizeOf(context).height * 0.0015,
          child: Text(""),
        ),
        _isLoading
            ? CircularProgressIndicator.adaptive()
            : Expanded(
                child: switch (pageCounter) {
                0 => masonryGridViewMid(),
                1 => masonryGridViewSmall(),
                int() => throw UnimplementedError(),
              }),
      ],
    );
  }

  PopupMenuItem<dynamic> listByMenuItem(
      {final void Function()? onTap, final String? title}) {
    return PopupMenuItem(onTap: onTap, child: Text(title ?? ""));
  }

  customPopUpMenu() {
    return PopupMenuButton(
      onSelected: (value) {
        setColors(value);
      },
      icon: Icon(
        Icons.color_lens,
        color: ProjectColors.secondaryColor,
        size: MediaQuery.sizeOf(context).width * 0.03,
      ),
      position: PopupMenuPosition.over,
      itemBuilder: (context) {
        return [
          customPopupMenuItem(context,
              color: ProjectColors.secondaryColor1,
              colorName: ColorsName.primaryColorNameFirst,
              value: 0),
          customPopupMenuItem(context,
              color: ProjectColors.secondaryColor2,
              colorName: ColorsName.primaryColorNameSecond,
              value: 1),
          customPopupMenuItem(context,
              color: ProjectColors.secondaryColor3,
              colorName: ColorsName.primaryColorNameThird,
              value: 2),
          customPopupMenuItem(context,
              color: ProjectColors.secondaryColor4,
              colorName: ColorsName.primaryColorNameFourth,
              value: 3),
        ];
      },
    );
  }

  PopupMenuItem<int> customPopupMenuItem(BuildContext context,
      {String? colorName, Color? color, int? value}) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      value: value,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width * 0.01),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 12,
                  ),
                ),
                Expanded(
                  child: SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.055,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      child: Text(
                        colorName ?? "Kırmızı",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: color,
                            ),
                      )),
                ),
                Spacer(),
              ],
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.01,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.sizeOf(context).width * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.045,
                    height: MediaQuery.sizeOf(context).height * 0.005,
                    color: color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  MasonryGridView masonryGridViewMid() {
    return MasonryGridView.builder(
      gridDelegate:
          SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemCount: tempAllList?.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.sizeOf(context).height * 0.02,
              horizontal: MediaQuery.sizeOf(context).width * 0.012),
          child: Stack(
            children: [
              CustomAllAtmItemMid(
                checkActiveOrPassive:
                    ((tempAllList?[index].isConnectionSuccesCable ?? false) ||
                        (tempAllList?[index].isConnectionSuccesWireless ??
                            false)),
                textColor:
                    (tempAllList?[index].isConnectionSuccesCable ?? false)
                        ? ProjectColors.checkIsAvaliableColor
                        : ProjectColors.checkIsNotAvaliableColor,
                path: (tempAllList?[index].isConnectionSuccesCable ?? false)
                    ? "rj45_green_icon2.png"
                    : "rj45_red_icon2.png",
                checkConnectionIconColorWireless:
                    (tempAllList?[index].isConnectionSuccesWireless ?? false)
                        ? ProjectColors.checkIsAvaliableColor
                        : ProjectColors.checkIsNotAvaliableColor,
                checkIconWireless:
                    (tempAllList?[index].isConnectionSuccesWireless ?? false)
                        ? Icons.wifi
                        : Icons.wifi_off_rounded,
                contentTitle: tempAllList?[index].baslik,
                contentSubTitleIp1:
                    (tempAllList?[index].disIP1?.isNotEmpty ?? false)
                        ? (tempAllList?[index].disIP1)
                        : "Tanımlanmamış",
                contentSubTitleIp2:
                    (tempAllList?[index].disIP2?.isNotEmpty ?? false)
                        ? (tempAllList?[index].disIP2)
                        : "Tanımlanmamış",
                goToLink: () async {
                  if (tempAllList?[index].disIP1?.isNotEmpty ?? false) {
                    try {
                      _message = AlertStrings.cableIsLoading;
                      final response = await checkConnection(
                        ip: tempAllList?[index].disIP1,
                        path: "assets/images/ethernet_icon_gif.gif",
                        message:
                            "${tempAllList?[index].baslik} operatör ekranı'nın $_message",
                      );
                      if (response == HttpStatus.ok) {
                        try {
                          final response = await Dio()
                              .get(
                                "Url",
                              )
                              .timeout(Duration(seconds: 30));
                          if (response.statusCode == 200) {
                            final datas = response.data;
                            if (datas[HomePageStrings
                                    .isAvaliableResponseMessageKey] ==
                                HomePageStrings
                                    .isAvaliableResponseMessageFalse) {
                              Navigator.pop(context);
                              alertMessageDialog(
                                context,
                                message: HomePageStrings.isNotAvaliableMessage,
                              );
                            }
                            if (datas[HomePageStrings
                                    .isAvaliableResponseMessageKey] ==
                                HomePageStrings
                                    .isAvaliableResponseMessageTrue) {
                              Navigator.pop(context);

                              try {
                                await checkAuthority(context,
                                    path:
                                        "Url",
                                    localIP: tempAllList?[index].disIP1,
                                    toastMessage:
                                        "${tempAllList?[index].baslik} operatör ekranının ${AlertStrings.cableLoadedToast}");
                              } on DioException catch (e) {
                                alertMessageDialog(context,
                                    message: "Bağlantı hatası!");
                              }
                            }
                          }
                        } on DioException catch (e) {
                          alertMessageDialog(
                            context,
                            message: HomePageStrings
                                .isAvaliableChekConnectionCableFault,
                          );
                        } on TimeoutException catch (e) {
                          alertMessageDialog(
                            context,
                            message: AlertStrings.timeoutFaultAlert,
                          );
                        }
                      }
                    } on DioException catch (e) {
                      Navigator.pop(context);
                      if (tempAllList?[index].disIP2?.isNotEmpty ?? false) {
                        try {
                          _message = AlertStrings.wirelessIsLoading;
                          final response = await checkConnection(
                              ip: tempAllList?[index].disIP2,
                              path: "assets/images/wifi_icon_gif.gif",
                              message:
                                  "${tempAllList?[index].baslik} operatör ekranı'nın $_message");
                          if (response == HttpStatus.ok) {
                            try {
                              final response = await Dio()
                                  .get(
                                      "Url")
                                  .timeout(Duration(seconds: 30));
                              if (response.statusCode == 200) {
                                final datas = response.data;
                                if (datas[HomePageStrings
                                        .isAvaliableResponseMessageKey] ==
                                    HomePageStrings
                                        .isAvaliableResponseMessageFalse) {
                                  Navigator.pop(context);
                                  alertMessageDialog(
                                    context,
                                    message:
                                        HomePageStrings.isNotAvaliableMessage,
                                  );
                                }
                                if (datas[HomePageStrings
                                        .isAvaliableResponseMessageKey] ==
                                    HomePageStrings
                                        .isAvaliableResponseMessageTrue) {
                                  Navigator.pop(context);
                                  try {
                                    await checkAuthority(context,
                                        path:
                                            "Url",
                                        localIP: tempAllList?[index].disIP2,
                                        toastMessage:
                                            "${tempAllList?[index].baslik} operatör ekranının ${AlertStrings.wirelessLoadedToast}");
                                  } on DioException catch (e) {
                                    alertMessageDialog(context,
                                        message: "Bağlantı hatası!");
                                  }
                                }
                              }
                            } on DioException catch (e) {
                              alertMessageDialog(
                                context,
                                message: HomePageStrings
                                    .isAvaliableCheckConnectionWirelessFault,
                              );
                            } on TimeoutException catch (e) {
                              alertMessageDialog(
                                context,
                                message: AlertStrings.timeoutFaultAlert,
                              );
                            }
                          }
                        } on DioException catch (e) {
                          Navigator.pop(context);
                          alertMessageDialog(
                            context,
                            message:
                                HomePageStrings.wirelessAndCableConnectionFault,
                          );
                        }
                      } else {
                        alertMessageDialog(
                          context,
                          message:
                              HomePageStrings.noWirelessCableConnectionFault,
                        );
                      }
                    }
                  } else {
                    if (tempAllList?[index].disIP2?.isNotEmpty ?? false) {
                      try {
                        _message = AlertStrings.wirelessIsLoading;
                        final response = await checkConnection(
                            ip: tempAllList?[index].disIP2,
                            path: "assets/images/wifi_icon_gif.gif",
                            message:
                                "${tempAllList?[index].baslik} operatör ekranı'nın $_message");
                        if (response == HttpStatus.ok) {
                          try {
                            final response = await Dio()
                                .get(
                                    "Url")
                                .timeout(Duration(seconds: 30));
                            if (response.statusCode == 200) {
                              final datas = response.data;
                              if (datas[HomePageStrings
                                      .isAvaliableResponseMessageKey] ==
                                  HomePageStrings
                                      .isAvaliableResponseMessageFalse) {
                                Navigator.pop(context);
                                alertMessageDialog(
                                  context,
                                  message:
                                      HomePageStrings.isNotAvaliableMessage,
                                );
                              }
                              if (datas[HomePageStrings
                                      .isAvaliableResponseMessageKey] ==
                                  HomePageStrings
                                      .isAvaliableResponseMessageTrue) {
                                Navigator.pop(context);
                                try {
                                  await checkAuthority(context,
                                      path:
                                          "Url",
                                      localIP: tempAllList?[index].disIP2,
                                      toastMessage:
                                          "${tempAllList?[index].baslik} operatör ekranının ${AlertStrings.wirelessLoadedToast}");
                                } on DioException catch (e) {
                                  alertMessageDialog(context,
                                      message: "Bağlantı hatası!");
                                }
                              }
                            }
                          } on DioException catch (e) {
                            alertMessageDialog(
                              context,
                              message: HomePageStrings
                                  .isAvaliableCheckConnectionWirelessFault,
                            );
                          } on TimeoutException catch (e) {
                            alertMessageDialog(
                              context,
                              message: AlertStrings.timeoutFaultAlert,
                            );
                          }
                        }
                      } on DioException catch (e) {
                        Navigator.pop(context);
                        alertMessageDialog(
                          context,
                          message:
                              HomePageStrings.wirelessAndCableConnectionFault,
                        );
                      }
                    } else {
                      alertMessageDialog(
                        context,
                        message: HomePageStrings.bothNoConnection,
                      );
                    }
                  }
                },
                iconData: (tempAllList?[index].isFav ?? false)
                    ? Icons.star
                    : Icons.star_border,
                addOrDeleteFav: () {
                  (tempAllList?[index].isFav ?? false)
                      ? addDeleteOrUpdateFavorite(
                          FavModel(
                              userId: tempAllList?[index].userId,
                              otomasyonId: tempAllList?[index].id,
                              status: 0),
                          atmName: tempAllList?[index].baslik)
                      : addDeleteOrUpdateFavorite(
                          FavModel(
                              otomasyonId: tempAllList?[index].id,
                              userId: tempAllList?[index].userId,
                              index: favList?.length.toString(),
                              status: 1),
                          atmName: tempAllList?[index].baslik);
                },
                infoPressed: () {},
              ),
              Visibility(
                visible: (!((tempAllList?[index].isConnectionSuccesCable ??
                        false) ||
                    (tempAllList?[index].isConnectionSuccesWireless ?? false))),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(100, 0, 0, 0),
                          borderRadius: BorderRadius.circular(12)),
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      height: MediaQuery.sizeOf(context).height * 0.25,
                      child: Text(""),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Center(
                          child: Transform.scale(
                              scale: 0.45,
                              child: Image.asset(
                                  "assets/images/no_connection_gif.gif")),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            (tempAllList?[index].isFav ?? false)
                                ? addDeleteOrUpdateFavorite(
                                    FavModel(
                                        userId: tempAllList?[index].userId,
                                        otomasyonId: tempAllList?[index].id,
                                        status: 0),
                                    atmName: tempAllList?[index].baslik)
                                : addDeleteOrUpdateFavorite(
                                    FavModel(
                                        otomasyonId: tempAllList?[index].id,
                                        userId: tempAllList?[index].userId,
                                        index: favList?.length.toString(),
                                        status: 1),
                                    atmName: tempAllList?[index].baslik);
                          },
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.05,
                            height: MediaQuery.sizeOf(context).height * 0.07,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  MasonryGridView masonryGridViewSmall() {
    return MasonryGridView.builder(
      gridDelegate:
          SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: tempAllList?.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.sizeOf(context).height * 0.02,
              horizontal: MediaQuery.sizeOf(context).width * 0.01),
          child: Stack(
            children: [
              CustomAllAtmItemSmall(
                checkActiveOrPassive:
                    ((tempAllList?[index].isConnectionSuccesCable ?? false) |
                        (tempAllList?[index].isConnectionSuccesWireless ??
                            false)),
                textColor:
                    (tempAllList?[index].isConnectionSuccesCable ?? false)
                        ? ProjectColors.checkIsAvaliableColor
                        : ProjectColors.checkIsNotAvaliableColor,
                path: (tempAllList?[index].isConnectionSuccesCable ?? false)
                    ? "rj45_green_icon2.png"
                    : "rj45_red_icon2.png",
                checkConnectionIconColorWireless:
                    (tempAllList?[index].isConnectionSuccesWireless ?? false)
                        ? ProjectColors.checkIsAvaliableColor
                        : ProjectColors.checkIsNotAvaliableColor,
                checkIconWireless:
                    (tempAllList?[index].isConnectionSuccesWireless ?? false)
                        ? Icons.wifi
                        : Icons.wifi_off_rounded,
                contentTitle: tempAllList?[index].baslik ?? "Baslik",
                contentSubTitleIP1:
                    (tempAllList?[index].disIP1?.isNotEmpty ?? false)
                        ? (tempAllList?[index].disIP1)
                        : "Tanımlanmamış",
                contentSubTitleIP2:
                    (tempAllList?[index].disIP2?.isNotEmpty ?? false)
                        ? (tempAllList?[index].disIP2)
                        : "Tanımlanmamış",
                goToLink: () async {
                  if (tempAllList?[index].disIP1?.isNotEmpty ?? false) {
                    try {
                      _message = AlertStrings.cableIsLoading;
                      final response = await checkConnection(
                          ip: tempAllList?[index].disIP1,
                          path: "assets/images/ethernet_icon_gif.gif",
                          message:
                              "${tempAllList?[index].baslik} operatör ekranı'nın $_message");
                      if (response == HttpStatus.ok) {
                        try {
                          final response = await Dio()
                              .get(
                                  "Url")
                              .timeout(Duration(seconds: 30));
                          if (response.statusCode == 200) {
                            final datas = response.data;
                            if (datas[HomePageStrings
                                    .isAvaliableResponseMessageKey] ==
                                HomePageStrings
                                    .isAvaliableResponseMessageFalse) {
                              Navigator.pop(context);
                              alertMessageDialog(
                                context,
                                message: HomePageStrings.isNotAvaliableMessage,
                              );
                            }
                            if (datas[HomePageStrings
                                    .isAvaliableResponseMessageKey] ==
                                HomePageStrings
                                    .isAvaliableResponseMessageTrue) {
                              Navigator.pop(context);
                              try {
                                await checkAuthority(context,
                                    path:
                                        "Url",
                                    localIP: tempAllList?[index].disIP1,
                                    toastMessage:
                                        "${tempAllList?[index].baslik} operatör ekranının ${AlertStrings.cableLoadedToast}");
                              } on DioException catch (e) {
                                alertMessageDialog(context,
                                    message: "Bağlantı hatası!");
                              }
                            }
                          }
                        } on DioException catch (e) {
                          alertMessageDialog(
                            context,
                            message: HomePageStrings
                                .isAvaliableChekConnectionCableFault,
                          );
                        } on TimeoutException catch (e) {
                          alertMessageDialog(
                            context,
                            message: AlertStrings.timeoutFaultAlert,
                          );
                        }
                      }
                    } on DioException catch (e) {
                      Navigator.pop(context);
                      if (tempAllList?[index].disIP2?.isNotEmpty ?? false) {
                        try {
                          _message = AlertStrings.wirelessIsLoading;
                          final response = await checkConnection(
                              ip: tempAllList?[index].disIP2,
                              path: "assets/images/wifi_icon_gif.gif",
                              message:
                                  "${tempAllList?[index].baslik} operatör ekranı'nın $_message");
                          if (response == HttpStatus.ok) {
                            try {
                              final response = await Dio()
                                  .get(
                                      "Url")
                                  .timeout(Duration(seconds: 30));
                              if (response.statusCode == 200) {
                                final datas = response.data;
                                if (datas[HomePageStrings
                                        .isAvaliableResponseMessageKey] ==
                                    HomePageStrings
                                        .isAvaliableResponseMessageFalse) {
                                  Navigator.pop(context);
                                  alertMessageDialog(
                                    context,
                                    message:
                                        HomePageStrings.isNotAvaliableMessage,
                                  );
                                }
                                if (datas[HomePageStrings
                                        .isAvaliableResponseMessageKey] ==
                                    HomePageStrings
                                        .isAvaliableResponseMessageTrue) {
                                  Navigator.pop(context);
                                  try {
                                    await checkAuthority(context,
                                        path:
                                            "Url",
                                        localIP: tempAllList?[index].disIP2,
                                        toastMessage:
                                            "${tempAllList?[index].baslik} operatör ekranının ${AlertStrings.wirelessLoadedToast}");
                                  } on DioException catch (e) {
                                    alertMessageDialog(context,
                                        message: "Bağlantı hatası!");
                                  }
                                }
                              }
                            } on DioException catch (e) {
                              alertMessageDialog(
                                context,
                                message: HomePageStrings
                                    .isAvaliableCheckConnectionWirelessFault,
                              );
                            } on TimeoutException catch (e) {
                              alertMessageDialog(
                                context,
                                message: AlertStrings.timeoutFaultAlert,
                              );
                            }
                          }
                        } on DioException catch (e) {
                          Navigator.pop(context);
                          alertMessageDialog(
                            context,
                            message:
                                HomePageStrings.wirelessAndCableConnectionFault,
                          );
                        }
                      } else {
                        alertMessageDialog(
                          context,
                          message:
                              HomePageStrings.noWirelessCableConnectionFault,
                        );
                      }
                    }
                  } else {
                    if (tempAllList?[index].disIP2?.isNotEmpty ?? false) {
                      try {
                        _message = AlertStrings.wirelessIsLoading;
                        final response = await checkConnection(
                            ip: tempAllList?[index].disIP2,
                            path: "assets/images/wifi_icon_gif.gif",
                            message:
                                "${tempAllList?[index].baslik} operatör ekranı'nın $_message");
                        if (response == HttpStatus.ok) {
                          try {
                            final response = await Dio()
                                .get(
                                    "Url")
                                .timeout(Duration(seconds: 30));
                            if (response.statusCode == 200) {
                              final datas = response.data;
                              if (datas[HomePageStrings
                                      .isAvaliableResponseMessageKey] ==
                                  HomePageStrings
                                      .isAvaliableResponseMessageFalse) {
                                Navigator.pop(context);
                                alertMessageDialog(
                                  context,
                                  message:
                                      HomePageStrings.isNotAvaliableMessage,
                                );
                              }
                              if (datas[HomePageStrings
                                      .isAvaliableResponseMessageKey] ==
                                  HomePageStrings
                                      .isAvaliableResponseMessageTrue) {
                                Navigator.pop(context);
                                try {
                                  await checkAuthority(context,
                                      path:
                                          "Url",
                                      localIP: tempAllList?[index].disIP2,
                                      toastMessage:
                                          "${tempAllList?[index].baslik} operatör ekranının ${AlertStrings.wirelessLoadedToast}");
                                } on DioException catch (e) {
                                  alertMessageDialog(context,
                                      message: "Bağlantı hatası!");
                                }
                              }
                            }
                          } on DioException catch (e) {
                            alertMessageDialog(
                              context,
                              message: HomePageStrings
                                  .isAvaliableCheckConnectionWirelessFault,
                            );
                          } on TimeoutException catch (e) {
                            alertMessageDialog(
                              context,
                              message: AlertStrings.timeoutFaultAlert,
                            );
                          }
                        }
                      } on DioException catch (e) {
                        Navigator.pop(context);
                        alertMessageDialog(
                          context,
                          message:
                              HomePageStrings.wirelessAndCableConnectionFault,
                        );
                      }
                    } else {
                      alertMessageDialog(
                        context,
                        message: HomePageStrings.bothNoConnection,
                      );
                    }
                  }
                },
                iconData: (tempAllList?[index].isFav ?? false)
                    ? Icons.star
                    : Icons.star_border,
                addOrDeleteFav: () {
                  (tempAllList?[index].isFav ?? false)
                      ? addDeleteOrUpdateFavorite(
                          FavModel(
                              userId: tempAllList?[index].userId,
                              otomasyonId: tempAllList?[index].id,
                              status: 0),
                          atmName: tempAllList?[index].baslik)
                      : addDeleteOrUpdateFavorite(
                          FavModel(
                              otomasyonId: tempAllList?[index].id,
                              userId: tempAllList?[index].userId,
                              index: favList?.length.toString(),
                              status: 1),
                          atmName: tempAllList?[index].baslik);
                },
                infoPressed: () {
                  //infoDialog(context, index);
                },
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.14,
                child: Visibility(
                  visible: (!((tempAllList?[index].isConnectionSuccesCable ??
                          false) ||
                      (tempAllList?[index].isConnectionSuccesWireless ??
                          false))),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(100, 0, 0, 0),
                            borderRadius: BorderRadius.circular(12)),
                        height: MediaQuery.sizeOf(context).height * 0.14,
                        width: double.maxFinite,
                        child: Text(""),
                      ),
                      Center(
                        child: Transform.scale(
                            scale: 0.4,
                            child: Image.asset(
                                "assets/images/no_connection_gif.gif")),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              (tempAllList?[index].isFav ?? false)
                                  ? addDeleteOrUpdateFavorite(
                                      FavModel(
                                          userId: tempAllList?[index].userId,
                                          otomasyonId: tempAllList?[index].id,
                                          status: 0),
                                      atmName: tempAllList?[index].baslik)
                                  : addDeleteOrUpdateFavorite(
                                      FavModel(
                                          otomasyonId: tempAllList?[index].id,
                                          userId: tempAllList?[index].userId,
                                          index: favList?.length.toString(),
                                          status: 1),
                                      atmName: tempAllList?[index].baslik);
                            },
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.04,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                              color: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({
    super.key,
    this.titleText,
  });
  final String? titleText;

  @override
  Widget build(BuildContext context) {
    return Text(
      titleText ?? "",
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: ProjectColors.secondaryColor,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    this.onPressed,
    this.text,
  });

  final void Function()? onPressed;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text ?? "",
        style: TextStyle(color: ProjectColors.secondaryColor),
      ),
    );
  }
}

class IconTextRow extends StatelessWidget {
  const IconTextRow({
    super.key,
    this.text,
  });
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Row(
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        CustomIcon(),
        SizedBox(
          width: 5,
        ),
        IconText(
          text: text,
        ),
      ],
    );
  }
}

class CustomIcon extends StatelessWidget {
  const CustomIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.sort_rounded,
      color: ProjectColors.secondaryColor,
    );
  }
}

class IconText extends StatelessWidget {
  const IconText({
    super.key,
    this.text,
  });
  final String? text;
  @override
  Widget build(BuildContext context) {
    return Text(
      textScaler: TextScaler.linear(0.7),
      text ?? "",
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: ProjectColors.secondaryColor,
          ),
    );
  }
}

class LoadingCircleProgress extends StatelessWidget {
  const LoadingCircleProgress({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.sizeOf(context).aspectRatio * 20,
        height: MediaQuery.sizeOf(context).aspectRatio * 20,
        child: CircularProgressIndicator.adaptive());
  }
}

class StatusSwitchChip extends StatelessWidget {
  const StatusSwitchChip({
    super.key,
    this.chipColor,
    this.textIconColor,
    this.text,
    this.icon,
  });

  final Color? chipColor;
  final Color? textIconColor;
  final String? text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: EdgeInsets.zero,
      color: WidgetStatePropertyAll(
        chipColor,
      ),
      side: BorderSide.none,
      label: Row(
        children: [
          Text(
            text ?? "",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: textIconColor,
                ),
          ),
          SizedBox(
            width: 5,
          ),
          Icon(
            icon,
            size: 16,
            color: textIconColor,
          ),
        ],
      ),
      shape: StadiumBorder(),
    );
  }
}

class ChipIconTextItem extends StatelessWidget {
  const ChipIconTextItem({
    super.key,
    this.textIconColor,
    this.text,
    this.icon,
  });

  final Color? textIconColor;
  final String? text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SwitchableText(
          color: textIconColor,
          text: text,
        ),
        SizedBox(
          width: 5,
        ),
        SwitchableIcon(
          iconColor: textIconColor,
          icon: icon,
        ),
      ],
    );
  }
}

class SwitchableIcon extends StatelessWidget {
  const SwitchableIcon({
    super.key,
    this.iconColor,
    this.icon,
  });
  final Color? iconColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 16,
      color: iconColor,
    );
  }
}

class SwitchableText extends StatelessWidget {
  const SwitchableText({
    super.key,
    this.text,
    this.color,
  });

  final String? text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
          ),
    );
  }
}

class RefreshButton extends StatelessWidget {
  const RefreshButton({
    super.key,
    required this.onPressed,
  });
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    enableFeedback: false,
                    shape: StadiumBorder(
                        side: BorderSide(
                            width: 0.5,
                            color: ProjectColors.secondaryColor ?? Colors.red)),
                    backgroundColor: ProjectColors.primaryColor),
                onPressed: onPressed,
                child: Icon(
                  Icons.refresh_rounded,
                  color: ProjectColors.secondaryColor,
                )),
          ],
        ),
      ],
    );
  }
}

class AppBarLogOut extends StatelessWidget {
  const AppBarLogOut({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.25,
                  height: MediaQuery.sizeOf(context).height * 0.15,
                  child: Column(
                    children: [
                      Expanded(
                        child: Text(
                          HomePageStrings.logoutDialogueText,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: ProjectColors.darkTheme, fontSize: 18),
                        ),
                      ),
                      Expanded(
                          child:
                              Image.asset("assets/images/exit_icon_gif.gif")),
                    ],
                  ),
                ),
                actions: [
                  AlertDialogueButton(
                    onPressed: () => Navigator.pop(context),
                    text: "Hayır",
                  ),
                  AlertDialogueButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                        (route) => false),
                    text: "Evet ",
                  ),
                ],
              );
            },
          );
          //logout
        },
        icon: Icon(
          color: ProjectColors.secondaryColor,
          Icons.logout_rounded,
          size: MediaQuery.sizeOf(context).width * 0.03,
        ));
  }
}

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
    required this.onChanged,
  });

  final void Function(String p1)? onChanged;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  Widget build(BuildContext context) {
    return Card(
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 1,
            color: ProjectColors.secondaryColor ?? Colors.transparent),
        borderRadius: BorderRadius.circular(BorderRadiusSizes.circleRadius),
      ),
      color: Color.fromARGB(255, 241, 239, 238),
      elevation: 5,
      child: TextField(
        autofocus: false,
        onChanged: widget.onChanged,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: ProjectColors.secondaryColor,
            ),
        decoration: InputDecoration(
            hintText: HomePageStrings.searcBarHintText,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: ProjectColors.secondaryColor,
                ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: ProjectColors.secondaryColor,
            )),
      ),
    );
  }
}

Future<void> periodicServiceCall(List<dynamic> args) async {
  SendPort sendPort = args[0];
  List<String> path = args[1];
  try {
    Future.wait(path.map(
      (url) async {
        try {
          final ping = Ping(url, count: 1);
          ping.stream.listen((event) {
            if (event.response != null) {
              sendPort.send({"url": url, "data": true});
            } else if (event.response == null && event.summary?.received == 0) {
              sendPort.send({"url": url, "data": false});
            }
          });
        } catch (e) {
          sendPort.send({"url": url, "data": false});
        }
      },
    ));
  } catch (e) {
    sendPort.send({"url": "", "data": false});
  }
}
