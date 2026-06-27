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

    func schedule(for task: PareTask) {
        guard let time = task.scheduledTime else { return }
        let content = UNMutableNotificationContent()
        content.title = "Pare"
        content.body  = task.title
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: time)
        let trigger    = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let id         = UUID().uuidString
        let request    = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
        task.notificationIDs.append(id)
    }

    func cancel(for task: PareTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: task.notificationIDs)
        task.notificationIDs.removeAll()
    }

    func refreshPendingCount() async {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        await MainActor.run { self.pendingCount = pending.count }
    }
}
