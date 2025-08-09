import 'package:flutter/material.dart';
import 'models.dart';
import 'hosteler_provider.dart';
import 'hosteler_form_screen.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class HostelerListScreen extends StatelessWidget {
  const HostelerListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registered Hostelers')),
      body: Consumer<HostelerProvider>(
        builder: (context, provider, _) {
          if (provider.hostelers.isEmpty) {
            return const Center(child: Text('No hostelers registered.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : 1,
                  childAspectRatio: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: provider.hostelers.length,
                itemBuilder: (context, index) {
                  final h = provider.hostelers[index];
                  return Card(
                    child: Row(
                      children: [
                        h.profilePhotoPath.isNotEmpty && File(h.profilePhotoPath).existsSync()
                          ? Image.file(File(h.profilePhotoPath), width: 80, height: 80, fit: BoxFit.cover)
                          : const Icon(Icons.person, size: 80),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(h.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('Room: ${h.roomNumber}'),
                              Text('Status: ${h.status}'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HostelerFormScreen(hosteler: h, index: index),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await provider.deleteHosteler(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HostelerFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
