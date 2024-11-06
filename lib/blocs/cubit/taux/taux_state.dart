part of 'taux_cubit.dart';

// State of the Cubit
class TauxState {
  final double? taux;
  final int? diffDays;
  final bool isLoading;
  final String? error;

  TauxState({this.taux, this.diffDays,this.isLoading = false, this.error});

  TauxState copyWith({double? taux,int? diffDays, bool? isLoading, String? error}) {
    return TauxState(
      taux: taux ?? this.taux,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      diffDays: diffDays ?? this.diffDays
    );
  }
}
