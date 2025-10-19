import 'package:flutter/material.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_device.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_folder.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_tenant.dart';

class KVMState {
  String? authToken;
  KVMDevice? device;
}

abstract class KVMStepState {}

class KVMStepInitializing extends KVMStepState {}

class KVMStepLogin extends KVMStepState {}

class KVMStepRegisterDevice extends KVMStepState with ChangeNotifier {
  KVMTenant? selectedTenant;
  KVMFolder? selectedFolder;

  void setSelectedTenant(KVMTenant? selectedTenant) {
    this.selectedTenant = selectedTenant;
    debugPrint("selected tenant");
    notifyListeners();
  }

  void setSelectedFolder(KVMFolder? selectedFolder) {
    this.selectedFolder = selectedFolder;
    notifyListeners();
  }
}

class KVMStepRequestPerissions extends KVMStepState {}

class KVMStepReady extends KVMStepState {}
