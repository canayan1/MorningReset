import AlarmKit

// Shared by the app, which schedules the alarm, and the widget, which draws it.
// AlarmKit needs the same metadata type on both sides of that line.

@available(iOS 26.1, *)
struct MorningAlarmMeta: AlarmMetadata {}
