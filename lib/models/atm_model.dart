class AtmModel implements Comparable<AtmModel> {
  String? id;
  String? otomasyonTipid;
  String? sunucuip;
  String? localip;
  String? baslik;
  String? name;
  String? makeCount;
  String? sunucuApi;
  String? localApi;
  int? paketTekrarZamani;
  String? otomasyonTip;
  String? regionId;
  bool? kontrol;
  int? islem;
  bool? isFav;
  bool? isConnectionSuccesCable;
  bool? isConnectionSuccesWireless;
  String? enlem;
  String? boylam;
  String? userId;
  String? userName;
  String? userSurname;
  String? disIP1;
  String? disIP2;

  AtmModel({
    this.id,
    this.otomasyonTipid,
    this.sunucuip,
    this.localip,
    this.baslik,
    this.sunucuApi,
    this.localApi,
    this.paketTekrarZamani,
    this.otomasyonTip,
    this.regionId,
    this.kontrol,
    this.islem,
    this.isFav = false,
    this.isConnectionSuccesCable,
    this.isConnectionSuccesWireless,
    this.enlem,
    this.boylam,
    this.userId,
    this.userName,
    this.userSurname,
    this.disIP1,
    this.disIP2,
    this.makeCount,
    this.name,
  });

  AtmModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    otomasyonTipid = json["otomasyonTipid"];
    sunucuip = json["sunucuip"];
    localip = json["localip"];
    baslik = json["baslik"];
    sunucuApi = json["sunucuApi"];
    localApi = json["localApi"];
    paketTekrarZamani = json["PaketTekrarZamani"];
    otomasyonTip = json["otomasyonTip"];
    regionId = json["RegionId"];
    kontrol = json["kontrol"];
    islem = json["islem"];
    enlem = json["Enlem"];
    boylam = json["Boylam"];
    userId = json["userId"];
    userName = json["userName"];
    userSurname = json["userSurname"];
    disIP1 = json["disIP1"];
    disIP2 = json["disIP2"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["otomasyonTipid"] = otomasyonTipid;
    data["sunucuip"] = sunucuip;
    data["localip"] = localip;
    data["baslik"] = baslik;
    data["sunucuApi"] = sunucuApi;
    data["localApi"] = localApi;
    data["PaketTekrarZamani"] = paketTekrarZamani;
    data["otomasyonTip"] = otomasyonTip;
    data["RegionId"] = regionId;
    data["kontrol"] = kontrol;
    data["islem"] = islem;
    data["Enlem"] = enlem;
    data["Boylam"] = boylam;
    data["userId"] = userId;
    data["userName"] = userName;
    data["userSurname"] = userSurname;
    data["disIP1"] = disIP1;
    data["disIP2"] = disIP2;
    return data;
  }


  @override
  int compareTo(AtmModel other) {
    return baslik?.compareTo(other.baslik.toString()) ?? 0;
  }
}
