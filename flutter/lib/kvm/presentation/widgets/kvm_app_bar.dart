import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/kvm/kvm_routing_utils.dart';
import 'package:flutter_hbb/mobile/widgets/dialog.dart';
import 'package:flutter_hbb/models/platform_model.dart';

SliverAppBar getKVMSliverAppBar(BuildContext context) => SliverAppBar.large(
      actions: [
        /*IconButton(
          onPressed: () {
            gFFI.serverModel.stopService();
            context.read<KVMStateProvider>().onUserSessionExpired();
          },
          icon: Icon(Icons.restart_alt_rounded),
        ),*/
        PopupMenuButton(
          icon: const Icon(Icons.more_vert_rounded),
          position: PopupMenuPosition.under,
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: ListTile(
                  title: Text("ID/Relay server"),
                  leading: Icon(Icons.settings),
                ),
                onTap: () => showServerSettings(gFFI.dialogManager),
              ),
              PopupMenuItem(
                child: ListTile(
                  title: Text("Ir a RustDesk"),
                  leading: Icon(Icons.open_in_new_rounded),
                ),
                onTap: () => KVMRoutingUtils.goToRustDeskHomePage(context),
              ),
            ];
          },
        )
      ],
      flexibleSpace: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
          bottom: 16,
        ),
        child: Center(
            child: Image.asset(
          "assets/dex_logo.png",
          scale: 1,
        )),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24))),
    );


void showServerSettings(OverlayDialogManager dialogManager) async {
  Map<String, dynamic> options = jsonDecode(await bind.mainGetOptions());
  showServerSettingsWithValue(ServerConfig.fromOptions(options), dialogManager);
}
