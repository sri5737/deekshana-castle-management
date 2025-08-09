import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'models.dart';
import 'hosteler_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class HostelerFormScreen extends StatefulWidget {
  final Hosteler? hosteler;
  final int? index;
  const HostelerFormScreen({Key? key, this.hosteler, this.index}) : super(key: key);

  @override
  State<HostelerFormScreen> createState() => _HostelerFormScreenState();
}

class _HostelerFormScreenState extends State<HostelerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  final _contactController = TextEditingController();
  DateTime? _joiningDate;
  String _status = 'Active';
  String? _profilePhotoPath;
  String? _registrationDocPath;
  final _aadharController = TextEditingController();
  String? _aadharPhotoPath;
  final _emergencyController = TextEditingController();
  final _contactAddressController = TextEditingController();
  final _workAddressController = TextEditingController();
  final _advanceController = TextEditingController();
  String _roomType = 'AC Single';

  @override
  void initState() {
    super.initState();
    if (widget.hosteler != null) {
      final h = widget.hosteler!;
      _nameController.text = h.name;
      _roomController.text = h.roomNumber;
      _contactController.text = h.contactNumber;
      _joiningDate = h.joiningDate;
      _status = h.status;
      _profilePhotoPath = h.profilePhotoPath;
      _registrationDocPath = h.registrationDocPath;
      _aadharController.text = h.aadharNumber;
      _aadharPhotoPath = h.aadharPhotoPath;
      _emergencyController.text = h.emergencyContact;
      _contactAddressController.text = h.contactAddress;
      _workAddressController.text = h.workAddress;
      _advanceController.text = h.advanceAmount.toString();
      _roomType = h.roomType;
    }
  }

  Future<void> _pickProfilePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _profilePhotoPath = picked.path);
  }

  Future<void> _pickAadharPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _aadharPhotoPath = picked.path);
  }

  Future<void> _pickRegistrationDoc() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
    if (result != null) setState(() => _registrationDocPath = result.files.single.path);
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _joiningDate != null) {
      final hosteler = Hosteler(
        name: _nameController.text,
        roomNumber: _roomController.text,
        contactNumber: _contactController.text,
        joiningDate: _joiningDate!,
        status: _status,
        profilePhotoPath: _profilePhotoPath ?? '',
        registrationDocPath: _registrationDocPath ?? '',
        aadharNumber: _aadharController.text,
        aadharPhotoPath: _aadharPhotoPath ?? '',
        emergencyContact: _emergencyController.text,
        contactAddress: _contactAddressController.text,
        workAddress: _workAddressController.text,
        advanceAmount: double.tryParse(_advanceController.text) ?? 0.0,
        roomType: _roomType,
      );
      final provider = Provider.of<HostelerProvider>(context, listen: false);
      if (widget.index != null) {
        await provider.updateHosteler(widget.index!, hosteler);
      } else {
        await provider.addHosteler(hosteler);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.hosteler == null ? 'Register Hosteler' : 'Edit Hosteler')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(labelText: 'Room Number'),
                validator: (v) => v == null || v.isEmpty ? 'Enter room number' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Enter contact number' : null,
              ),
              ListTile(
                title: Text(_joiningDate == null ? 'Select Joining Date' : 'Joining Date: ${_joiningDate!.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _joiningDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _joiningDate = picked);
                },
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Active', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _status = v!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              ListTile(
                title: Text(_profilePhotoPath == null ? 'Upload Profile Photo' : 'Profile Photo Selected'),
                trailing: Icon(Icons.photo),
                onTap: _pickProfilePhoto,
              ),
              ListTile(
                title: Text(_registrationDocPath == null ? 'Upload Registration Document' : 'Document Selected'),
                trailing: Icon(Icons.attach_file),
                onTap: _pickRegistrationDoc,
              ),
              TextFormField(
                controller: _aadharController,
                decoration: const InputDecoration(labelText: 'Aadhar Card Number'),
                validator: (v) => v == null || v.isEmpty ? 'Enter Aadhar number' : null,
              ),
              ListTile(
                title: Text(_aadharPhotoPath == null ? 'Upload Aadhar Card Photo' : 'Aadhar Photo Selected'),
                trailing: Icon(Icons.photo),
                onTap: _pickAadharPhoto,
              ),
              TextFormField(
                controller: _emergencyController,
                decoration: const InputDecoration(labelText: 'Emergency Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Enter emergency contact' : null,
              ),
              TextFormField(
                controller: _contactAddressController,
                decoration: const InputDecoration(labelText: 'Contact Address'),
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty ? 'Enter contact address' : null,
              ),
              TextFormField(
                controller: _workAddressController,
                decoration: const InputDecoration(labelText: 'Work Address'),
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty ? 'Enter work address' : null,
              ),
              TextFormField(
                controller: _advanceController,
                decoration: const InputDecoration(labelText: 'Advance Amount'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter advance amount' : null,
              ),
              DropdownButtonFormField<String>(
                value: _roomType,
                items: ['AC Single', 'AC Double Sharing', 'Non-AC 4 Sharing'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _roomType = v!),
                decoration: const InputDecoration(labelText: 'Room Type'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.hosteler == null ? 'Register' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
