import 'package:flutter/foundation.dart';

/// Qué hace un toque. La pulsación larga hace lo contrario.
enum TapAction { reveal, flag }

/// Duración de la pulsación larga.
enum LongPressSpeed {
  short(Duration(milliseconds: 300)),
  normal(Duration(milliseconds: 450)),
  long(Duration(milliseconds: 650));

  const LongPressSpeed(this.duration);

  final Duration duration;
}

/// Preferencias del Buscaminas. [showTimer] y [haptics] vienen de los
/// ajustes generales de la app (H4-09).
@immutable
final class MinesweeperSettings {
  const MinesweeperSettings({
    this.tapAction = TapAction.reveal,
    this.longPress = LongPressSpeed.normal,
    this.chord = true,
    this.longPressTipDone = false,
    this.showTimer = true,
    this.haptics = true,
  });

  final TapAction tapAction;
  final LongPressSpeed longPress;

  /// Tocar un número con todas sus banderas revela sus vecinas.
  final bool chord;

  /// El jugador ya usó la pulsación larga: no hace falta la ayuda.
  final bool longPressTipDone;
  final bool showTimer;
  final bool haptics;

  MinesweeperSettings copyWith({
    TapAction? tapAction,
    LongPressSpeed? longPress,
    bool? chord,
    bool? longPressTipDone,
    bool? showTimer,
    bool? haptics,
  }) => MinesweeperSettings(
    tapAction: tapAction ?? this.tapAction,
    longPress: longPress ?? this.longPress,
    chord: chord ?? this.chord,
    longPressTipDone: longPressTipDone ?? this.longPressTipDone,
    showTimer: showTimer ?? this.showTimer,
    haptics: haptics ?? this.haptics,
  );

  Map<String, Object?> toJson() => {
    'tapAction': tapAction.name,
    'longPress': longPress.name,
    'chord': chord,
    'longPressTipDone': longPressTipDone,
  };

  /// Valores desconocidos (de una versión futura) vuelven al predeterminado.
  factory MinesweeperSettings.fromJson(Map<String, Object?> json) {
    T byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    return MinesweeperSettings(
      tapAction: byName(TapAction.values, json['tapAction'], TapAction.reveal),
      longPress: byName(LongPressSpeed.values, json['longPress'], LongPressSpeed.normal),
      chord: json['chord'] as bool? ?? true,
      longPressTipDone: json['longPressTipDone'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MinesweeperSettings &&
      other.tapAction == tapAction &&
      other.longPress == longPress &&
      other.chord == chord &&
      other.longPressTipDone == longPressTipDone &&
      other.showTimer == showTimer &&
      other.haptics == haptics;

  @override
  int get hashCode => Object.hash(tapAction, longPress, chord, longPressTipDone, showTimer, haptics);
}

/// Dónde se guardan los ajustes del Buscaminas.
abstract interface class MinesweeperSettingsStore {
  MinesweeperSettings load();

  Future<void> save(MinesweeperSettings settings);
}

final class InMemoryMinesweeperSettingsStore implements MinesweeperSettingsStore {
  InMemoryMinesweeperSettingsStore([this._settings = const MinesweeperSettings()]);

  MinesweeperSettings _settings;

  @override
  MinesweeperSettings load() => _settings;

  @override
  Future<void> save(MinesweeperSettings settings) async => _settings = settings;
}
