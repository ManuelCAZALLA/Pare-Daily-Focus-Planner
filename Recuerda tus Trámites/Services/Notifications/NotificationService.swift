// NotificationService.swift
import Foundation
import UserNotifications

@Observable
final class NotificationService {
    var isAuthorized: Bool = false
    var pendingCount: Int = 0
    private let maximumManagedNotifications = 60

    func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        await MainActor.run { self.isAuthorized = granted ?? false }
    }

    func schedule(for task: TramiteTask) {
        guard let time = task.scheduledTime,
              let alertOffset = task.alertOffset else { return }

        let notificationDate = time.addingTimeInterval(-alertOffset.rawValue)
        guard notificationDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Recuerda tus Trámites"
        content.body  = task.title
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.hour, .minute, .day, .month, .year],
            from: notificationDate
        )
        let trigger    = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let id         = UUID().uuidString
        let request    = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
        task.notificationIDs.append(id)
    }

    func cancel(for task: TramiteTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: task.notificationIDs)
        task.notificationIDs.removeAll()
    }

    /// Devuelve únicamente IDs que iOS ha aceptado. iOS admite hasta 64 avisos
    /// locales pendientes; dejamos margen para avisos de tareas y rutinas.
    func schedule(for obligation: LifeObligation, title: String) async -> [String] {
        guard let expiryDate = obligation.expiryDate else { return [] }
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let slots = max(0, maximumManagedNotifications - pending.count)
        guard slots > 0 else { return [] }

        let calendar = Calendar.current
        let dates: [Date]
        if obligation.escalatedAlertsEnabled {
            // Debe coincidir con lo que se promete en la interfaz.
            dates = [
                calendar.date(byAdding: .month, value: -1, to: expiryDate),
                calendar.date(byAdding: .day, value: -14, to: expiryDate),
                calendar.date(byAdding: .day, value: -7, to: expiryDate),
                calendar.date(byAdding: .day, value: -2, to: expiryDate)
            ].compactMap { $0 }
        } else if let alertOffset = obligation.alertOffset {
            dates = [expiryDate.addingTimeInterval(-alertOffset.timeIntervalBefore)]
        } else {
            dates = []
        }

        var ids: [String] = []
        for date in dates.sorted() where ids.count < slots {
            if let id = await scheduleObligationNotification(
                title: title,
                expiryDate: expiryDate,
                notificationDate: date
            ) {
                ids.append(id)
            }
        }
        return ids
    }

    private func scheduleObligationNotification(
        title: String,
        expiryDate: Date,
        notificationDate: Date
    ) async -> String? {
        let notificationDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: notificationDate) ?? notificationDate
        guard notificationDate > Date() else { return nil }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Trámites")
        content.body = String(format: String(localized: "%@ vence el %@."), title, expiryDate.formatted(date: .abbreviated, time: .omitted))
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.hour, .minute, .day, .month, .year],
            from: notificationDate
        )
        let id = UUID().uuidString
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            return id
        } catch {
            return nil
        }
    }

    func cancel(for obligation: LifeObligation) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: obligation.notificationIDs)
        obligation.notificationIDs.removeAll()
    }

    func refreshPendingCount() async {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        await MainActor.run { self.pendingCount = pending.count }
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            self.isAuthorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        }
    }
}
