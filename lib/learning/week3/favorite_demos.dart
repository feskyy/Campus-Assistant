import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:campus_assistant/shared/widgets/ui/campus_card.dart';
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteDemoState extends ChangeNotifier {
  bool selected = false;
  void toggle() {
    selected = !selected;
    notifyListeners();
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.selected,
    required this.toggle,
  });
  final bool selected;
  final VoidCallback toggle;
  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: toggle,
    icon: Icon(selected ? Icons.bookmark : Icons.bookmark_border),
    label: Text(
      selected
          ? tr(context, 'В избранном')
          : tr(context, 'Добавить в избранное'),
    ),
  );
}

class SetStateFavoriteDemo extends StatefulWidget {
  const SetStateFavoriteDemo({super.key});
  @override
  State<SetStateFavoriteDemo> createState() => _SetStateFavoriteDemoState();
}

class _SetStateFavoriteDemoState extends State<SetStateFavoriteDemo> {
  bool selected = false;
  @override
  Widget build(BuildContext context) => FavoriteButton(
    selected: selected,
    toggle: () => setState(() => selected = !selected),
  );
}

class FavoriteScope extends InheritedWidget {
  const FavoriteScope({
    super.key,
    required this.selected,
    required this.toggle,
    required super.child,
  });
  final bool selected;
  final VoidCallback toggle;
  static FavoriteScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FavoriteScope>()!;
  @override
  bool updateShouldNotify(FavoriteScope oldWidget) =>
      selected != oldWidget.selected;
}

class InheritedFavoriteDemo extends StatefulWidget {
  const InheritedFavoriteDemo({super.key});
  @override
  State<InheritedFavoriteDemo> createState() => _InheritedFavoriteDemoState();
}

class _InheritedFavoriteDemoState extends State<InheritedFavoriteDemo> {
  bool selected = false;
  @override
  Widget build(BuildContext context) => FavoriteScope(
    selected: selected,
    toggle: () => setState(() => selected = !selected),
    child: Builder(
      builder: (context) {
        final scope = FavoriteScope.of(context);
        return FavoriteButton(selected: scope.selected, toggle: scope.toggle);
      },
    ),
  );
}

class ProviderFavoriteDemo extends StatelessWidget {
  const ProviderFavoriteDemo({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => FavoriteDemoState(),
    child: Consumer<FavoriteDemoState>(
      builder: (_, state, _) =>
          FavoriteButton(selected: state.selected, toggle: state.toggle),
    ),
  );
}

class Week3Screen extends StatelessWidget {
  const Week3Screen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, 'Неделя 3: состояние'))),
    body: PageBody(
      child: ListView(
        padding: EdgeInsets.all(CampusTokens.of(context).space16),
        children: const [
          CampusCard(
            child: ListTile(
              title: Text('setState'),
              subtitle: SetStateFavoriteDemo(),
            ),
          ),
          CampusCard(
            child: ListTile(
              title: Text('InheritedWidget'),
              subtitle: InheritedFavoriteDemo(),
            ),
          ),
          CampusCard(
            child: ListTile(
              title: Text('ChangeNotifier + Provider'),
              subtitle: ProviderFavoriteDemo(),
            ),
          ),
        ],
      ),
    ),
  );
}
