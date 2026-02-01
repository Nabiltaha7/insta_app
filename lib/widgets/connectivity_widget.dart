import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../services/connectivity_service.dart';

class ConnectivityWidget extends StatelessWidget {
  final Widget child;
  
  const ConnectivityWidget({
    super.key,
    required this.child,
  });

  void _showNoConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text('لا يوجد اتصال بالإنترنت'),
            ],
          ),
          content: const Text(
            'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final connectivityService = Get.find<ConnectivityService>();
                await connectivityService.checkConnection();
                
                // إذا لم يتم الاتصال، أظهر النافذة مرة أخرى
                if (!connectivityService.isConnected.value) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) {
                      _showNoConnectionDialog(context);
                    }
                  });
                }
              },
              child: const Text('إعادة المحاولة'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop(); // إغلاق التطبيق
              },
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connectivityService = Get.find<ConnectivityService>();
      
      // إظهار النافذة عند فقدان الاتصال
      if (!connectivityService.isConnected.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showNoConnectionDialog(context);
          }
        });
      }
      
      return child;
    });
  }
}