/// Fetches news articles from the API based on keyword and page, handling responses and errors.

library;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import '../common/colors.dart';
import '../models/listdata_model.dart';
import '../models/news_model.dart';
import '../services/api.dart';


class NewsProvider {
  Future<ListData> GetEverything(String keyword, int page) async {
    ListData articles = ListData([], 0, false);

    await ApiService().getEverything(keyword, page).then((response) {
      if (response.statusCode == 200) {
        Iterable data = jsonDecode(response.body)['articles'];
        articles = ListData(
          data.map((e) => News.fromJson(e)).toList(),
          jsonDecode(response.body)['totalResults'],
          true,
        );
      } else {
        // Show error message toast if API call fails
        Fluttertoast.showToast(
          msg: jsonDecode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.lighterGray,
          textColor: AppColors.black,
          fontSize: 16.0,
        );
        throw Exception(response.statusCode);
      }
    });

    return articles;
  }
}
