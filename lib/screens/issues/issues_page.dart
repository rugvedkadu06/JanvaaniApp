import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Assuming IssueController exists and has searchIssues and filteredIssues
// class IssueController extends GetxController {
//   RxList<dynamic> issues = <dynamic>[].obs;
//   RxList<dynamic> filteredIssues = <dynamic>[].obs;
//
//   void searchIssues(String query) {
//     if (query.isEmpty) {
//       filteredIssues.value = issues;
//     } else {
//       filteredIssues.value = issues.where((issue) => 
//         issue.title.toLowerCase().contains(query.toLowerCase())
//       ).toList();
//     }
//   }
// }

// CONVERTED TO STATEFULWIDGET to manage the TextEditingController
class IssuesPage extends StatefulWidget {
  const IssuesPage({super.key});

  @override
  State<IssuesPage> createState() => _IssuesPageState();
}

class _IssuesPageState extends State<IssuesPage> {
  // 1. Initialize the TextEditingController
  final TextEditingController _searchController = TextEditingController();

  // Get the controller once in initState or build, here we use build
  // as Get.find is usually fine in build.

  @override
  void dispose() {
    // 2. DISPOSE the controller to prevent memory leaks
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: Replace `IssueController` with your actual controller class name if different
    // The previous code implied IssueController was defined elsewhere.
    final issueCtrl = Get.find<IssueController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            // 3. ASSIGN the controller
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search issues...',
              prefixIcon: const Icon(Icons.search),
              // Add a functional clear button
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  // Clear the text and reset the search
                  _searchController.clear();
                  issueCtrl.searchIssues('');
                  // Manually trigger a rebuild to hide the clear button
                  setState(() {});
                },
              )
                  : null, // Hide clear button when text is empty
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (query) {
              issueCtrl.searchIssues(query);
              // Trigger a rebuild to show/hide the clear button dynamically
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: Obx(() => ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: issueCtrl.filteredIssues.length,
            itemBuilder: (context, index) {
              final issue = issueCtrl.filteredIssues[index];
              // ...existing issue list item code...
              // Placeholder for missing Issue list item code:
              return ListTile(
                title: Text(issue.title ?? 'No Title'),
                subtitle: Text('ID: ${issue.id}'),
              );
            },
          )),
        ),
      ],
    );
  }
}