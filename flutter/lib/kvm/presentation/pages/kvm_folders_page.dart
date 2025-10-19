import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hbb/kvm/domain/kvm_state_provider.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_folder.dart';
import 'package:flutter_hbb/kvm/presentation/kvm_state.dart';
import 'package:flutter_hbb/kvm/presentation/widgets/kvm_app_bar.dart';
import 'package:flutter_hbb/kvm/presentation/widgets/kvm_folder_selection.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class KVMFoldersPage extends StatefulWidget {
  const KVMFoldersPage({super.key, required this.stepRegisterDevice});

  final KVMStepRegisterDevice stepRegisterDevice;

  @override
  State<KVMFoldersPage> createState() => _KVMFoldersPageState();
}

class _KVMFoldersPageState extends State<KVMFoldersPage> {
  bool isRegisteringDevice = false;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      widget.stepRegisterDevice.setSelectedFolder(null);
      final stateProvider = context.read<KVMStateProvider>();
      final device = stateProvider.device;
      if (device != null) {
        if (!(await showReEnrollDeviceDialog()) && context.mounted) {
          stateProvider.onDeviceRegistered(device);
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.stepRegisterDevice,
        builder: (context, _) {
          final selectedTenant = widget.stepRegisterDevice.selectedTenant;
          final selectedFolder = widget.stepRegisterDevice.selectedFolder;
          return Scaffold(
            body: Builder(builder: (context) {
              return CustomScrollView(
                slivers: [
                  getKVMSliverAppBar(context),
                  SliverFillRemaining(
                    child: FutureBuilder(
                      future: context.read<KVMStateProvider>().fetchTenants(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        }

                        final dropdownTenants = [
                          "Select tenant",
                          ...snapshot.data!
                              .toList()
                              .map((tenant) => tenant.toString())
                        ];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                child: DropdownButton<String>(
                                  hint: Text("Select tenant"),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  value: selectedTenant != null
                                      ? selectedTenant.toString()
                                      : "Select tenant",
                                  items: dropdownTenants
                                      .map(
                                        (tenant) => DropdownMenuItem<String>(
                                          value: tenant.toString(),
                                          child: Text(tenant.toString()),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    widget.stepRegisterDevice
                                        .setSelectedFolder(null);
                                    widget.stepRegisterDevice.setSelectedTenant(
                                        snapshot.data!
                                            .toList()
                                            .firstWhereOrNull((tenant) =>
                                                tenant.toString() == value));
                                  },
                                  isExpanded: true,
                                ),
                              ),
                            ),
                            if (selectedTenant != null)
                              Expanded(
                                child: KVMFolderPicker(
                                  stepRegisterDevice: widget.stepRegisterDevice,
                                ),
                              )
                            else
                              Spacer(),
                            Builder(builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.all(12)),
                                  onPressed: selectedFolder != null &&
                                          !isRegisteringDevice
                                      ? () {
                                          _registerDevice(
                                              selectedFolder, context);
                                        }
                                      : null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Register device"),
                                      if (isRegisteringDevice)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: SizedBox.square(
                                              dimension: 16,
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            })
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          );
        });
  }

  void _registerDevice(KVMFolder folder, BuildContext context) async {
    final deviceName = await showDialogNamePicker();
    if (deviceName == null) {
      return;
    }

    setState(() {
      isRegisteringDevice = true;
    });

    try {
      await context.read<KVMStateProvider>().registerDevice(folder, deviceName);
    } catch (e) {
      displayErrorSnackbar(e.toString(), context);
    }

    setState(() {
      isRegisteringDevice = false;
    });
  }

  Future<bool> showReEnrollDeviceDialog() async {
    return await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("El dispositivo ya está registrado"),
                content: Text(
                    "Deseas registrar el dispositivo en una nueva carpeta o usar la existente?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text("Usar carpeta existente"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text("Nueva carpeta"),
                  ),
                ],
              );
            }) ??
        false;
  }

  Future<String?> showDialogNamePicker() {
    return showDialog<String?>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text("Set device name"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Device name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: Text("Continue"),
            )
          ],
        );
      },
    );
  }

  void displayErrorSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
