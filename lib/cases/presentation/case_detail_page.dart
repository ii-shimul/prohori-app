import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../domain/case_detail.dart';
import 'case_providers.dart';

class CaseDetailPage extends ConsumerStatefulWidget {
  const CaseDetailPage({super.key, required this.caseId});
  final String caseId;

  @override
  ConsumerState<CaseDetailPage> createState() => _CaseDetailPageState();
}

class _CaseDetailPageState extends ConsumerState<CaseDetailPage> {
  final _noteController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _sendNote() async {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(casesApiProvider).addNote(widget.caseId, note);
      _noteController.clear();
      ref.invalidate(caseDetailProvider(widget.caseId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noteSent)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.actionFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final result = ref.watch(caseDetailProvider(widget.caseId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to alerts',
          onPressed: () => context.go('/alerts'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(strings.caseTimeline, overflow: TextOverflow.ellipsis),
      ),
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: ElevatedButton(onPressed: () => ref.invalidate(caseDetailProvider(widget.caseId)), child: const Text('Retry'))),
        data: (caseDetail) => SafeArea(
          top: false,
          child: Column(children: [
            _CaseStatus(status: caseDetail.status),
            Expanded(
              child: caseDetail.timeline.isEmpty
                  ? Center(child: Text(strings.timelineEmpty))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: caseDetail.timeline.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) => _TimelineEvent(event: caseDetail.timeline[index]),
                    ),
            ),
            _NoteComposer(
              controller: _noteController,
              sending: _sending,
              onSend: _sendNote,
            ),
          ]),
        ),
      ),
    );
  }
}

class _CaseStatus extends StatelessWidget {
  const _CaseStatus({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: AppPalette.extraSurface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.assignment_turned_in_outlined),
            const SizedBox(width: 12),
            Flexible(
              child: Text('${strings.caseStatus}: $status', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({required this.event});
  final CaseTimelineEvent event;
  @override
  Widget build(BuildContext context) => Card(
        color: AppPalette.extraSurface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(event.description, maxLines: 5, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(event.occurredAt?.toLocal().toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppPalette.inkMuted)),
          ]),
        ),
      );
}

class _NoteComposer extends StatelessWidget {
  const _NoteComposer({required this.controller, required this.sending, required this.onSend});
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(strings.addNote, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(controller: controller, minLines: 2, maxLines: 4, decoration: InputDecoration(hintText: strings.noteHint)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: sending ? null : onSend, child: Text(sending ? strings.sendingNote : strings.sendNote, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}
