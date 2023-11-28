import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class page_provider extends ChangeNotifier{
  int? _page = 0;


  //page getter
  int? get page => _page;

  void changePage(int page){
    _page = page;
    notifyListeners();
  }

  void clearPage(){
    _page = null;
    notifyListeners();
  }
}