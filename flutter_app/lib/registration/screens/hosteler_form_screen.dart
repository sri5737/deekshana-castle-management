// ...existing code from hosteler_form_screen.dart...
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../widgets/app_header.dart';

class HostelerFormScreen extends StatefulWidget {
	final Function(String, String, Uint8List?) onSubmit;
	final String username;
	const HostelerFormScreen({super.key, required this.onSubmit, required this.username});

	@override
	State<HostelerFormScreen> createState() => _HostelerFormScreenState();
}

class _HostelerFormScreenState extends State<HostelerFormScreen> {
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _roomController = TextEditingController();
	Uint8List? _imageBytes;

	Future<void> _pickImage() async {
		final picker = ImagePicker();
		final picked = await picker.pickImage(source: ImageSource.gallery);
		if (picked != null) {
			final bytes = await picked.readAsBytes();
			setState(() => _imageBytes = bytes);
		}
	}

	void _submit() {
		final name = _nameController.text.trim();
		final room = _roomController.text.trim();
		if (name.isEmpty || room.isEmpty) return;
		widget.onSubmit(name, room, _imageBytes);
	}

	@override
		Widget build(BuildContext context) {
				return Scaffold(
					appBar: AppHeader(
						title: 'Add Hosteler',
						username: widget.username,
						onLogout: () {
							Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
						},
						onBack: () => Navigator.of(context).pop(),
					),
					body: Center(
						child: SingleChildScrollView(
							child: Container(
								constraints: const BoxConstraints(maxWidth: 400),
								child: Material(
									color: Colors.white,
									elevation: 10,
									borderRadius: BorderRadius.circular(20),
									child: Padding(
										padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
										child: Column(
											mainAxisSize: MainAxisSize.min,
											children: [
												Text('Add Hosteler', style: Theme.of(context).textTheme.titleLarge?.copyWith(
													color: const Color(0xFF00D09C),
													letterSpacing: 0.2,
												)),
												const SizedBox(height: 24),
												TextField(
													controller: _nameController,
													decoration: InputDecoration(
														hintText: 'Name',
														filled: true,
														fillColor: const Color(0xFFE6FAF6),
														contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
														border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
													),
													style: const TextStyle(fontSize: 18),
												),
												const SizedBox(height: 16),
												TextField(
													controller: _roomController,
													decoration: InputDecoration(
														hintText: 'Room No',
														filled: true,
														fillColor: const Color(0xFFE6FAF6),
														contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
														border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
													),
													style: const TextStyle(fontSize: 18),
												),
												const SizedBox(height: 16),
												Row(
													children: [
														ElevatedButton(
															onPressed: _pickImage,
															child: const Text('Pick Image'),
														),
														if (_imageBytes != null)
															Padding(
																padding: const EdgeInsets.only(left: 16.0),
																child: CircleAvatar(
																	backgroundImage: MemoryImage(_imageBytes!),
																	radius: 24,
																),
															),
													],
												),
												const SizedBox(height: 24),
												SizedBox(
													width: double.infinity,
													child: ElevatedButton(
														onPressed: _submit,
														child: const Text('Submit'),
													),
												),
											],
										),
									),
								),
							),
						),
					),
				);
		}
}
