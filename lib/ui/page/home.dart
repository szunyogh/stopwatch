import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0).r,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text('00:00,00', style: Theme.of(context).textTheme.headlineLarge),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: null,
                    child: const Text('Kör'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Indítás'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
