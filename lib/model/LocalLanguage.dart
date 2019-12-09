import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';

class LocalLanguage {
  String languageCode;
  String countryCode;
  String displayName;
  String translator;

  LocalLanguage({
    @required this.languageCode,
    @required this.countryCode,
    @required this.displayName,
    @required this.translator,
  });
}

class LocalLanguagePicker extends StatefulWidget {
  @override
  _LocalLanguagePickerState createState() => _LocalLanguagePickerState();
}

class _LocalLanguagePickerState extends State<LocalLanguagePicker> {
  List<LocalLanguage> localLanguages = [
    LocalLanguage(
      languageCode: "en",
      countryCode: "US",
      displayName: "English",
      translator: "tuanha2000vn",
    ),
    LocalLanguage(
      languageCode: "sv",
      countryCode: "SE",
      displayName: "Swedish",
      translator: "Tyre88",
    ),
    LocalLanguage(
      languageCode: "vi",
      countryCode: "VN",
      displayName: "Vietnamese",
      translator: "tuanha2000vn",
    ),
    LocalLanguage(
      languageCode: "bg",
      countryCode: "BG",
      displayName: "Bulgarian",
      translator: "kirichkov",
    ),
    LocalLanguage(
      languageCode: "el",
      countryCode: "GR",
      displayName: "Greece",
      translator: "smartHomeHub",
    ),
    LocalLanguage(
      languageCode: "zh",
      countryCode: "CN",
      displayName:
          "Chinese Simplified", //Simplified Chinese or 中文简体 (zh-CN) is used in China. Traditional Chinese or 中文繁体 (zh-TW) is used in Taiwan
      translator: "thor",
    ),
    LocalLanguage(
      languageCode: "zh",
      countryCode: "TW",
      displayName:
          "Chinese Traditional", //Simplified Chinese or 中文简体 (zh-CN) is used in China. Traditional Chinese or 中文繁体 (zh-TW) is used in Taiwan
      translator: "bluefoxlee",
    ),
    LocalLanguage(
      languageCode: "ru",
      countryCode: "RU",
      displayName: "Russian",
      translator: "antropophob",
    ),
    LocalLanguage(
      languageCode: "nl",
      countryCode: "NL",
      displayName: "Dutch",
      translator: "Arjan",
    ),
    LocalLanguage(
      languageCode: "he",
      countryCode: "IL",
      displayName: "Hebrew",
      translator: "Asaf",
    ),
  ];

  @override
  void initState() {
    super.initState();
    log.d("_LocalLanguagePickerState ${gd.localeData.savedLocale}");
    localLanguages.sort((a, b) => (a.displayName).compareTo(b.displayName));
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.all(4),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: DropdownButton<String>(
              value: gd.localeData.savedLocale != null &&
                      gd.localeData.savedLocale.toString() != null
                  ? gd.localeData.savedLocale.toString()
                  : "en_US",
              items: localLanguages.map((LocalLanguage map) {
                return DropdownMenuItem<String>(
                  value: "${map.languageCode}_${map.countryCode}",
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 30),
                      Text(
                        gd.textToDisplay(
                            "${map.displayName} - © ${map.translator}"),
                        style: Theme.of(context).textTheme.body1,
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: gd.textScaleFactorFix,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  var languageCode = newValue.split("_")[0];
                  var countryCode = newValue.split("_")[1];
                  log.d(
                      "newValue $newValue languageCode $languageCode countryCode $countryCode");
                  gd.localeData.changeLocale(Locale(
                    languageCode,
                    countryCode,
                  ));
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
