import 'package:flutter_application_1/redux/state.dart';

import 'action.dart';

AppState reducer(AppState state, dynamic action) {

  if (action is SetCurrentUserAction) {
    return AppState(currentUser: action.currentUser);
  }
  return state;
}