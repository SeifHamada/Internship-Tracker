import 'package:flutter/material.dart';
import '../services/api_service.dart';

import '../models/application.dart';

class AddEditScreen extends StatefulWidget {
  final String userName;
  final Application? application;

  const AddEditScreen({super.key, required this.userName, this.application});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

// Text input fields
class _AddEditScreenState extends State<AddEditScreen> {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  //Variables
  DateTime? _applicationDate;
  DateTime? _applicationDeadline;
  String? _selectedStatus;
  bool _isLoading = false;
  // status list
  final List<String> _statusOptions = [
    'Applied',
    'Interview',
    'Offer',
    'Rejected',
    'Ghosted',
  ];
  // free controllers from memory
  @override
  void initState() {
    super.initState();
    if (widget.application != null) {
      _companyController.text = widget.application!.company;
      _roleController.text = widget.application!.role;
      _applicationDate = widget.application!.applicationDate;
      _applicationDeadline = widget.application!.deadlineDate;
      _selectedStatus = widget.application!.status;
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  // opens calender to store dates
  Future<void> _pickDate(Function(DateTime) onPicked) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  // validates fields and saves application to backend
  Future<void> _saveApplication() async {
    if (_isLoading) return;

    // name validation
    if (_companyController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a company name')));
      return;
    }
    // role validation
    if (_roleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a role')));
      return;
    }
    // apply date validation
    if (_applicationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an application date')),
      );
      return;
    }
    // status validation
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a status')));
      return;
    }

    // deadline validation
    if (_applicationDeadline != null &&
        _applicationDeadline!.isBefore(_applicationDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deadline cannot be before application date')),
      );
      return;
    }

    setState(() => _isLoading = true);
    // match backend schema with fields
    final Map<String, dynamic> data = {
      'company': _companyController.text,
      'role': _roleController.text,
      'application_date': _applicationDate!.toIso8601String().split('T')[0],
      'deadline_date': _applicationDeadline?.toIso8601String().split('T')[0],
      'status': _selectedStatus,
    };
    // send to backend
    try {
      if (widget.application == null) {
        await ApiService(widget.userName).createApplication(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application saved successfully')),
        );
        _companyController.clear();
        _roleController.clear();
        setState(() {
          _applicationDate = null;
          _applicationDeadline = null;
          _selectedStatus = null;
          _isLoading = false;
        });
      } else {
        await ApiService(widget.userName).updateApplication(widget.application!.id, data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application updated successfully')),
        );
        Navigator.pop(context, true); // Pop to return and signal refresh
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save application. Is the backend running?'),
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return date.toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      //app bar
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: Text(
          widget.application == null ? "Add Internship" : "Edit Internship",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //company field
                Text(
                  "Company",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _companyController,
                  decoration: InputDecoration(
                    hintText: 'Enter company name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                //role field
                Text(
                  "Internship Role",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _roleController,
                  decoration: InputDecoration(
                    hintText: 'Enter role (e.g. Data Scientist)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                // date applied field
                Text(
                  "Date Applied",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  onTap: () => _pickDate((date) => _applicationDate = date),
                  decoration: InputDecoration(
                    hintText: _applicationDate == null
                        ? 'Date Applied'
                        : _formatDate(_applicationDate),
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                //deadline date field
                Text(
                  "Deadline Date",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  onTap: () => _pickDate((date) => _applicationDeadline = date),
                  decoration: InputDecoration(
                    hintText: _applicationDeadline == null
                        ? 'Deadline Date'
                        : _formatDate(_applicationDeadline),
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                //status field
                Text(
                  "Status",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  hint: Text('Select status'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
                SizedBox(height: 40),
                //save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'SAVE INTERNSHIP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
