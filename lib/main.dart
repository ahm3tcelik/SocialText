import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'helper/app_localizations.dart';
import 'screens/messenger/messenger.dart';
import 'screens/messenger/messenger_detail.dart';
import 'screens/profile.dart';
import 'screens/settings.dart';
import 'wrapper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        switch (settings.name) {
          case Settings.route_id:
            return MaterialPageRoute(builder: (context) => Settings());
          case Messenger.route_id:
            return MaterialPageRoute(builder: (context) => Messenger());
          case MessengerDetail.route_id:
            return MaterialPageRoute(builder: (context) => MessengerDetail());
          case Profile.route_id:
            {
              return MaterialPageRoute(
                  builder: (context) => Profile(
                        user: (args as Profile).user,
                        isAuthor: (args as Profile).isAuthor,
                      ));
            }
          default:
            return MaterialPageRoute(
              builder: (context) => Wrapper(),
            );
        }
      },
      supportedLocales: [
        Locale('en', 'US'),
        Locale('tr', 'TR')
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for(var supportedLocale in supportedLocales) {
          if(supportedLocale.languageCode == locale.languageCode && supportedLocale.countryCode == locale.countryCode)
            return supportedLocale;
        }
        return supportedLocales.first;
      },
    );
  }
}
