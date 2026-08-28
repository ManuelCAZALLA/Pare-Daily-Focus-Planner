// NotificationService.swift
import Foundation
import UserNotifications

@Observable
final class NotificationService {
    var isAuthorized: Bool = false
    var pendingCount: Int = 0

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

    func schedule(for obligation: LifeObligation, title: String) {
        guard let expiryDate = obligation.expiryDate else { return }

        if obligation.escalatedAlertsEnabled {
            [90, 30, 14, 7].forEach { daysBeforeExpiry in
                scheduleObligationNotification(
                    for: obligation,
                    title: title,
                    expiryDate: expiryDate,
                    daysBeforeExpiry: daysBeforeExpiry
                )
            }
        } else if let alertOffset = obligation.alertOffset {
            scheduleObligationNotification(
                for: obligation,
                title: title,
                expiryDate: expiryDate,
                timeIntervalBefore: alertOffset.timeIntervalBefore
            )
        }
    }

    private func scheduleObligationNotification(
        for obligation: LifeObligation,
        title: String,
        expiryDate: Date,
        daysBeforeExpiry: Int
    ) {
        scheduleObligationNotification(
            for: obligation,
            title: title,
            expiryDate: expiryDate,
            timeIntervalBefore: TimeInterval(daysBeforeExpiry * 24 * 60 * 60)
        )
    }

    private func scheduleObligationNotification(
        for obligation: LifeObligation,
        title: String,
        expiryDate: Date,
        timeIntervalBefore: TimeInterval
    ) {
        let notificationDate = Calendar.current.startOfDay(for: expiryDate)
            .addingTimeInterval(-timeIntervalBefore + 9 * 60 * 60)
        guard notificationDate > Date() else { return }

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

        UNUserNotificationCenter.current().add(request)
        obligation.notificationIDs.append(id)
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
