import 'package:get/get.dart';
import 'package:job_hive/features/home/controllers/home_controller.dart';
import 'package:job_hive/features/home/service/home_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeService>(() => HomeService());
    Get.lazyPut<HomeController>(
      () => HomeController(homeService: Get.find<HomeService>()),
    );
  }
}
