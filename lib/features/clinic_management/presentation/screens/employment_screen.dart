import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_request_model.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_response_model.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_cubit.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_state.dart';

class EmploymentScreen extends StatefulWidget {
  const EmploymentScreen({super.key, this.clinicId});
  final int? clinicId;

  @override
  State<EmploymentScreen> createState() => _EmploymentScreenState();
}

class _EmploymentScreenState extends State<EmploymentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<EmploymentRequestModel> _received = [];
  List<EmploymentRequestModel> _sent = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClinicManagementCubit>().getMyEmploymentRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
        title: const Text(
          'Employment',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(3),
                dividerColor: Colors.transparent,
                labelColor: AppColors.deepNavy,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Received'),
                  Tab(text: 'Sent'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: BlocConsumer<ClinicManagementCubit, ClinicManagementState>(
        listener: (context, state) {
          if (state is GetMyEmploymentRequestsLoading) {
            setState(() => _isLoading = true);
          } else if (state is GetMyEmploymentRequestsSuccess) {
            setState(() {
              _isLoading = false;
              _received = state.response.requests
                  .where((r) => r.roleInRequest?.toLowerCase() == 'receiver')
                  .toList();
              _sent = state.response.requests
                  .where((r) => r.roleInRequest?.toLowerCase() == 'sender')
                  .toList();
            });
          } else if (state is GetMyEmploymentRequestsFailure) {
            setState(() => _isLoading = false);
            CherryToast.error(
              title: const Text('Error'),
              description: Text(state.errorMessage),
            ).show(context);
          }

          if (state is RespondToEmploymentSuccess) {
            CherryToast.success(
              title: const Text('Done'),
              description: const Text('Response submitted successfully'),
            ).show(context);
          } else if (state is RespondToEmploymentFailure) {
            CherryToast.error(
              title: const Text('Error'),
              description: Text(state.errorMessage),
            ).show(context);
          }

          if (state is SendEmploymentSuccess) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            CherryToast.success(
              title: const Text('Sent'),
              description: const Text('Employment request sent successfully'),
            ).show(context);
          } else if (state is SendEmploymentFailure) {
            CherryToast.error(
              title: const Text('Error'),
              description: Text(state.errorMessage),
            ).show(context);
          }
        },
        builder: (context, state) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildReceivedTab(context, state),
              _buildSentTab(context, state),
            ],
          );
        },
      ),
    );
  }

  // ── Received ────────────────────────────────────────────────────────────────

  Widget _buildReceivedTab(BuildContext context, ClinicManagementState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              const Text(
                'Incoming Requests',
                style: TextStyle(
                  color: AppColors.deepNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              if (_received.isNotEmpty)
                _BouncingCountBadge(count: _received.length),
            ],
          ),
        ),
        Expanded(
          child: _received.isEmpty
              ? _buildEmptyState('No incoming requests')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: _received.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _RequestCard(
                    request: _received[i],
                    onViewDetails: () =>
                        _showDetailsSheet(context, _received[i]),
                  ),
                ),
        ),
      ],
    );
  }

  // ── Sent ────────────────────────────────────────────────────────────────────

  Widget _buildSentTab(BuildContext context, ClinicManagementState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: _AnimatedSendButton(
            onTap: () => _showSendRequestSheet(context),
          ),
        ),
        if (_sent.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Sent Requests',
              style: TextStyle(
                color: AppColors.deepNavy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        Expanded(
          child: _sent.isEmpty
              ? _buildEmptyState('No sent requests yet')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: _sent.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _SentRequestCard(request: _sent[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.work_outline,
            size: 60,
            color: AppColors.textSecondary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Details bottom sheet ────────────────────────────────────────────────────

  void _showDetailsSheet(BuildContext context, EmploymentRequestModel req) {
    final cubit = context.read<ClinicManagementCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailsSheet(req: req, cubit: cubit),
    );
  }

  // ── Send request bottom sheet ───────────────────────────────────────────────

  void _showSendRequestSheet(BuildContext context) {
    final cubit = context.read<ClinicManagementCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _SendRequestSheet(cubit: cubit, defaultClinicId: widget.clinicId),
    );
  }
}

// ── Request card (Received tab) ─────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onViewDetails});
  final EmploymentRequestModel request;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.deepNavy,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.doctorName ?? 'Unknown Doctor',
                      style: const TextStyle(
                        color: AppColors.deepNavy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.clinicName ?? '',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: request.status),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sent request card ───────────────────────────────────────────────────────

class _SentRequestCard extends StatelessWidget {
  const _SentRequestCard({required this.request});
  final EmploymentRequestModel request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_hospital_outlined,
              color: AppColors.deepNavy,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.doctorName ?? 'Unknown Doctor',
                  style: const TextStyle(
                    color: AppColors.deepNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.clinicName ?? '',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(status: request.status),
        ],
      ),
    );
  }
}

