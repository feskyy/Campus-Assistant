import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/domain/campus_data.dart';
import 'package:campus_assistant/core/di/map_providers.dart';
import 'package:campus_assistant/core/presentation/not_found_screen.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/core/utils/date_format.dart';
import 'package:campus_assistant/features/map/domain/entities/building.dart';
import 'package:campus_assistant/features/map/domain/entities/room.dart';
import 'package:campus_assistant/features/map/domain/room_schedule.dart';
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/shared/widgets/data_view.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;
import 'package:campus_assistant/shared/widgets/ui/entity_actions.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.room, this.building});
  final String? room, building;
  @override
  ConsumerState<MapScreen> createState() => _MapState();
}

class _MapState extends ConsumerState<MapScreen> {
  String? buildingFilter;
  bool freeOnly = false;
  final search = TextEditingController();
  @override
  void initState() {
    super.initState();
    applyTarget();
  }

  void applyTarget() {
    buildingFilter = widget.building?.isNotEmpty == true
        ? widget.building
        : null;
    search.text = widget.room ?? '';
    freeOnly = false;
  }

  @override
  void didUpdateWidget(covariant MapScreen old) {
    super.didUpdateWidget(old);
    if (old.building != widget.building || old.room != widget.room) {
      applyTarget();
    }
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void browseBuilding(String id) {
    setState(() {
      buildingFilter = id;
      search.clear();
      freeOnly = false;
    });
  }

  void showBuilding(CampusData data, String id) {
    FocusScope.of(context).unfocus();
    showDialog<void>(
      context: context,
      builder: (c) => _InfoDialog(
        title: data.buildings.firstWhere((b) => b.id == id).name,
        child: _BuildingInfo(
          data: data,
          id: id,
          onClose: () => Navigator.pop(c),
          onRooms: () {
            Navigator.pop(c);
            browseBuilding(id);
          },
        ),
      ),
    );
  }

  void showRoom(CampusData data, Building building, Room room) {
    FocusScope.of(context).unfocus();
    showDialog<void>(
      context: context,
      builder: (c) => _InfoDialog(
        title: strings(c).detailRoom(room.number),
        child: _RoomInfo(
          data: data,
          buildingId: building.id,
          number: room.number,
        ),
      ),
    );
  }

  void expand(CampusData data) {
    FocusScope.of(context).unfocus();
    showDialog<void>(
      context: context,
      builder: (c) => Dialog.fullscreen(
        child: _ExpandedMap(
          data: data,
          onRooms: (id) {
            Navigator.pop(c);
            browseBuilding(id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context), l = strings(context);
    final now = ref.watch(clockProvider).asData?.value ?? DateTime.now();
    return Scaffold(
      appBar: AppBar(title: Text(l.navMap)),
      body: PageBody(
        maxWidth: t.wideBreakpoint + t.space24,
        child: DataView(
          builder: (data) {
            if (data.buildings.isEmpty) {
              return ui.EmptyState(
                title: l.mapNoBuildings,
                message: l.detailMissing,
              );
            }
            final target = data.buildings
                .where((b) => b.id == widget.building)
                .firstOrNull;
            if (widget.building?.isNotEmpty == true &&
                (target == null ||
                    (widget.room?.isNotEmpty == true &&
                        !target.rooms.any((r) => r.number == widget.room)))) {
              return const NotFoundContent();
            }
            final query = search.text.toLowerCase().trim();
            final entries =
                <({Building building, Room room, RoomSchedule schedule})>[];
            for (final b in data.buildings.where(
              (b) => buildingFilter == null || b.id == buildingFilter,
            )) {
              for (final room in b.rooms) {
                final schedule = RoomSchedule(
                  building: b,
                  room: room,
                  lessons: data.lessons,
                  now: now,
                );
                final haystack =
                    '${b.name} ${b.address ?? ''} ${room.number} ${room.floor ?? ''} ${room.hint ?? ''} ${room.equipment.join(' ')}'
                        .toLowerCase();
                if ((query.isEmpty || haystack.contains(query)) &&
                    (!freeOnly || schedule.isFree)) {
                  entries.add((building: b, room: room, schedule: schedule));
                }
              }
            }
            return RefreshIndicator(
              onRefresh: () => ref.read(campusDataProvider.notifier).refresh(),
              child: ListView(
                key: const ValueKey('map-room-list'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(t.space24),
                children: [
                  ui.CampusCard(
                    padding: EdgeInsets.all(t.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(l.mapCampus, style: t.sectionStyle),
                            ),
                            IconButton(
                              key: const ValueKey('map-expand-button'),
                              tooltip: l.mapExpand,
                              onPressed: () => expand(data),
                              icon: const Icon(Icons.open_in_full_rounded),
                            ),
                          ],
                        ),
                        SizedBox(height: t.space8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(t.fieldRadius),
                          child: SizedBox(
                            key: const ValueKey('map-preview'),
                            height: t.tapExtent * 3 + t.space16,
                            child: ref.watch(campusMapPreviewProvider)(
                              data.buildings,
                              buildingFilter,
                              (id) => showBuilding(data, id),
                            ),
                          ),
                        ),
                        SizedBox(height: t.space16),
                        Text(
                          l.mapBannerHint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: t.space24),
                  Text(
                    l.detailRooms,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: t.space8),
                  Text(
                    '${l.mapCheckedAt} ${formatTime(now)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: t.space16),
                  TextField(
                    controller: search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: tr(context, 'Корпус, этаж или аудитория'),
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l.mapClearSearch,
                              onPressed: () => setState(search.clear),
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  SizedBox(height: t.space16),
                  Wrap(
                    spacing: t.space8,
                    runSpacing: t.space8,
                    children: [
                      ChoiceChip(
                        label: Text(l.mapAllBuildings),
                        selected: buildingFilter == null,
                        labelStyle: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: buildingFilter == null
                                  ? t.onAccent
                                  : t.readableSecondary,
                            ),
                        onSelected: (_) =>
                            setState(() => buildingFilter = null),
                      ),
                      for (final b in data.buildings)
                        ChoiceChip(
                          label: Text(b.name),
                          selected: buildingFilter == b.id,
                          labelStyle: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: buildingFilter == b.id
                                    ? t.onAccent
                                    : t.readableSecondary,
                              ),
                          onSelected: (_) =>
                              setState(() => buildingFilter = b.id),
                        ),
                      FilterChip(
                        key: const ValueKey('map-free-filter'),
                        label: Text(l.mapFreeOnly),
                        selected: freeOnly,
                        labelStyle: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: freeOnly
                                  ? t.onAccent
                                  : t.readableSecondary,
                            ),
                        avatar: Icon(
                          Icons.check_circle_outline_rounded,
                          color: freeOnly ? t.onAccent : t.readableSupportive,
                        ),
                        onSelected: (value) => setState(() => freeOnly = value),
                      ),
                    ],
                  ),
                  SizedBox(height: t.space16),
                  Text(
                    l.mapAvailabilityNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: t.space24),
                  if (entries.isEmpty)
                    ui.EmptyState(
                      title: tr(context, 'Аудиторий не найдено'),
                      message: l.mapEmptyHint,
                      action: TextButton(
                        onPressed: () => setState(() {
                          search.clear();
                          buildingFilter = null;
                          freeOnly = false;
                        }),
                        child: Text(l.mapResetFilters),
                      ),
                    ),
                  for (final entry in entries)
                    Padding(
                      padding: EdgeInsets.only(bottom: t.space16),
                      child: _RoomTile(
                        building: entry.building,
                        room: entry.room,
                        schedule: entry.schedule,
                        onTap: () => showRoom(data, entry.building, entry.room),
                      ),
                    ),
                  SourceNotice(data: data),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.building,
    required this.room,
    required this.schedule,
    required this.onTap,
  });
  final Building building;
  final Room room;
  final RoomSchedule schedule;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context), l = strings(context);
    return ui.CampusCard(
      key: ValueKey('room:${building.id}:${room.number}'),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: t.tapExtent,
                height: t.tapExtent,
                decoration: BoxDecoration(
                  color: t.surface2,
                  borderRadius: BorderRadius.circular(t.fieldRadius),
                ),
                child: Icon(Icons.meeting_room_rounded, color: t.accent),
              ),
              SizedBox(width: t.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.roomLabel(room.number), style: t.sectionStyle),
                    SizedBox(height: t.space4),
                    Text(
                      building.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(width: t.space8),
              Icon(Icons.chevron_right_rounded, color: t.secondary),
            ],
          ),
          SizedBox(height: t.space16),
          Text(
            room.floor == null
                ? l.detailMissing
                : l.detailRoomSummary('${room.floor}', room.number),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (room.capacity != null) ...[
            SizedBox(height: t.space4),
            Text(
              '${l.detailCapacity}: ${room.capacity}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          SizedBox(height: t.space16),
          _Availability(schedule: schedule),
          if (!schedule.isFree) ...[
            SizedBox(height: t.space8),
            Text(
              schedule.current.map((lesson) => lesson.subject).join(' · '),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
          if (schedule.next != null) ...[
            SizedBox(height: t.space8),
            Text(
              '${l.mapNextClass}: ${schedule.next!.startTime} · ${schedule.next!.subject}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _Availability extends StatelessWidget {
  const _Availability({required this.schedule});
  final RoomSchedule schedule;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context), l = strings(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          schedule.isFree
              ? Icons.check_circle_outline_rounded
              : Icons.schedule_rounded,
          color: schedule.isFree ? t.readableSupportive : t.accent,
        ),
        SizedBox(width: t.space8),
        Expanded(
          child: Text(
            schedule.isFree ? l.mapFree : l.mapOccupied,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

class _InfoDialog extends StatelessWidget {
  const _InfoDialog({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context);
    return Dialog(
      insetPadding: EdgeInsets.all(t.space16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: t.statRowBreakpoint,
          maxHeight: MediaQuery.sizeOf(context).height * .85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                t.space24,
                t.space16,
                t.space16,
                t.space8,
              ),
              child: _InfoHeader(
                title: title,
                onClose: () => Navigator.pop(context),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  t.space24,
                  t.space8,
                  t.space24,
                  t.space24,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoHeader extends StatelessWidget {
  const _InfoHeader({required this.title, required this.onClose});
  final String title;
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ),
      SizedBox(width: CampusTokens.of(context).space8),
      IconButton(
        tooltip: strings(context).mapClose,
        onPressed: onClose,
        icon: const Icon(Icons.close_rounded),
      ),
    ],
  );
}

class _RoomInfo extends ConsumerWidget {
  const _RoomInfo({
    required this.data,
    required this.buildingId,
    required this.number,
  });
  final CampusData data;
  final String buildingId, number;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(campusDataProvider).asData?.value ?? data;
    final now = ref.watch(clockProvider).asData?.value ?? DateTime.now();
    final building = live.buildings
        .where((b) => b.id == buildingId)
        .firstOrNull;
    final room = building?.rooms.where((r) => r.number == number).firstOrNull;
    if (building == null || room == null) return const NotFoundContent();
    final schedule = RoomSchedule(
      building: building,
      room: room,
      lessons: live.lessons,
      now: now,
    );
    final t = CampusTokens.of(context), l = strings(context);
    void openLesson(String id) {
      final router = GoRouter.of(context);
      Navigator.pop(context);
      router.pushNamed(Routes.lesson, pathParameters: {'id': id});
    }

    return Column(
      key: const ValueKey('map-room-info'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(building.name, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: t.space16),
        Wrap(
          spacing: t.space24,
          runSpacing: t.space8,
          children: [
            Text('${l.detailFloor}: ${room.floor ?? l.detailMissing}'),
            Text('${l.detailCapacity}: ${room.capacity ?? l.detailMissing}'),
          ],
        ),
        if (room.hint != null) ...[
          SizedBox(height: t.space16),
          Text(room.hint!),
        ],
        if (room.equipment.isNotEmpty) ...[
          SizedBox(height: t.space24),
          Text(l.mapEquipment, style: t.sectionStyle),
          SizedBox(height: t.space8),
          Text(room.equipment.join(' · ')),
        ],
        SizedBox(height: t.space24),
        _Availability(schedule: schedule),
        SizedBox(height: t.space8),
        Text(
          '${l.mapCheckedAt} ${formatTime(now)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: t.space16),
        for (final lesson in schedule.current)
          Padding(
            padding: EdgeInsets.only(bottom: t.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.subject, style: t.sectionStyle),
                SizedBox(height: t.space8),
                Text(
                  '${lesson.startTime}–${lesson.endTime} · ${l.groupLabel(lesson.group)}',
                ),
                SizedBox(height: t.space4),
                Text(lesson.teacher),
                TextButton.icon(
                  onPressed: () => openLesson(lesson.id),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(l.mapLessonDetails),
                ),
              ],
            ),
          ),
        Text(l.mapTodaySchedule, style: t.sectionStyle),
        SizedBox(height: t.space16),
        if (schedule.today.isEmpty)
          Text(l.detailNoLessons, style: Theme.of(context).textTheme.bodySmall),
        for (final lesson in schedule.today)
          Padding(
            padding: EdgeInsets.only(bottom: t.space8),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: t.space8),
              title: Text(lesson.subject),
              subtitle: Text(
                '${lesson.startTime}–${lesson.endTime}\n${lesson.teacher} · ${l.groupLabel(lesson.group)}',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => openLesson(lesson.id),
            ),
          ),
        SizedBox(height: t.space16),
        Text(
          l.mapAvailabilityNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: t.space16),
        ui.PillButton(
          label: l.routeRoom,
          icon: Icons.near_me_rounded,
          onPressed: () => openEntityLink(
            context,
            ref,
            addressDirections(building.address ?? building.name),
            building.address ?? building.name,
          ),
        ),
      ],
    );
  }
}

class _BuildingInfo extends ConsumerWidget {
  const _BuildingInfo({
    required this.data,
    required this.id,
    required this.onClose,
    required this.onRooms,
    this.compact = false,
  });
  final CampusData data;
  final String id;
  final VoidCallback onClose, onRooms;
  final bool compact;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(campusDataProvider).asData?.value ?? data;
    final now = ref.watch(clockProvider).asData?.value ?? DateTime.now();
    final b = live.buildings.where((b) => b.id == id).firstOrNull;
    if (b == null) return const NotFoundContent();
    final t = CampusTokens.of(context), l = strings(context);
    final free = b.rooms
        .where(
          (r) => RoomSchedule(
            building: b,
            room: r,
            lessons: live.lessons,
            now: now,
          ).isFree,
        )
        .length;
    return Column(
      key: ValueKey('building-info:$id'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compact) ...[
          _InfoHeader(title: b.name, onClose: onClose),
          SizedBox(height: t.space16),
        ],
        if (!compact) ...[
          ui.CampusImage(source: b.photoUrl, kind: ui.CampusImageKind.building),
          SizedBox(height: t.space24),
        ],
        if (b.address != null) ...[
          Text(b.address!),
          SizedBox(height: t.space16),
        ],
        Wrap(
          spacing: t.space16,
          runSpacing: t.space8,
          children: [
            Text('${l.detailFloors}: ${b.floors ?? l.detailMissing}'),
            Text('${l.detailCount}: ${b.rooms.length}'),
          ],
        ),
        SizedBox(height: t.space16),
        Text(
          '${l.mapFreeCount}: $free / ${b.rooms.length}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        if (!compact && b.description != null) ...[
          SizedBox(height: t.space16),
          Text(b.description!),
        ],
        SizedBox(height: t.space16),
        ui.PillButton(
          label: l.detailRooms,
          icon: Icons.meeting_room_rounded,
          onPressed: onRooms,
        ),
        SizedBox(height: t.space8),
        ui.PillButton(
          label: l.routeRoom,
          variant: ui.PillButtonVariant.outlined,
          icon: Icons.near_me_rounded,
          onPressed: () => openEntityLink(
            context,
            ref,
            addressDirections(b.address ?? b.name),
            b.address ?? b.name,
          ),
        ),
        SizedBox(height: t.space16),
        Text(
          l.mapAvailabilityNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ExpandedMap extends ConsumerStatefulWidget {
  const _ExpandedMap({required this.data, required this.onRooms});
  final CampusData data;
  final ValueChanged<String> onRooms;
  @override
  ConsumerState<_ExpandedMap> createState() => _ExpandedMapState();
}

class _ExpandedMapState extends ConsumerState<_ExpandedMap> {
  String? selectedId;
  @override
  Widget build(BuildContext context) {
    final t = CampusTokens.of(context), l = strings(context);
    final data = ref.watch(campusDataProvider).asData?.value ?? widget.data;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.mapCampus),
        leading: IconButton(
          key: const ValueKey('map-expanded-close'),
          tooltip: l.mapClose,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(t.space16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(t.cardRadius),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Positioned.fill(
                    child: ref.watch(campusMapViewProvider)(
                      data.buildings,
                      selectedId,
                      (id) => setState(() => selectedId = id),
                    ),
                  ),
                  if (selectedId != null)
                    Align(
                      alignment: constraints.maxWidth >= t.wideBreakpoint
                          ? Alignment.bottomRight
                          : Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.all(t.space16),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth >= t.wideBreakpoint
                                ? t.listingWidth
                                : t.statRowBreakpoint,
                            maxHeight: constraints.maxHeight * .55,
                          ),
                          child: ui.CampusCard(
                            key: const ValueKey('map-building-floating'),
                            child: SingleChildScrollView(
                              child: _BuildingInfo(
                                data: data,
                                id: selectedId!,
                                compact: true,
                                onClose: () =>
                                    setState(() => selectedId = null),
                                onRooms: () => widget.onRooms(selectedId!),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
