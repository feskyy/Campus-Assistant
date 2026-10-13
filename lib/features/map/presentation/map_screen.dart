import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapState();
}

class _MapState extends State<MapScreen> {
  String query = '';
  static const rooms = [
    (building: 'Главный корпус', floor: '2', room: '214'),
    (building: 'Главный корпус', floor: '1', room: '112'),
    (building: 'Главный корпус', floor: '2', room: '210'),
    (building: 'Главный корпус', floor: '1', room: '118'),
    (building: 'Корпус Б', floor: '3', room: '305'),
    (building: 'Корпус Б', floor: '3', room: '301'),
  ];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = rooms
        .where(
          (e) => '${e.building} ${e.room} ${e.floor}'.toLowerCase().contains(
            query,
          ),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Каталог кампуса')),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const PageIntro(
              eyebrow: 'КОРПУСА И АУДИТОРИИ',
              title: 'Найдите свою аудиторию',
              subtitle: 'Поиск по названию корпуса, этажу или номеру.',
            ),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Корпус, этаж или аудитория',
              ),
              onChanged: (value) =>
                  setState(() => query = value.trim().toLowerCase()),
            ),
            const SizedBox(height: 16),
            Text(
              'Демонстрационный каталог · Google Maps появится на следующем этапе.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            if (filtered.isEmpty)
              const EmptyState(
                icon: Icons.location_off_outlined,
                message: 'Аудиторий не найдено',
              ),
            for (final building in filtered.map((e) => e.building).toSet()) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(building, style: theme.textTheme.titleLarge),
              ),
              Card(
                child: Column(
                  children: [
                    for (final room in filtered.where(
                      (e) => e.building == building,
                    ))
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            room.room,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text('Аудитория ${room.room}'),
                        subtitle: Text(
                          'Этаж ${room.floor} · Аудитория ${room.room}',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => Scaffold(
                              appBar: AppBar(title: Text(room.building)),
                              body: PageBody(
                                child: ListView(
                                  padding: const EdgeInsets.all(24),
                                  children: [
                                    PageIntro(
                                      eyebrow: room.building,
                                      title: 'Аудитория ${room.room}',
                                      subtitle: 'Этаж ${room.floor}',
                                    ),
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Text(
                                          'Демонстрационные данные\nКорпус: ${room.building}\nЭтаж: ${room.floor}\nАудитория: ${room.room}\nАдрес университета не указан.',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