// ── Status chip ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({this.status});
  final String? status;

  @override
  Widget build(BuildContext context) {
    final s = status?.toLowerCase() ?? '';
    Color bg;
    Color fg;
    if (s == 'accepted') {
      bg = AppColors.success.withValues(alpha: 0.15);
      fg = AppColors.success;
    } else if (s == 'rejected' || s == 'declined') {
      bg = Colors.red.withValues(alpha: 0.12);
      fg = Colors.red;
    } else {
      bg = AppColors.blueAction.withValues(alpha: 0.12);
      fg = AppColors.blueAction;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ?? 'Pending',
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Details bottom sheet widget ─────────────────────────────────────────────

class _DetailsSheet extends StatefulWidget {
  const _DetailsSheet({required this.req, required this.cubit});
  final EmploymentRequestModel req;
  final ClinicManagementCubit cubit;

  @override
  State<_DetailsSheet> createState() => _DetailsSheetState();
}

class _DetailsSheetState extends State<_DetailsSheet> {
  final _feedbackCtrl = TextEditingController();
  bool _feedbackError = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  bool get _hasFees =>
      widget.req.inClinicFee != null ||
      widget.req.onlineFee != null ||
      widget.req.followUpFee != null ||
      widget.req.homeVisitFee != null ||
      widget.req.emergencyFee != null;

  void _respond(bool accept) {
    if (_feedbackCtrl.text.trim().isEmpty) {
      setState(() => _feedbackError = true);
      return;
    }
    Navigator.pop(context);
    widget.cubit.respondToEmployment(
      requestId: widget.req.id!,
      accept: accept,
      feedback: _feedbackCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DetailRow(
                      icon: Icons.local_hospital_outlined,
                      label: 'Clinic',
                      value: widget.req.clinicName ?? '—',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.person_outline,
                      label: 'Doctor',
                      value: widget.req.doctorName ?? '—',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.info_outline,
                      label: 'Status',
                      value: widget.req.status ?? '—',
                    ),
                    if (_hasFees) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Fees',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _FeesCard(req: widget.req),
                    ],
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Feedback',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _feedbackCtrl,
                      maxLines: 3,
                      onChanged: (_) {
                        if (_feedbackError) {
                          setState(() => _feedbackError = false);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your feedback (required)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: _feedbackError
                            ? 'Feedback is required'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _respond(false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Decline',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _respond(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Accept',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Send request bottom sheet widget ───────────────────────────────────────

class _SendRequestSheet extends StatefulWidget {
  const _SendRequestSheet({required this.cubit, this.defaultClinicId});
  final ClinicManagementCubit cubit;
  final int? defaultClinicId;

  @override
  State<_SendRequestSheet> createState() => _SendRequestSheetState();
}

class _SendRequestSheetState extends State<_SendRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _doctorIdCtrl = TextEditingController();
  final _clinicIdCtrl = TextEditingController();
  final _clinicFeeCtrl = TextEditingController();
  final _homeVisitFeeCtrl = TextEditingController();
  final _onlineFeeCtrl = TextEditingController();
  final _followUpFeeCtrl = TextEditingController();
  final _emergencyFeeCtrl = TextEditingController();
  final _sessionDurationCtrl = TextEditingController();

  final List<_ScheduleSlot> _slots = [_ScheduleSlot()];

  @override
  void initState() {
    super.initState();
    if (widget.defaultClinicId != null) {
      _clinicIdCtrl.text = widget.defaultClinicId.toString();
    }
  }

  @override
  void dispose() {
    _doctorIdCtrl.dispose();
    _clinicIdCtrl.dispose();
    _clinicFeeCtrl.dispose();
    _homeVisitFeeCtrl.dispose();
    _onlineFeeCtrl.dispose();
    _followUpFeeCtrl.dispose();
    _emergencyFeeCtrl.dispose();
    _sessionDurationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    for (final slot in _slots) {
      if (slot.day == null || slot.startTime == null || slot.endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all schedule slots')),
        );
        return;
      }
    }
    final request = SendEmploymentRequestModel(
      doctorId: _doctorIdCtrl.text.trim(),
      clinicId: int.parse(_clinicIdCtrl.text.trim()),
      inClinicFee: double.parse(_clinicFeeCtrl.text.trim()),
      homeVisitFee: double.parse(_homeVisitFeeCtrl.text.trim()),
      onlineFee: double.parse(_onlineFeeCtrl.text.trim()),
      followUpFee: double.parse(_followUpFeeCtrl.text.trim()),
      emergencyFee: double.parse(_emergencyFeeCtrl.text.trim()),
      sessionDuration: int.parse(_sessionDurationCtrl.text.trim()),
      schedules: _slots
          .map(
            (s) => ScheduleSlotModel(
              dayOfWeek: s.day!,
              startTime: s.startTime!,
              endTime: s.endTime!,
              maxPatients: s.maxPatients,
            ),
          )
          .toList(),
    );
    widget.cubit.sendEmploymentRequest(request);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Send Employment Request',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Doctor & Clinic'),
                      const SizedBox(height: 10),
                      _FormField(
                        controller: _doctorIdCtrl,
                        label: 'Doctor ID',
                        hint: 'Enter doctor\'s ID',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      _FormField(
                        controller: _clinicIdCtrl,
                        label: 'Clinic ID',
                        hint: 'Enter clinic ID',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (int.tryParse(v.trim()) == null)
                            return 'Must be a number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _SectionLabel('Fees (EGP)'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              controller: _clinicFeeCtrl,
                              label: 'Examination',
                              keyboardType: TextInputType.number,
                              validator: _numValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _FormField(
                              controller: _onlineFeeCtrl,
                              label: 'Online',
                              keyboardType: TextInputType.number,
                              validator: _numValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              controller: _homeVisitFeeCtrl,
                              label: 'Home Visit',
                              keyboardType: TextInputType.number,
                              validator: _numValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _FormField(
                              controller: _followUpFeeCtrl,
                              label: 'Follow Up',
                              keyboardType: TextInputType.number,
                              validator: _numValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              controller: _emergencyFeeCtrl,
                              label: 'Emergency',
                              keyboardType: TextInputType.number,
                              validator: _numValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _FormField(
                              controller: _sessionDurationCtrl,
                              label: 'Session (mins)',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Required';
                                if (int.tryParse(v.trim()) == null)
                                  return 'Must be a number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SectionLabel('Schedules'),
                          TextButton.icon(
                            onPressed: () =>
                                setState(() => _slots.add(_ScheduleSlot())),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Slot'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.blueAction,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._slots.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ScheduleSlotWidget(
                            slot: e.value,
                            index: e.key,
                            canRemove: _slots.length > 1,
                            onRemove: () =>
                                setState(() => _slots.removeAt(e.key)),
                            onChanged: () => setState(() {}),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueAction,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Send Request',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _numValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (double.tryParse(v.trim()) == null) return 'Invalid';
    return null;
  }
}

// ── Schedule slot data model ────────────────────────────────────────────────

class _ScheduleSlot {
  String? day;
  String? startTime;
  String? endTime;
  int maxPatients = 10;
}

// ── Schedule slot form widget ───────────────────────────────────────────────

class _ScheduleSlotWidget extends StatefulWidget {
  const _ScheduleSlotWidget({
    required this.slot,
    required this.index,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });
  final _ScheduleSlot slot;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  State<_ScheduleSlotWidget> createState() => _ScheduleSlotWidgetState();
}

class _ScheduleSlotWidgetState extends State<_ScheduleSlotWidget> {
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final _maxPatientsCtrl = TextEditingController(text: '10');

  @override
  void dispose() {
    _maxPatientsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isStart) {
        widget.slot.startTime = formatted;
      } else {
        widget.slot.endTime = formatted;
      }
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Slot ${widget.index + 1}',
                style: const TextStyle(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (widget.canRemove)
                GestureDetector(
                  onTap: widget.onRemove,
                  child: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: widget.slot.day,
            hint: const Text('Day of Week'),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: _days
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (v) {
              setState(() => widget.slot.day = v);
              widget.onChanged();
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _TimeTile(
                  label: widget.slot.startTime ?? 'Start Time',
                  onTap: () => _pickTime(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeTile(
                  label: widget.slot.endTime ?? 'End Time',
                  onTap: () => _pickTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _maxPatientsCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Max Patients',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (v) {
              widget.slot.maxPatients = int.tryParse(v) ?? 10;
            },
          ),
        ],
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail row ──────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 18, color: AppColors.deepNavy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.deepNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Fees card ───────────────────────────────────────────────────────────────

class _FeesCard extends StatelessWidget {
  const _FeesCard({required this.req});
  final EmploymentRequestModel req;

  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<String, num?>>[
      MapEntry('Examination', req.inClinicFee),
      MapEntry('Online', req.onlineFee),
      MapEntry('Follow Up', req.followUpFee),
      MapEntry('Home Visit', req.homeVisitFee),
      MapEntry('Emergency', req.emergencyFee),
    ].where((e) => e.value != null).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'EGP ${e.value!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.deepNavy,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Animated send button (matches clinic management grid card style) ─────────

class _AnimatedSendButton extends StatefulWidget {
  const _AnimatedSendButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AnimatedSendButton> createState() => _AnimatedSendButtonState();
}

class _AnimatedSendButtonState extends State<_AnimatedSendButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) async {
        setState(() => _scale = 1.0);
        await Future.delayed(const Duration(milliseconds: 80));
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -32,
                right: -34,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 20,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Send Employment Request',
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Recruit a doctor to your clinic',
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bouncing count badge (same as clinic management) ────────────────────────

class _BouncingCountBadge extends StatefulWidget {
  const _BouncingCountBadge({required this.count});
  final int count;

  @override
  State<_BouncingCountBadge> createState() => _BouncingCountBadgeState();
}

class _BouncingCountBadgeState extends State<_BouncingCountBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      reverseDuration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -3.0 * t),
          child: Transform.scale(scale: 1.0 + (0.04 * t), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.blueAction.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '${widget.count} NEW',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.deepNavy,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
