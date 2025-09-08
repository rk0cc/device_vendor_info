import 'package:device_vendor_info/device_vendor_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: DeviceInfoPage()));
}

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  Container _buildInfoWidget<T extends Object>(BuildContext context,
      {required String displayName,
      required Future<T> Function() infoFetch,
      required List<ListTile> Function(T info) result}) {
    final ThemeData currentTheme = Theme.of(context);

    return Container(
        constraints: const BoxConstraints(maxWidth: 768),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName,
                  style: TextStyle(
                      color: currentTheme.dividerColor, fontSize: 12)),
              const Divider(),
              FutureBuilder<T>(
                  future: infoFetch(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Icon(Icons.error_outline);
                    } else if (!snapshot.hasData ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: result(snapshot.data!));
                  })
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text("Current platform: ${defaultTargetPlatform.name}",
                style: const TextStyle(color: Colors.white))),
        body: Column(children: [
          Expanded(
              child: ListView(children: [
            _buildInfoWidget(context,
                displayName: "Virtualization",
                infoFetch: isVirtualized,
                result: (info) => <ListTile>[
                      ListTile(
                        title: const Text("Virtualization"),
                        trailing: Text(info ? "Yes" : "No"),
                      )
                    ]),
            _buildInfoWidget<BiosInfo>(context,
                displayName: "BIOS",
                infoFetch: getBiosInfo,
                result: (info) => <ListTile>[
                      ListTile(
                          title: const Text("Vendor name"),
                          trailing: Text(info.vendor ?? "(Unknown)")),
                      ListTile(
                          title: const Text("Version"),
                          trailing: Text(info.version ?? "(Unknown)")),
                      ListTile(
                          title: const Text("Release date"),
                          trailing: Text(info.releaseDate != null
                              ? DateFormat("yyyy-MM-dd")
                                  .format(info.releaseDate!)
                              : "(Unknown)"))
                    ]),
            _buildInfoWidget<BoardInfo>(context,
                displayName: "Motherboard",
                infoFetch: getBoardInfo,
                result: (info) => <ListTile>[
                      ListTile(
                          title: const Text("Product name"),
                          trailing: Text(info.productName ?? "(Unknown)")),
                      ListTile(
                          title: const Text("Manufacturer"),
                          trailing: Text(info.manufacturer ?? "(Unknown)")),
                      ListTile(
                          title: const Text("Version"),
                          trailing: Text(info.version ?? "(Unknown)"))
                    ]),
            _buildInfoWidget<SystemInfo>(context,
                displayName: "System",
                infoFetch: getSystemInfo,
                result: (info) => <ListTile>[
                      ListTile(
                          title: const Text("Family"),
                          trailing: Text(info.family ?? "(Unknown)")),
                      ListTile(
                          title: const Text("Product name"),
                          trailing: Text(info.productName ?? "(Unknown)")),
                      ListTile(
                          title: const Text("Manufacturer"),
                          trailing: Text(info.manufacturer ?? "(Unknown)")),
                      ListTile(
                          title: const Text("Version"),
                          trailing: Text(info.version ?? "(Unknown)"))
                    ])
          ]))
        ]));
  }
}
