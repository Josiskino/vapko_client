import 'package:get_it/get_it.dart';

final servicelocator = GetIt.instance;

Future<void> initServiceLocatorDependencies() async {
  // External
  // servicelocator.registerLazySingleton<Dio>(
  //   () => Dio(
  //     BaseOptions(
  //       baseUrl: ApiEndpoints.baseUrl,
  //     ),
  //   ),
  // );

  // DioClient
  // servicelocator.registerLazySingleton<DioClient>(() => DioClient(dio: servicelocator()));

  // Data sources
  // servicelocator.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSource(dioClient: servicelocator()),
  // ); 
}
