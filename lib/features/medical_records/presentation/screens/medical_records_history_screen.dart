import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_card.dart';
import 'package:smartclinic/features/medical_records/data/model/medical_records_response.dart';
import 'package:smartclinic/features/medical_records/presentation/manager/medical_records_cubit.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:smartclinic/injection_dependency.dart';

class MedicalRecordsHistoryScreen extends StatefulWidget {
  const MedicalRecordsHistoryScreen({super.key});

  @override
  State<MedicalRecordsHistoryScreen> createState() =>
      _MedicalRecordsHistoryScreenState();
}

class _MedicalRecordsHistoryScreenState
    extends State<MedicalRecordsHistoryScreen> {
  final UserSession _userSession = getIt<UserSession>();
  Future<List<UploadRecordResponse>>? _recordsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recordsFuture ??= _loadRecords();
  }

  Future<List<UploadRecordResponse>> _loadRecords() async {
    final patientId = _userSession.userId?.trim() ?? '';
    if (patientId.isEmpty) {
      return <UploadRecordResponse>[];
    }

    return context.read<MedicalRecordsCubit>().getMedicalRecords(patientId);
  }

  Future<void> _deleteRecord(UploadRecordResponse record) async {
    final id = record.id;
    if (id == null) {
      CherryToast.error(
        title: const Text('Delete failed'),
        description: const Text('Record id is missing.'),
      ).show(context);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete record?'),
          content: const Text(
            'This will remove the medical record from history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success = await context
        .read<MedicalRecordsCubit>()
        .deleteMedicalRecord(id);
    if (!mounted) {
      return;
    }

    if (success) {
      CherryToast.success(
        title: const Text('Deleted'),
        description: const Text('Medical record removed.'),
      ).show(context);
      setState(() {
        _recordsFuture = _loadRecords();
      });
    } else {
      CherryToast.error(
        title: const Text('Delete failed'),
        description: const Text('Could not delete the medical record.'),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(
                title: 'Past Medical Records',
                subTitle: 'Review the records you have uploaded before.',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<UploadRecordResponse>>(
                  future: _recordsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.skyBlue,
                        ),
                      );
                    }

                    final records = snapshot.data ?? <UploadRecordResponse>[];

                    if (records.isEmpty) {
                      return Center(
                        child: Text(
                          'No past medical records yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.9,
                            ),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _HistoryRecordTile(
                          record: records[index],
                          onDeletePressed: () => _deleteRecord(records[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryRecordTile extends StatelessWidget {
  const _HistoryRecordTile({
    required this.record,
    required this.onDeletePressed,
  });

  final UploadRecordResponse record;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final description = [
      if ((record.description ?? '').trim().isNotEmpty)
        record.description!.trim(),
      if ((record.fileUrl ?? '').trim().isNotEmpty) record.fileUrl!.trim(),
    ].join('\n');

    return MedicalRecordCard(
      title: (record.title ?? 'Medical record').trim(),
      description: description.isEmpty
          ? 'Uploaded medical record'
          : description,
      showEditButton: false,
      showDeleteButton: true,
      onEditPressed: () {},
      onDeletePressed: onDeletePressed,
    );
  }
}
