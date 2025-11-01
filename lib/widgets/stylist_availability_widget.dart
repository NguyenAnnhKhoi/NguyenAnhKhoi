// lib/widgets/stylist_availability_widget.dart
import 'package:flutter/material.dart';
import '../models/stylist.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

/// Widget hiển thị danh sách stylists với trạng thái khả dụng
class StylistAvailabilityWidget extends StatelessWidget {
  final DateTime selectedDateTime;
  final Stylist? selectedStylist;
  final Function(Stylist) onStylistSelected;
  final bool showOnlyAvailable;
  final int durationMinutes; // Thêm tham số duration
  final String? branchId; // Lọc theo chi nhánh (optional)

  const StylistAvailabilityWidget({
    super.key,
    required this.selectedDateTime,
    required this.selectedStylist,
    required this.onStylistSelected,
    this.showOnlyAvailable = false,
    this.durationMinutes = 60, // Mặc định 60 phút
    this.branchId, // Có thể null nếu không cần lọc theo branch
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Stylist>>(
      stream: FirestoreService().getStylists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final allStylists = snapshot.data ?? [];

        return FutureBuilder<Map<String, bool>>(
          future: _checkStylistsAvailability(allStylists),
          builder: (context, availabilitySnapshot) {
            if (availabilitySnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final availabilityMap = availabilitySnapshot.data ?? {};

            // Lọc stylists theo branch nếu có branchId
            var filteredStylists = allStylists;
            if (branchId != null && branchId!.isNotEmpty) {
              filteredStylists = allStylists
                  .where((s) => s.branchId == branchId)
                  .toList();
            }

            // Lọc stylists theo availability nếu cần
            final displayStylists = showOnlyAvailable
                ? filteredStylists
                      .where((s) => availabilityMap[s.id] == true)
                      .toList()
                : filteredStylists;

            if (displayStylists.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Không có stylist khả dụng\nvào thời gian này',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Vui lòng chọn thời gian khác',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayStylists.length,
              itemBuilder: (context, index) {
                final stylist = displayStylists[index];
                final isAvailable = availabilityMap[stylist.id] ?? true;
                final isSelected = selectedStylist?.id == stylist.id;

                return _StylistCard(
                  stylist: stylist,
                  isAvailable: isAvailable,
                  isSelected: isSelected,
                  onTap: isAvailable
                      ? () => onStylistSelected(stylist)
                      : () => _showUnavailableDialog(context, stylist),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, bool>> _checkStylistsAvailability(
    List<Stylist> stylists,
  ) async {
    final firestoreService = FirestoreService();
    final Map<String, bool> availabilityMap = {};

    for (var stylist in stylists) {
      final isAvailable = await firestoreService.checkStylistAvailability(
        stylistId: stylist.id,
        dateTime: selectedDateTime,
        durationMinutes: durationMinutes, // Truyền duration vào
      );
      availabilityMap[stylist.id] = isAvailable;
    }

    return availabilityMap;
  }

  void _showUnavailableDialog(BuildContext context, Stylist stylist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            const SizedBox(width: 12),
            const Text('Stylist không khả dụng'),
          ],
        ),
        content: Text(
          '${stylist.name} đã có lịch hẹn vào thời gian này.\n\nVui lòng chọn stylist khác hoặc chọn thời gian khác.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

class _StylistCard extends StatelessWidget {
  final Stylist stylist;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback onTap;

  const _StylistCard({
    required this.stylist,
    required this.isAvailable,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: isSelected
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      color: !isAvailable ? Colors.grey.shade100 : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(stylist.image),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Icon(
                          Icons.block,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stylist.name,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: !isAvailable
                                  ? Colors.grey.shade600
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              'Đã bận',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: !isAvailable
                              ? Colors.grey.shade400
                              : AppColors.star,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stylist.rating.toStringAsFixed(1),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: !isAvailable
                                ? Colors.grey.shade500
                                : AppColors.starText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.work_outline,
                          size: 14,
                          color: !isAvailable
                              ? Colors.grey.shade400
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            stylist.experience,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: !isAvailable
                                  ? Colors.grey.shade500
                                  : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Hiển thị tên chi nhánh nếu có
                    if (stylist.branchName != null &&
                        stylist.branchName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 14,
                            color: !isAvailable
                                ? Colors.grey.shade400
                                : Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              stylist.branchName!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: !isAvailable
                                    ? Colors.grey.shade500
                                    : Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
