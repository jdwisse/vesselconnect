import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:flutter/services.dart';
import 'package:location/location.dart';

void main() async {
  var delegate = await LocalizationDelegate.create(
    basePath: 'lib/assets/i18n/',
    fallbackLocale: 'en',
    supportedLocales: ['en', 'nl'],
  );

  runApp(LocalizedApp(delegate, MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        title: 'vesselconnect',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        theme: ThemeData.dark().copyWith(accentColor: Colors.orange),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  LocationData _currentLocation;
  Location _locationService = new Location();

  void _decrementCounter() => setState(() => _counter--);

  void _incrementCounter() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return Scaffold(
      appBar: AppBar(
        title: Text(translate('app_bar.title')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(translate('language.selected_message', args: {
              'language': translate(
                  'language.name.${localizationDelegate.currentLocale.languageCode}')
            })),
            Padding(
              padding: EdgeInsets.only(top: 25, bottom: 40),
              child: CupertinoButton.filled(
                child: Text(translate('button.change_language')),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 36.0),
                onPressed: () => _onActionSheetPress(context),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 25, bottom: 40),
              child: CupertinoButton.filled(
                child: Text(translate('button.get_datepicker')),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 36.0),
                onPressed: () async {
                  final List<DateTime> picked =
                      await DateRagePicker.showDatePicker(
                          context: context,
                          initialFirstDate: new DateTime.now(),
                          initialLastDate:
                              (new DateTime.now()).add(new Duration(days: 7)),
                          firstDate: new DateTime(2019),
                          lastDate: new DateTime(2022));
                  if (picked != null && picked.length == 2) {
                    print(picked);
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 25, bottom: 40),
              child: CupertinoButton.filled(
                child: Text(translate('button.location')),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 36.0),
                onPressed: () async {
                  // await _locationService.changeSettings(
                  //   accuracy: LocationAccuracy.POWERSAVE,
                  //   interval: 1000,
                  // );
                  try {
                    _currentLocation = await _locationService.getLocation();
                    print(
                      'lat: ${_currentLocation.latitude} & long: ${_currentLocation.longitude}',
                    );
                  } on PlatformException catch (e) {
                    if (e.code == 'PERMISSION_DENIED') {
                      print('Permission denied');
                    }
                    _currentLocation = null;
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(translatePlural('plural.demo', _counter)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.remove_circle),
                  iconSize: 48,
                  onPressed: _counter > 0
                      ? () => setState(() => _decrementCounter())
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.add_circle),
                  color: Colors.blue,
                  iconSize: 48,
                  onPressed: () => setState(() => _incrementCounter()),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void showDemoActionSheet({BuildContext context, Widget child}) {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((String value) {
      changeLocale(context, value);
    });
  }

  void _onActionSheetPress(BuildContext context) {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
        title: Text(translate('language.selection.title')),
        message: Text(translate('language.selection.message')),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(translate('language.name.en')),
            onPressed: () => Navigator.pop(context, 'en_US'),
          ),
          CupertinoActionSheetAction(
            child: Text(translate('language.name.nl')),
            onPressed: () => Navigator.pop(context, 'nl'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(translate('button.cancel')),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, null),
        ),
      ),
    );
  }
}
