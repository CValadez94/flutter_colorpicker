part of 'main_bloc.dart';

enum ColorTheme { none, a, b }

final class MainState extends Equatable {
  final ColorTheme theme;
  final Color color;
  final List<Color> history;

  const MainState({
    this.theme = ColorTheme.none,
    this.color = Colors.white,
    this.history = const [],
  });

  MainState copyWith({
    ColorTheme? theme,
    Color? color,
    List<Color>? history,
  }) {
    return MainState(
      theme: theme ?? this.theme,
      color: color ?? this.color,
      history: history ?? this.history,
    );
  }

  @override
  List<Object> get props => [theme, color, history];
}
