part of 'main_bloc.dart';

sealed class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object?> get props => [];
}

final class ColorThemeChanged extends MainEvent {
  final ColorTheme theme;

  const ColorThemeChanged(this.theme);

  @override
  List<Object> get props => [theme];
}

final class ColorChanged extends MainEvent {
  final Color color;

  const ColorChanged(this.color);

  @override
  List<Object> get props => [color];
}

final class HistoryColorAdded extends MainEvent {
  final Color color;

  const HistoryColorAdded(this.color);

  @override
  List<Object> get props => [color];
}
