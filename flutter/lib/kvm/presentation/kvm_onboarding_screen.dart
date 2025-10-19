import 'package:flutter/material.dart';
import 'package:flutter_hbb/kvm/domain/kvm_state_provider.dart';
import 'package:flutter_hbb/kvm/presentation/kvm_state.dart';
import 'package:flutter_hbb/kvm/presentation/pages/kvm_folders_page.dart';
import 'package:flutter_hbb/kvm/presentation/pages/kvm_login_page.dart';
import 'package:flutter_hbb/kvm/presentation/pages/kvm_permissions_page.dart';
import 'package:provider/provider.dart';

class KVMOnboardingScreen extends StatefulWidget {
  const KVMOnboardingScreen({super.key});

  @override
  State<KVMOnboardingScreen> createState() => _KVMOnboardingScreenState();
}

class _KVMOnboardingScreenState extends State<KVMOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController =
      TabController(length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<KVMStateProvider>(builder: (context, kvmStateProvider, _) {
        final nextStep = kvmStateProvider.nextStepState;
        if (nextStep is KVMStepInitializing) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        tabController.index = nextStep is KVMStepLogin
            ? 0
            : nextStep is KVMStepRegisterDevice
                ? 1
                : 2;

        return TabBarView(
          controller: tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            KVMLoginPage(),
            KVMFoldersPage(
              stepRegisterDevice: kvmStateProvider.registerDeviceStepState,
            ),
            KVMPermissionsPage(),
          ],
        );
      }),
    );
  }
}
