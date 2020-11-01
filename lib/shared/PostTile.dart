import 'package:social_text/Helper/ImageHelper.dart';
import 'package:social_text/helper/app_localizations.dart';
import 'package:social_text/models/Post.dart';
import 'package:social_text/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'FullImagePage.dart';

class PostTile extends StatelessWidget {
  final bool isAuthor;
  final Post post;
  final Function delete;
  final Function update;
  final BuildContext context;
  String dateTxt;

  PostTile({@required this.context, this.isAuthor, this.post, this.update, this.delete});

  String getDate(Duration dr) {
    if (dr.inDays >= 365) {
      // 1 yıl önce
      return "${(dr.inDays / 365).round()} " + AppLocalizations.of(context).translate('years_ago');
    } else if (dr.inDays >= 7) {
      // 1 hafta önce
      return "${(dr.inDays / 7).round()} " + AppLocalizations.of(context).translate('weeks_ago');
    } else if (dr.inDays >= 1) {
      // 1 gün önce
      return "${dr.inDays} " + AppLocalizations.of(context).translate('days_ago');
    } else if (dr.inHours >= 1) {
      // 1 saat önce
      return "${dr.inHours} " + AppLocalizations.of(context).translate('hours_ago');
    } else if (dr.inMinutes >= 1) {
      return "${dr.inMinutes} " + AppLocalizations.of(context).translate('minutes_ago');
    } else if (dr.inSeconds >= 1) {
      // saniye önce
      return "${dr.inSeconds} " + AppLocalizations.of(context).translate('seconds_ago');
    } else {
      return AppLocalizations.of(context).translate('now');
    }
  }

  Function onTapVert(int value) {
    switch (value) {
      case 0:
        update.call();
        break;
      case 1:
        delete.call();
        break;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime dt = post.date.toDate();
    Duration dr = DateTime.now().difference(dt);
    dateTxt = getDate(dr);
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        elevation: 10,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            DecoratedBox(
              position: DecorationPosition.background,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      child: ClipOval(
                          child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullImagePage(
                                      imageUrl: post.author.photo_url,
                                      imageAsset: ImageHelper.defaultLogoPath,
                                      title:
                                          "${post.author.ad} ${post.author.soyad}",
                                      subtitle: AppLocalizations.of(context).translate('profile_photo'))));
                        },
                        child: ImageHelper.getImage(
                            fit: BoxFit.fill,
                            imageAsset: ImageHelper.defaultLogoPath,
                            imageUrl: post.author.photo_url),
                      )),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Profile.route_id,
                              arguments: Profile(
                                isAuthor: isAuthor,
                                user: post.author,
                              ));
                        },
                        child: Text.rich(
                            TextSpan(text: "${post.author.ad}\n• ", children: [
                          TextSpan(
                              text: dateTxt,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.white60)),
                        ])),
                      ),
                    ),
                    Spacer(),
                    isAuthor
                        ? PopupMenuButton(
                            elevation: 3.2,
                            icon: Icon(Icons.more_horiz),
                            tooltip: AppLocalizations.of(context).translate('more'),
                            onSelected: onTapVert,
                            itemBuilder: (context) => <PopupMenuItem<int>>[
                              PopupMenuItem<int>(
                                  child: Text(AppLocalizations.of(context).translate('edit')), value: 0),
                              PopupMenuItem<int>(
                                  child: Text(AppLocalizations.of(context).translate('remove')), value: 1),
                            ],
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              child: Text(post.content, textAlign: TextAlign.center),
            ),
          ],
        ));
  }
}
