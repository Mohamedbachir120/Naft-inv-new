import 'package:flutter_bloc/flutter_bloc.dart';

// Cubit that manages the number of articles
class NumberOfArticlesCubit extends Cubit<AddSnFields> {
  NumberOfArticlesCubit()
      : super(
            AddSnFields(nature: "", numberOfArticles: 1)); // Initial value is 1

  // Method to increment the number of articles
  void update(AddSnFields field) => emit(field);

  // Method to decrement the number of articles

  // Method to reset the number of articles
  void reset() => emit(AddSnFields(nature: "", numberOfArticles: 1));
}

class AddSnFields {
  final int numberOfArticles;
  final String nature;

  AddSnFields({required this.nature, required this.numberOfArticles});
  AddSnFields copyWith({
    String? nature,
    int? numberOfArticles,
  }) {
    return AddSnFields(
      nature: nature ?? this.nature,
      numberOfArticles: numberOfArticles ?? this.numberOfArticles,
    );
  }
}
