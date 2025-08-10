// ...existing code from hosteler_list_screen.dart...
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../providers/hosteler_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_header.dart';
import '../screens/hosteler_form_screen.dart';
import '../models.dart';


class HostelerListScreen extends StatelessWidget {
	final String username;
	const HostelerListScreen({super.key, required this.username});

	@override
	Widget build(BuildContext context) {
		final provider = Provider.of<HostelerProvider>(context);
			return DefaultTabController(
				length: 2,
				child: Scaffold(
					appBar: AppHeader(
						title: 'Hostelers',
						username: username,
						onLogout: () {
							final auth = Provider.of<AuthProvider>(context, listen: false);
							auth.logout();
							Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
						},
						tabs: const [
							Tab(text: 'Hostelers'),
							Tab(text: 'Finance'),
						],
					),
					body: TabBarView(
						children: [
							Center(
								child: Container(
									constraints: const BoxConstraints(maxWidth: 600),
									padding: const EdgeInsets.all(0),
									child: Padding(
										padding: const EdgeInsets.all(20.0),
										child: provider.hostelers.isEmpty
												? Center(child: Text('No hostelers found', style: Theme.of(context).textTheme.titleMedium))
												: ListView.builder(
													itemCount: provider.hostelers.length,
													itemBuilder: (context, index) {
														final hosteler = provider.hostelers[index];
														return Card(
															elevation: 4,
															shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
															margin: const EdgeInsets.symmetric(vertical: 10),
															child: ListTile(
																leading: hosteler.profilePhotoBytes != null
																	? CircleAvatar(
																		backgroundImage: MemoryImage(Uint8List.fromList(hosteler.profilePhotoBytes!)),
																		radius: 26,
																)
																: const CircleAvatar(
																	radius: 26,
																	child: Icon(Icons.person),
																),
															title: Text(hosteler.name, style: Theme.of(context).textTheme.titleMedium),
															subtitle: Text('Room: ${hosteler.roomNumber}', style: Theme.of(context).textTheme.bodyMedium),
															trailing: IconButton(
																icon: const Icon(Icons.delete, color: Color(0xFF00D09C)),
																onPressed: () => provider.removeHosteler(index),
															),
														),
													);
												},
											),
									),
								),
							),
							Center(
								child: Text('Finance coming soon', style: Theme.of(context).textTheme.titleMedium),
							),
						],
					),
					floatingActionButton: Builder(
						builder: (context) {
							final controller = DefaultTabController.of(context);
							if (controller == null || controller.animation == null) {
								// Fallback: hide FAB if no controller.
								return const SizedBox.shrink();
							}
							return AnimatedBuilder(
								animation: controller.animation!,
								builder: (context, _) {
									final isHostelersTab = controller.index == 0;
									if (!isHostelersTab) return const SizedBox.shrink();
									return FloatingActionButton(
										onPressed: () async {
											await Navigator.push(
												context,
												MaterialPageRoute(
													builder: (context) => HostelerFormScreen(
														onSubmit: (name, room, imageBytes) {
															final hosteler = Hosteler(
																name: name,
																roomNumber: room,
																contactNumber: '',
																joiningDate: DateTime.now(),
																status: 'Active',
																profilePhotoPath: '',
																profilePhotoBytes: imageBytes,
																registrationDocPath: '',
																registrationDocBytes: null,
																aadharNumber: '',
																aadharPhotoPath: '',
																aadharPhotoBytes: null,
																emergencyContact: '',
																contactAddress: '',
																workAddress: '',
																advanceAmount: 0.0,
																roomType: '',
															);
															provider.addHosteler(hosteler);
															Navigator.pop(context);
														},
														username: username,
													),
												),
											);
									},
									backgroundColor: const Color(0xFF00D09C),
									child: const Icon(Icons.add, color: Colors.white),
								);
							},
						);
					},
					),
				),
		);
	}
}
