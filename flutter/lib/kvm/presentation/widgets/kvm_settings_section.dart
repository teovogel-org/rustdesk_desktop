import 'package:flutter/material.dart';
import 'package:flutter_hbb/kvm/domain/kvm_state_provider.dart';
import 'package:flutter_hbb/kvm/presentation/pages/kvm_login_page.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class KVMSettingsSection extends SettingsSection {
  KVMSettingsSection({super.key})
      : super(
          title: Text("Dex Remote"),
          tiles: [
            SettingsTile(
              title: Consumer<KVMStateProvider>(builder: (context, state, _) {
                return Text(state.registeredDeviceId == null
                    ? "Dex Remote Onboarding"
                    : "Dex Remote Onboarding Done!");
              }),
              leading: Consumer<KVMStateProvider>(builder: (context, state, _) {
                return Icon(
                  state.registeredDeviceId == null
                      ? Icons.play_arrow
                      : Icons.check,
                  color: state.registeredDeviceId != null ? Colors.green : null,
                );
              }),
              onPressed: (context) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => KVMLoginPage(),
                  ),
                );
              },
            ),
          ],
        );
}
