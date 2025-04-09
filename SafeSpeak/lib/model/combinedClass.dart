import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';

import 'usermodel.dart';

class CombinedData {
  final UserModel user;
  final KeywordModel keyword;
  final List<ContactModel> contacts;

  CombinedData({
    required this.user,
    required this.keyword,
    required this.contacts,
  });
}
