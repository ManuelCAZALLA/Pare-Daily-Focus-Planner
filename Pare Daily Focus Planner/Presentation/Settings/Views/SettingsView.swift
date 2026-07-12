import SwiftUI

struct SettingsView: View {
    @Environment(NotificationService.self) private var notificationService

    var body: some View {
        ZStack {
            Color(hex: "#0C0C0E").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    notificationsSection
                    planningSection
                    privacySection
                    aboutSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 36)
            }
        }
        .task { await notificationService.refreshAuthorizationStatus() }
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.pareGreen.opacity(0.15))
                    .frame(width: 54, height: 54)
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundStyle(Color.pareGreen)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Ajustes")
                    .font(.largeTitle.weight(.heavy))
                    .fontDesign(.rounded)
                Text("Personaliza cómo te acompaña Pare")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var notificationsSection: some View {
        SettingsSection(title: "Notificaciones") {
            Button {
                Task {
                    if notificationService.isAuthorized {
                        await notificationService.refreshAuthorizationStatus()
                    } else {
                        await notificationService.requestPermission()
                    }
                }
            } label: {
                SettingsRow(
                    icon: notificationService.isAuthorized ? "bell.badge.fill" : "bell.slash.fill",
                    title: "Avisos de tareas y trámites",
                    detail: notificationService.isAuthorized ? "Activados" : "Toca para activarlos",
                    tint: notificationService.isAuthorized ? Color.pareGreen : Color.orange,
                    showsChevron: !notificationService.isAuthorized
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var planningSection: some View {
        SettingsSection(title: "Planificación") {
            SettingsRow(
                icon: "calendar",
                title: "Semana laboral",
                detail: "De lunes a domingo",
                tint: Color.pareGreen,
                showsChevron: false
            )

            Divider().overlay(Color.white.opacity(0.08))

            SettingsRow(
                icon: "checkmark.circle",
                title: "Tareas completadas",
                detail: "Se ocultan al terminar",
                tint: Color.pareGreen,
                showsChevron: false
            )
        }
    }

    private var privacySection: some View {
        SettingsSection(title: "Privacidad") {
            SettingsRow(
                icon: "lock.fill",
                title: "Tus datos",
                detail: "Se guardan solo en este dispositivo",
                tint: Color.pareGreen,
                showsChevron: false
            )
        }
    }

    private var aboutSection: some View {
        SettingsSection(title: "Acerca de") {
            SettingsRow(
                icon: "info.circle.fill",
                title: "Pare Daily Focus Planner",
                detail: "Versión \(appVersion)",
                tint: Color.pareGreen,
                showsChevron: false
            )
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}

private struct SettingsSection<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(1)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, 14)
            .background(Color(hex: "#1A1A1C"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 1)
            )
        }
    }
}

private struct SettingsRow: View {
    let icon: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    let tint: Color
    let showsChevron: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(hex: "#636366"))
            }
        }
        .padding(.vertical, 14)
    }
}
