import 'package:social_text/helper/app_localizations.dart';
import 'package:social_text/models/User.dart';
import 'package:social_text/screens/messenger/user_list.dart';
import 'package:social_text/services/database.dart';
import 'package:flutter/material.dart';

class Messenger extends StatefulWidget {
  static const String route_id = "/admin_messenger";

  Messenger();

  @override
  State createState() => MessengerState();
}

class MessengerState extends State<Messenger> {
  List<User> userList = List();
  final TextEditingController searchCtrl = TextEditingController();
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  final DatabaseService databaseService = DatabaseService();
  Future future;

  void onSubmitSearch(String key) {
    setState(() {
      future = databaseService.searchUser(key);
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    future = databaseService.users(limit: 10, isFirst: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: buildSearchBar(),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          key: refreshKey,
          backgroundColor: ThemeData.dark().primaryColor,
          onRefresh: () async {
            setState(() {});
          },
          child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              userList = snapshot.data;
              return (snapshot.connectionState == ConnectionState.waiting)
                  ? Center(child: CircularProgressIndicator())
                  : UserList(userList: userList);
            },
          ),
        ));
  }

  Widget buildSearchBar() {
    return TextFormField(
      controller: searchCtrl,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('search_here'),
        prefixIcon: Icon(Icons.search, color: Colors.white),
        suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            color: Colors.white,
            onPressed: () => searchCtrl.clear()),
      ),
      onFieldSubmitted: onSubmitSearch,
    );
  }
}
