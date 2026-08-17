// -------------------------
// Municipal Services State
// -------------------------

import 'package:equatable/equatable.dart';

import '../../../domain/entities/municipal_service.dart';

enum MunicipalServicesStatus { loading, empty, error, ready }

final class MunicipalServicesState extends Equatable {
  final MunicipalServicesStatus status;
  final List<MunicipalService> services;
  final String? errorMessage;

  const MunicipalServicesState({
    this.status = MunicipalServicesStatus.loading,
    this.services = const [],
    this.errorMessage,
  });

  MunicipalServicesState copyWith({
    MunicipalServicesStatus? status,
    List<MunicipalService>? services,
    String? errorMessage,
  }) {
    return MunicipalServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, services, errorMessage];
}
