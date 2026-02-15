// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/repositories/auth_repository.dart' as _i481;
import '../../data/repositories/transaction_repository.dart' as _i684;
import '../../data/repositories/wallet_repository.dart' as _i147;
import '../../data/usecases/login_usecase.dart' as _i917;
import '../../data/usecases/wallet_usecase.dart' as _i292;
import '../../presentation/cubit/auth/auth_cubit.dart' as _i714;
import '../../presentation/cubit/wallet/wallet_cubit.dart' as _i748;
import '../network/api_service.dart' as _i921;
import '../network/dio_api_service.dart' as _i906;
import '../network/dio_client.dart' as _i667;
import 'cubit_module.dart' as _i551;
import 'network_module.dart' as _i567;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    final cubitModule = _$CubitModule();
    gh.singleton<_i667.DioClient>(() => networkModule.dioClient);
    gh.singleton<_i361.Dio>(() => networkModule.dio(gh<_i667.DioClient>()));
    gh.lazySingleton<_i921.ApiService>(
        () => _i906.DioApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i684.TransactionRepository>(
        () => _i684.TransactionRepositoryImpl(gh<_i921.ApiService>()));
    gh.lazySingleton<_i147.WalletRepository>(
        () => _i147.WalletRepositoryImpl(gh<_i921.ApiService>()));
    gh.lazySingleton<_i481.AuthRepository>(
        () => _i481.AuthRepositoryImpl(gh<_i921.ApiService>()));
    gh.lazySingleton<_i917.LoginUseCase>(
        () => cubitModule.loginUseCase(gh<_i481.AuthRepository>()));
    gh.lazySingleton<_i917.LogoutUseCase>(
        () => cubitModule.logoutUseCase(gh<_i481.AuthRepository>()));
    gh.lazySingleton<_i714.AuthCubit>(() => cubitModule.authCubit(
          gh<_i917.LoginUseCase>(),
          gh<_i917.LogoutUseCase>(),
          gh<_i667.DioClient>(),
        ));
    gh.lazySingleton<_i292.GetWalletUseCase>(
        () => cubitModule.getWalletUseCase(gh<_i147.WalletRepository>()));
    gh.lazySingleton<_i292.DeductBalanceUseCase>(
        () => cubitModule.deductBalanceUseCase(gh<_i147.WalletRepository>()));
    gh.lazySingleton<_i748.WalletCubit>(() => cubitModule.walletCubit(
          gh<_i292.GetWalletUseCase>(),
          gh<_i292.DeductBalanceUseCase>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i567.NetworkModule {}

class _$CubitModule extends _i551.CubitModule {}
