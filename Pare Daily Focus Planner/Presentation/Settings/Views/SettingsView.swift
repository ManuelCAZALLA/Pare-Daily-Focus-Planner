import SwiftUI

struct SettingsView: View {
    @Environment(NotificationService.self) private var notificationService
    @Environment(RoutineViewModel.self) private var routineVM
    @State private var viewModel = SettingsViewModel()

    // Ajustes persistentes de planificación
    @AppStorage("weekStartsOnMonday") private var weekStartsOnMonday: Bool = true
    @AppStorage("autoHideCompletedTasks") private var autoHideCompletedTasks: Bool = true

    var body: some View {
        ZStack {
            Color(hex: "#0C0C0E").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    notificationsSection
                    routineSection
                    planningSection
                    supportSection
                    legalSection
                    aboutSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 36)
            }
        }
        .task { await notificationService.refreshAuthorizationStatus() }
    }

    // MARK: - Sections

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
                    .foregroundStyle(.white)
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

    private var routineSection: some View {
        SettingsSection(title: "Rutina Diaria") {
            // Morning Toggle + Hora
            Toggle(isOn: Binding(
                get: { routineVM.morningEnabled },
                set: { routineVM.morningEnabled = $0 }
            )) {
                SettingsRow(
                    icon: "sunrise.fill",
                    title: "Rutina de mañana",
                    detail: LocalizedStringKey(routineVM.morningEnabled ? String(format: "%02d:%02d", routineVM.morningHour, routineVM.morningMinute) : "Desactivada"),
                    tint: Color(hex: "#FF9500"),
                    showsChevron: false
                )
            }
            .tint(Color(hex: "#FF9500"))
            .padding(.vertical, 4)

            if routineVM.morningEnabled {
                Divider().overlay(Color.white.opacity(0.08))
                HStack {
                    Text("Hora")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    DatePicker("", selection: Binding(
                        get: { routineVM.morningTime },
                        set: { routineVM.morningTime = $0 }
                    ), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .tint(Color(hex: "#FF9500"))
                }
                .padding(.vertical, 6)
            }

            Divider().overlay(Color.white.opacity(0.08))

            // Evening Toggle + Hora
            Toggle(isOn: Binding(
                get: { routineVM.eveningEnabled },
                set: { routineVM.eveningEnabled = $0 }
            )) {
                SettingsRow(
                    icon: "moon.stars.fill",
                    title: "Rutina de noche",
                    detail: LocalizedStringKey(routineVM.eveningEnabled ? String(format: "%02d:%02d", routineVM.eveningHour, routineVM.eveningMinute) : "Desactivada"),
                    tint: Color(hex: "#5E5CE6"),
                    showsChevron: false
                )
            }
            .tint(Color(hex: "#5E5CE6"))
            .padding(.vertical, 4)

            if routineVM.eveningEnabled {
                Divider().overlay(Color.white.opacity(0.08))
                HStack {
                    Text("Hora")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    DatePicker("", selection: Binding(
                        get: { routineVM.eveningTime },
                        set: { routineVM.eveningTime = $0 }
                    ), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .tint(Color(hex: "#5E5CE6"))
                }
                .padding(.vertical, 6)
            }
        }
    }

    private var planningSection: some View {
        SettingsSection(title: "Planificación") {
            Toggle(isOn: $weekStartsOnMonday) {
                SettingsRow(
                    icon: "calendar",
                    title: "Semana laboral",
                    detail: weekStartsOnMonday ? "Empieza en lunes" : "Empieza en domingo",
                    tint: Color.pareGreen,
                    showsChevron: false
                )
            }
            .tint(Color.pareGreen)
            .padding(.vertical, 4)

            Divider().overlay(Color.white.opacity(0.08))

            Toggle(isOn: $autoHideCompletedTasks) {
                SettingsRow(
                    icon: "checkmark.circle",
                    title: "Tareas completadas",
                    detail: autoHideCompletedTasks ? "Se ocultan al terminar" : "Se muestran siempre",
                    tint: Color.pareGreen,
                    showsChevron: false
                )
            }
            .tint(Color.pareGreen)
            .padding(.vertical, 4)
        }
    }

    private var supportSection: some View {
        SettingsSection(title: "Soporte y Comunidad") {
            Button(action: viewModel.openWebsite) {
                SettingsRow(
                    icon: "globe",
                    title: "Página Web",
                    detail: "Visita nuestro sitio oficial",
                    tint: .blue,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)

            Divider().overlay(Color.white.opacity(0.08))

            Button(action: viewModel.openEmail) {
                SettingsRow(
                    icon: "envelope.fill",
                    title: "Contáctanos",
                    detail: "Envíanos un email para ayuda o sugerencias",
                    tint: .orange,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)

            Divider().overlay(Color.white.opacity(0.08))

            Button(action: viewModel.rateApp) {
                SettingsRow(
                    icon: "star.fill",
                    title: "Valora la App",
                    detail: "¿Te gusta Pare? Déjanos una reseña",
                    tint: .yellow,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var legalSection: some View {
        SettingsSection(title: "Legal") {
            Button(action: viewModel.openPrivacyPolicy) {
                SettingsRow(
                    icon: "hand.raised.fill",
                    title: "Política de Privacidad",
                    detail: "Tus datos son tuyos",
                    tint: Color.pareGreen,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)

            Divider().overlay(Color.white.opacity(0.08))

            Button(action: viewModel.openTermsOfUse) {
                SettingsRow(
                    icon: "doc.text.fill",
                    title: "Términos de Uso",
                    detail: "Condiciones del servicio",
                    tint: .gray,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var aboutSection: some View {
        SettingsSection(title: "Acerca de") {
            SettingsRow(
                icon: "info.circle.fill",
                title: "Pare Daily Focus Planner",
                detail: "Versión \(viewModel.appVersion)",
                tint: Color.pareGreen,
                showsChevron: false
            )
        }
    }
}

// MARK: - Componentes UI Reutilizables

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
                .font(.system(size: 18))
                .frame(width: 24, height: 24)

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
        // Asegura que toda la fila sea clickeable cuando se envuelve en un Button
        .contentShape(Rectangle())
    }
}
