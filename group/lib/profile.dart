import 'package:flutter/material.dart';
import 'api_service.dart'; // Make sure to import your ApiService

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  bool isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch the user profile
  Future<void> _fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });

    var response = await ApiService().getProfile();

    if (response.containsKey('error')) {
      // Handle error
      setState(() {
        isLoading = false;
      });
      print(response['error']);
    } else {
      // Update UI with fetched data
      setState(() {
        name = response['name'];
        email = response['email'];
        _nameController.text = name;
        _emailController.text = email;
        isLoading = false;
      });
    }
  }

  // Update user profile
  Future<void> _updateProfile() async {
    String updatedName = _nameController.text;
    String updatedEmail = _emailController.text;

    var response = await ApiService().updateProfile(updatedName, updatedEmail);

    if (response.containsKey('error')) {
      // Handle error
      print(response['error']);
    } else {
      // Handle success
      setState(() {
        name = updatedName;
        email = updatedEmail;
      });
      print('Profile updated successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display name and email
                  Text('Name: $name', style: TextStyle(fontSize: 18)),
                  Text('Email: $email', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),

                  // Editable text fields
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Edit Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Edit Email'),
                  ),
                  SizedBox(height: 20),

                  // Update button
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text('Update Profile'),
                  ),
                ],
              ),
            ),
    );
  }
}
