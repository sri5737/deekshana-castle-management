import 'package:flutter/material.dart';
import 'models.dart';
import 'package:hive/hive.dart';

class HostelerProvider extends ChangeNotifier {
  List<Hosteler> _hostelers = [];
  List<Hosteler> get hostelers => _hostelers;

  Future<void> loadHostelers() async {
    var box = await Hive.openBox('hostelers');
    _hostelers = box.values.map((e) => Hosteler.fromJson(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }

  Future<void> addHosteler(Hosteler hosteler) async {
    var box = await Hive.openBox('hostelers');
    await box.add(hosteler.toJson());
    await loadHostelers();
  }

  Future<void> updateHosteler(int index, Hosteler hosteler) async {
    var box = await Hive.openBox('hostelers');
    await box.putAt(index, hosteler.toJson());
    await loadHostelers();
  }

  Future<void> deleteHosteler(int index) async {
    var box = await Hive.openBox('hostelers');
    await box.deleteAt(index);
    await loadHostelers();
  }
}
