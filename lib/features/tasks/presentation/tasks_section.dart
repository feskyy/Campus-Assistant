import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_assistant/core/di/task_providers.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;

import '../domain/personal_task.dart';

Future<void> editPersonalTask(
  BuildContext context, {
  PersonalTask? task,
  DateTime? day,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _TaskEditor(task: task, day: day),
);

class TasksSection extends ConsumerStatefulWidget {
  const TasksSection({super.key, this.day});
  final DateTime? day;
  @override
  ConsumerState<TasksSection> createState() => _TasksSectionState();
}

class _TasksSectionState extends ConsumerState<TasksSection> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context), l = strings(context);
    final now = ref.watch(clockProvider).asData?.value ?? DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.tasksTitle, style: t.sectionStyle)),
            SizedBox(width: t.space8),
            TextButton.icon(
              key: ValueKey(
                widget.day == null ? 'add-home-task' : 'add-day-task',
              ),
              onPressed: () => editPersonalTask(context, day: widget.day),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.tasksAdd),
            ),
          ],
        ),
        SizedBox(height: t.space8),
        ref
            .watch(personalTasksProvider)
            .when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => ui.ErrorState(
                title: l.tasksLoadError,
                message: l.tasksLocalHint,
                onRetry: () => ref.invalidate(personalTasksProvider),
              ),
              data: (tasks) {
                final items =
                    tasks
                        .where(
                          (task) =>
                              widget.day == null ||
                              task.dueDate != null &&
                                  DateUtils.isSameDay(task.dueDate, widget.day),
                        )
                        .toList()
                      ..sort((a, b) {
                        if (a.completed != b.completed) {
                          return a.completed ? 1 : -1;
                        }
                        if (a.dueDate == null) {
                          return b.dueDate == null ? a.id.compareTo(b.id) : 1;
                        }
                        return b.dueDate == null
                            ? -1
                            : a.dueDate!.compareTo(b.dueDate!);
                      });
                final visible = expanded ? items : items.take(4);
                return ui.CampusCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(t.space16),
                        child: Text(
                          items.isEmpty
                              ? l.tasksEmpty
                              : '${l.tasksOpen}: ${items.where((task) => !task.completed).length} · ${l.tasksDone}: ${items.where((task) => task.completed).length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      for (final task in visible)
                        _TaskRow(key: ValueKey(task.id), task: task, now: now),
                      if (items.length > 4)
                        TextButton(
                          onPressed: () => setState(() => expanded = !expanded),
                          child: Text(
                            expanded ? l.tasksCollapse : l.tasksShowAll,
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.all(t.space16),
                        child: Text(
                          l.tasksLocalHint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ],
    );
  }
}

class _TaskRow extends ConsumerStatefulWidget {
  const _TaskRow({super.key, required this.task, required this.now});
  final PersonalTask task;
  final DateTime now;
  @override
  ConsumerState<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends ConsumerState<_TaskRow> {
  bool busy = false;
  Future<void> change(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings(context).tasksSaveError)),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task,
        t = CampusTokens.of(context),
        l = strings(context);
    final overdue =
        !task.completed &&
        task.dueDate != null &&
        task.dueDate!.isBefore(DateUtils.dateOnly(widget.now));
    return Padding(
      key: ValueKey('task:${task.id}'),
      padding: EdgeInsets.symmetric(horizontal: t.space8, vertical: t.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: task.completed,
            semanticLabel: '${l.tasksComplete}: ${task.title}',
            onChanged: busy
                ? null
                : (value) => change(
                    () => ref
                        .read(personalTasksProvider.notifier)
                        .setCompleted(task.id, value!),
                  ),
          ),
          Expanded(
            child: InkWell(
              onTap: busy ? null : () => editPersonalTask(context, task: task),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: t.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    SizedBox(height: t.space4),
                    Text(
                      task.dueDate == null
                          ? l.tasksNoDate
                          : '${overdue ? '${l.tasksOverdue} · ' : ''}${MaterialLocalizations.of(context).formatCompactDate(task.dueDate!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            enabled: !busy,
            tooltip: '${l.tasksActions}: ${task.title}',
            icon: const Icon(Icons.more_horiz_rounded),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(l.tasksEdit)),
              PopupMenuItem(value: 'delete', child: Text(l.tasksDelete)),
            ],
            onSelected: (value) async {
              if (value == 'edit') {
                await editPersonalTask(context, task: task);
              } else {
                final remove = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text(l.tasksDeleteConfirm),
                    content: Text(task.title),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: Text(tr(c, 'Отмена')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: Text(l.tasksDelete),
                      ),
                    ],
                  ),
                );
                if (remove == true && mounted) {
                  await change(
                    () => ref
                        .read(personalTasksProvider.notifier)
                        .delete(task.id),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TaskEditor extends ConsumerStatefulWidget {
  const _TaskEditor({this.task, this.day});
  final PersonalTask? task;
  final DateTime? day;
  @override
  ConsumerState<_TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends ConsumerState<_TaskEditor> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.task?.title);
  late final notes = TextEditingController(text: widget.task?.notes);
  late DateTime? date = widget.task?.dueDate ?? widget.day;
  bool busy = false;
  String? error;
  @override
  void dispose() {
    title.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref
          .read(personalTasksProvider.notifier)
          .saveTask(
            id: widget.task?.id,
            title: title.text,
            notes: notes.text,
            dueDate: date,
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => error = strings(context).tasksSaveError);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context), l = strings(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(t.space24),
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.task == null ? l.tasksNew : l.tasksEdit,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: l.mapClose,
                      onPressed: busy ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                SizedBox(height: t.space24),
                TextFormField(
                  key: const ValueKey('task-title-input'),
                  controller: title,
                  maxLength: 120,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l.tasksName,
                    errorMaxLines: 2,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l.tasksNameRequired
                      : null,
                ),
                SizedBox(height: t.space16),
                TextFormField(
                  key: const ValueKey('task-notes-input'),
                  controller: notes,
                  maxLength: 1000,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: l.tasksNotes),
                ),
                SizedBox(height: t.space16),
                OutlinedButton.icon(
                  key: const ValueKey('task-date-button'),
                  onPressed: busy
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date ?? widget.day ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2200),
                          );
                          if (picked != null && mounted) {
                            setState(() => date = picked);
                          }
                        },
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(
                    date == null
                        ? l.tasksPickDate
                        : MaterialLocalizations.of(context)
                              .formatCompactDate(date!),
                  ),
                ),
                if (date != null)
                  TextButton(
                    onPressed: busy ? null : () => setState(() => date = null),
                    child: Text(l.tasksClearDate),
                  ),
                SizedBox(height: t.space24),
                if (error != null) ...[
                  Text(
                    error!,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: t.text),
                  ),
                  SizedBox(height: t.space16),
                ],
                FilledButton(
                  key: const ValueKey('task-save-button'),
                  onPressed: busy ? null : save,
                  child: Text(busy ? l.tasksSaving : tr(context, 'Сохранить')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
