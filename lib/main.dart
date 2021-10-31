
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/simple_bloc_provider.dart';

import 'app.dart';

void  main(){
  Bloc.observer = SimpleBlocObserver();
  runApp(App());
}
