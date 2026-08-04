import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.attach_money), title: Text('薪资配置')),
          ListTile(leading: Icon(Icons.access_time), title: Text('打卡设置')),
          ListTile(leading: Icon(Icons.notifications), title: Text('推送通知')),
          ListTile(leading: Icon(Icons.dark_mode), title: Text('深色模式')),
          ListTile(leading: Icon(Icons.language), title: Text('语言')),
          ListTile(leading: Icon(Icons.info), title: Text('关于 WageBar')),
        ],
      ),
    );
  }
}
