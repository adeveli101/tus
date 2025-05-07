import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tus/core/error/exceptions.dart';
import 'package:tus/core/error/failures.dart';

class ErrorHandler {
  static Either<Failure, T> handleError<T>(Function callback) {
    try {
      final result = callback();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code ?? 'SERVER_ERROR',
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code ?? 'CACHE_ERROR',
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message,
        code: e.code ?? 'NETWORK_ERROR',
      ));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.message,
        code: e.code ?? 'VALIDATION_ERROR',
      ));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(
        message: e.message,
        code: e.code ?? 'UNAUTHORIZED_ERROR',
      ));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(
        message: e.message,
        code: e.code ?? 'NOT_FOUND_ERROR',
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Bir hata oluştu',
        code: e.response?.statusCode?.toString() ?? 'DIO_ERROR',
      ));
    } on SocketException catch (e) {
      return Left(NetworkFailure(
        message: 'İnternet bağlantınızı kontrol edin',
        code: e.osError?.errorCode.toString() ?? 'SOCKET_ERROR',
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  static Future<Either<Failure, T>> handleFutureError<T>(
    Future<T> Function() callback,
  ) async {
    try {
      final result = await callback();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code ?? 'SERVER_ERROR',
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code ?? 'CACHE_ERROR',
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message,
        code: e.code ?? 'NETWORK_ERROR',
      ));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.message,
        code: e.code ?? 'VALIDATION_ERROR',
      ));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(
        message: e.message,
        code: e.code ?? 'UNAUTHORIZED_ERROR',
      ));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(
        message: e.message,
        code: e.code ?? 'NOT_FOUND_ERROR',
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.message ?? 'Bir hata oluştu',
        code: e.response?.statusCode?.toString() ?? 'DIO_ERROR',
      ));
    } on SocketException catch (e) {
      return Left(NetworkFailure(
        message: 'İnternet bağlantınızı kontrol edin',
        code: e.osError?.errorCode.toString() ?? 'SOCKET_ERROR',
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  static String? getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case CacheFailure:
        return 'Cache error: ${failure.message}';
      case NetworkFailure:
        return 'Network error: ${failure.message}';
      default:
        return 'An unexpected error occurred';
    }
  }

  static String? getErrorCode(Failure failure) {
    return failure.code;
  }
} 