import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker_tailored_example/main.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(const MainState()) {
    on<ColorThemeChanged>((event, emit) {
      emit(state.copyWith(theme: event.theme));
    });
    on<ColorChanged>((event, emit) {
      emit(state.copyWith(color: event.color));
    });
    on<HistoryColorAdded>((event, emit) {
      // Ignore if color already in history

      if (state.history.contains(event.color)) return;

      List<Color> newHistory = [...state.history];
      newHistory.insert(0, event.color);
      // Trim
      if (newHistory.length >= 5) {
        newHistory.removeRange(5, newHistory.length);
      }

      emit(state.copyWith(history: newHistory));
    });
  }
}
