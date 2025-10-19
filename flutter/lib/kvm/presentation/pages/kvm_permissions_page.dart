import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/kvm/domain/kvm_state_provider.dart';
import 'package:flutter_hbb/kvm/presentation/widgets/kvm_app_bar.dart';
import 'package:flutter_hbb/mobile/pages/server_page.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:provider/provider.dart';

class KVMPermissionsPage extends StatefulWidget {
  const KVMPermissionsPage({super.key});

  @override
  State<KVMPermissionsPage> createState() => _KVMPermissionsPageState();
}

class _KVMPermissionsPageState extends State<KVMPermissionsPage> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTimer = periodic_immediate(const Duration(seconds: 3), () async {
      await gFFI.serverModel.fetchID();
    });
    gFFI.serverModel.checkAndroidPermission();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider.value(
          value: gFFI.serverModel,
          builder: (context, _) {
            return Consumer<ServerModel>(builder: (context, serverModel, _) {
              return CustomScrollView(slivers: [
                getKVMSliverAppBar(context),
                SliverFillRemaining(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Device: ${context.read<KVMStateProvider>().device?.name}",
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          margin: EdgeInsets.all(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Permisos",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Habilita TODOS los siguientes permisos para terminar el setup",
                                ),
                                SizedBox(height: 4),
                                Divider(),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  title: Text("Input Control"),
                                  value: serverModel.inputOk,
                                  onChanged: (bool value) =>
                                      serverModel.toggleInput(),
                                ),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  title: Text("Transfer file"),
                                  value: serverModel.fileOk,
                                  onChanged: (bool value) =>
                                      serverModel.toggleFile(),
                                ),
                                SwitchListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text("Screen Capture"),
                                    value: serverModel.mediaOk,
                                    onChanged: serverModel.inputOk &&
                                            serverModel.fileOk
                                        ? (bool value) {
                                            serverModel.toggleService();
                                            serverModel.fetchID();
                                          }
                                        : null),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: serverModel.mediaOk &&
                              serverModel.inputOk &&
                              serverModel.fileOk,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                  horizontal: 16,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.green,
                                      size: 64,
                                    ),
                                    Text(
                                      "Setup completo!",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                              ),
                              ServerInfo(),
                              SizedBox(height: 24),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ]);
            });
          }),
    );
  }
}
