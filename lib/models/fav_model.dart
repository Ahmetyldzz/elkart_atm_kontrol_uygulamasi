class FavModel implements Comparable<FavModel> {
  int? id;
  String? userId;
  String? otomasyonId;
  String? index;
  String? positionLeft;
  int? status;
  String? user;
  String? otomasyon;

  FavModel(
      {this.id,
      this.userId,
      this.otomasyonId,
      this.index,
      this.positionLeft,
      this.status,
      this.user,
      this.otomasyon});

  FavModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    userId = json['UserId'];
    otomasyonId = json['otomasyonId'];
    positionLeft = json['PositionLeft'];
    status = json['status'];
    user = json['User'];
    otomasyon = json['otomasyon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['UserId'] = this.userId;
    data['otomasyonId'] = this.otomasyonId;
    data['index'] = this.index;
    data['PositionLeft'] = this.positionLeft;
    data['status'] = this.status;
    data['User'] = this.user;
    data['otomasyon'] = this.otomasyon;
    return data;
  }
  
   @override
  int compareTo(FavModel other) {
    return int.parse(positionLeft ?? "0").compareTo(int.parse(other.positionLeft ?? "0"));
  }
}