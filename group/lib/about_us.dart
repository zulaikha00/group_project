import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Team'),
      ),
      body: ListView.builder(
        itemCount: teamMembers.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teamMembers[index].name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    teamMembers[index].studentId,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TeamMember {
  final String name;
  final String studentId;

  const TeamMember({
    required this.name,
    required this.studentId,
  });
}

final List<TeamMember> teamMembers = [
  TeamMember(
    name: 'SITI NUR ZULAIKHA BINTI ABDUL FATAH',
    studentId: '2022812766',
  ),
  TeamMember(
    name: 'ARIFAH BINTI ABDUL RASYID',
    studentId: '2023388429',
  ),
  TeamMember(
    name: 'NURUL ALIA AISYAH BINTI ANUAR',
    studentId: '2022646588',
  ),
  TeamMember(
    name: 'SITI ATIQAH ILYANA BINTI MOHAMAD RIZAL',
    studentId: '2022645994',
  ),
  TeamMember(
    name: 'WAN NUR BALQIS BINTI WAN MOHD ISKANDAR',
    studentId: '2022478682',
  ),
  TeamMember(
    name: 'SAFURA ALIAH BINTI RAZALL',
    studentId: '2022495866',
  ),
  TeamMember(
    name: 'NUR SYAKIRAH BINTI RACHMAT',
    studentId: '2022862254',
  ),
  TeamMember(
    name: 'NUR ALIA TASNIM BINTI HARMA AZMI',
    studentId: '2022842264',
  ),
];
