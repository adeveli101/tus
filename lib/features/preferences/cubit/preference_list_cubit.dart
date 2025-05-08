import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tus/features/preferences/cubit/preference_list_state.dart';

class PreferenceListCubit extends Cubit<PreferenceListState> {
  PreferenceListCubit() : super(const PreferenceListState());

  void loadPreferences() {
    emit(state.copyWith(isLoading: true, error: null));
    
    // TODO: Implement actual data loading
    Future.delayed(const Duration(seconds: 1), () {
      emit(state.copyWith(
        isLoading: false,
        preferences: [], // TODO: Add actual preferences
      ));
    });
  }

  void updateFilterParams(Map<String, dynamic> params) {
    // TODO: Implement filter logic
  }
} 