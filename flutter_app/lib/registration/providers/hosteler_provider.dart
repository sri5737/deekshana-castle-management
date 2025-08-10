// ...existing code from hosteler_provider.dart...
import 'package:flutter/material.dart';
import '../models.dart';

class HostelerProvider extends ChangeNotifier {
	final List<Hosteler> _hostelers = [];

	List<Hosteler> get hostelers => _hostelers;

	void addHosteler(Hosteler hosteler) {
		_hostelers.add(hosteler);
		notifyListeners();
	}

	void removeHosteler(int index) {
		_hostelers.removeAt(index);
		notifyListeners();
	}

	void loadHostelers() {
		// TODO: Load hostelers from Hive or other source
		notifyListeners();
	}
}
