// lib/screens/issues/issue_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/issue_controller.dart';
import '../../widgets/issue_card_placeholder.dart';
import '../../widgets/issue_card.dart';

class IssueListPage extends StatelessWidget {
  const IssueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final issueCtrl = Get.find<IssueController>();
    // --- UPDATED STATUSES LIST ---
    final statuses = ['all', 'pending', 'approved', 'inProgress', 'resolved', 'rejected']; // <-- Added 'rejected'

    return Column(
      children: [
        _buildSearchBar(issueCtrl),
        _buildHeader(issueCtrl),
        const SizedBox(height: 8),
        _buildStatusChips(issueCtrl, statuses),
        Expanded(child: _buildIssueList(issueCtrl)),
      ],
    );
  }

  // ---------------- Search Bar ----------------
  Widget _buildSearchBar(IssueController issueCtrl) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: issueCtrl.searchIssues, // <-- reactive search
              decoration: InputDecoration(
                hintText: 'searchIssues'.tr,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => IconButton(
            onPressed: issueCtrl.toggleActiveIssues,
            icon: Icon(
              issueCtrl.showActiveIssues.value
                  ? Icons.public
                  : Icons.person,
              color: issueCtrl.showActiveIssues.value
                  ? Colors.blue
                  : Colors.grey,
            ),
            tooltip: issueCtrl.showActiveIssues.value
                ? 'Show My Issues'
                : 'Show All Issues',
          )),
        ],
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _buildHeader(IssueController issueCtrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: Text(
              // You might want to update this text based on showActiveIssues or selectedStatus
              issueCtrl.showActiveIssues.value
                  ? 'All Active Issues' // Note: 'rejected' issues are typically NOT considered 'active'
                  : 'My Issues',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      )),
    );
  }

  // ---------------- Status Chips ----------------
  Widget _buildStatusChips(
      IssueController issueCtrl, List<String> statuses) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: statuses.map((status) {
          return Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              // Give rejected a distinctive color
              label: Text(status.tr),
              selected: issueCtrl.selectedStatus.value == status,
              selectedColor: status == 'rejected' ? Colors.red.shade100 : Colors.blue.shade100, // <-- Distinct color for rejected
              onSelected: (isSelected) {
                if (isSelected) issueCtrl.filterByStatus(status);
              },
            ),
          ));
        }).toList(),
      ),
    );
  }

  // ---------------- Issue List ----------------
  Widget _buildIssueList(IssueController issueCtrl) {
    return Obx(() {
      if (issueCtrl.isLoading.value) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: 5,
          itemBuilder: (_, __) => const IssueCardPlaceholder(),
        );
      }

      if (issueCtrl.filteredIssues.isEmpty) {
        return Center(
          child: Text(
            issueCtrl.searchQuery.value.isNotEmpty
                ? 'No results found'.tr
                : 'noIssues'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => issueCtrl.loadIssues(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: issueCtrl.filteredIssues.length,
          itemBuilder: (context, index) =>
              IssueCard(issue: issueCtrl.filteredIssues[index]),
        ),
      );
    });
  }
}