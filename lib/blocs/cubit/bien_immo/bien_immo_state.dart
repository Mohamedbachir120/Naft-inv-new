part of 'bien_immo_cubit.dart';

abstract class BienImmoState {}

class BienImmoInitial extends BienImmoState {}

class BienImmoLoading extends BienImmoState {}

class BienImmoLoaded extends BienImmoState {
  final BienImmo bienImmo;
  BienImmoLoaded(this.bienImmo);
}

class BienImmoNotFound extends BienImmoState {}

class BienImmoError extends BienImmoState {
  final String message;
  BienImmoError(this.message);
}

class BienImmoUpdated extends BienImmoState {
  final BienImmo bienImmo;
  BienImmoUpdated(this.bienImmo);
}

class BienImmoEdit extends BienImmoState {
  final BienImmo bienImmo;
  BienImmoEdit(this.bienImmo);
}