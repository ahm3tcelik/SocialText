class User {
  String uid;
  String ad;
  String soyad;
  String email;
  String sifre;
  String photo_url;

  User({this.uid, this.ad, this.soyad, this.email, this.sifre, this.photo_url});

  void setClear() {
    uid =  "";
    ad = "";
    soyad = "";
    email = "";
    sifre = "";
    photo_url = "";
  }
}