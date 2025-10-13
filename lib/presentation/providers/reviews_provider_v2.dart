/// ReviewsProvider migrado para Clean Architecture com Use Cases.
library;

import 'package:app_sanitaria/core/di/injection_container.dart';
import 'package:app_sanitaria/domain/entities/review_entity.dart';
import 'package:app_sanitaria/domain/usecases/reviews/add_review.dart';
import 'package:app_sanitaria/domain/usecases/reviews/get_average_rating.dart';
import 'package:app_sanitaria/domain/usecases/reviews/get_reviews_by_professional.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado das avaliações (Clean Architecture)
class ReviewsState {
  ReviewsState({
    this.reviewsByProfessional = const {},
    this.averageRatings = const {},
    this.isLoading = false,
    this.errorMessage,
  });
  final Map<String, List<ReviewEntity>> reviewsByProfessional;
  final Map<String, double> averageRatings;
  final bool isLoading;
  final String? errorMessage;

  ReviewsState copyWith({
    Map<String, List<ReviewEntity>>? reviewsByProfessional,
    Map<String, double>? averageRatings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReviewsState(
      reviewsByProfessional:
          reviewsByProfessional ?? this.reviewsByProfessional,
      averageRatings: averageRatings ?? this.averageRatings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<ReviewEntity> getReviews(String professionalId) =>
      reviewsByProfessional[professionalId] ?? [];

  double getAverageRating(String professionalId) =>
      averageRatings[professionalId] ?? 0.0;
}

/// ReviewsNotifier V2 - Clean Architecture
class ReviewsNotifierV2 extends StateNotifier<ReviewsState> {
  ReviewsNotifierV2({
    required GetReviewsByProfessional getReviewsByProfessional,
    required AddReview addReview,
    required GetAverageRating getAverageRating,
  })  : _getReviewsByProfessional = getReviewsByProfessional,
        _addReview = addReview,
        _getAverageRating = getAverageRating,
        super(ReviewsState());
  final GetReviewsByProfessional _getReviewsByProfessional;
  final AddReview _addReview;
  final GetAverageRating _getAverageRating;

  /// Carrega avaliações de um profissional
  Future<void> loadReviews(String professionalId) async {
    state = state.copyWith(isLoading: true);

    final result = await _getReviewsByProfessional.call(professionalId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar avaliações',
      ),
      (reviews) {
        final newReviews =
            Map<String, List<ReviewEntity>>.from(state.reviewsByProfessional);
        newReviews[professionalId] = reviews;
        state =
            state.copyWith(reviewsByProfessional: newReviews, isLoading: false);
      },
    );
  }

  /// Adiciona nova avaliação
  Future<bool> addReview(ReviewEntity review) async {
    state = state.copyWith(isLoading: true);

    final result = await _addReview.call(
      AddReviewParams(
        professionalId: review.professionalId,
        patientId: review.patientId,
        patientName: review.patientName,
        rating: review.rating,
        comment: review.comment,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao adicionar avaliação',
        );
        return false;
      },
      (addedReview) {
        // Recarregar avaliações
        loadReviews(review.professionalId);
        loadAverageRating(review.professionalId);
        return true;
      },
    );
  }

  /// Carrega média de avaliações
  Future<void> loadAverageRating(String professionalId) async {
    final result = await _getAverageRating.call(professionalId);

    result.fold(
      (failure) => null,
      (average) {
        final newRatings = Map<String, double>.from(state.averageRatings);
        newRatings[professionalId] = average;
        state = state.copyWith(averageRatings: newRatings);
      },
    );
  }
}

/// Provider para ReviewsNotifierV2
final reviewsProviderV2 =
    StateNotifierProvider<ReviewsNotifierV2, ReviewsState>((ref) {
  return ReviewsNotifierV2(
    getReviewsByProfessional: getIt<GetReviewsByProfessional>(),
    addReview: getIt<AddReview>(),
    getAverageRating: getIt<GetAverageRating>(),
  );
});
