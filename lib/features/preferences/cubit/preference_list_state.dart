class PreferenceListState {
  final bool isLoading;
  final String? error;
  final List<dynamic> preferences;

  const PreferenceListState({
    this.isLoading = false,
    this.error,
    this.preferences = const [],
  });

  PreferenceListState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? preferences,
  }) {
    return PreferenceListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      preferences: preferences ?? this.preferences,
    );
  }
} 