import SwiftUI
import RevenueCatUI

struct SettingsView: View {
    @Environment(NotificationService.self) private var notificationService
    @Environment(RoutineViewModel.self) private var routineVM
    @Environment(PurchasesService.self) private var purchases   // ← RevenueCat
    private let viewModel = SettingsViewModel()

    // Ajustes persistentes de planificación
    @AppStorage("weekStartsOnMonday") private var weekStartsOnMonday: Bool = true
    @AppStorage("autoHideCompletedTasks") private var autoHideCompletedTasks: Bool = true

    // Sheets de monetización
    @State private var showPaywall = false
    @State private var showCustomerCenter = false

    var body: some View {
        ZStack {
            Color(hex: "#0C0C0E").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    proSection              // ← nuevo
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
        .task { await purchases.loadCustomerInfo() }    // ← cargar estado Pro
        // Paywall gestionado 100% por RevenueCat (diseñado en su dashboard)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .onRestoreCompleted { _ in showPaywall = false }
                .preferredColorScheme(.dark)
        }
        // Customer Center para usuarios Pro (cancelar, reembolso, cambiar plan…)
        .sheet(isPresented: $showCustomerCenter) {
#if canImport(RevenueCatUI)
#if os(iOS)
            if #available(iOS 15.0, *) {
                CustomerCenterView()
            } else {
                Text("Gestión de suscripción no disponible en esta versión")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
            }
#else
            Text("Gestión de suscripción no disponible en esta versión")
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
#endif
#else
            Text("Gestión de suscripción no disponible en esta versión")
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
#endif
        }
    }

    // MARK: - Pro section

    private var proSection: some View {
        @Bindable var purchases = purchases
        return SettingsSection(title: "Pare Pro") {
            if purchases.isProActive {

                // ── Usuario Pro ────────────────────────────────────────
                SettingsRow(
                    icon: "sparkles",
                    title: "settings.pro.active",
                    detail: "settings.pro.active.detail",
                    tint: Color.pareGreen,
                    showsChevron: false
                )

                Divider().overlay(Color.white.opacity(0.08))

                Button { showCustomerCenter = true } label: {
                    SettingsRow(
                        icon: "person.crop.circle.badge.checkmark",
                        title: "settings.pro.manage",
                        detail: "settings.pro.manage.detail",
                        tint: Color.pareGreen,
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)

            } else {

                // ── Usuario Free ───────────────────────────────────────
                Button { showPaywall = true } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.pareGreen.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.pareGreen)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("settings.pro.upgrade")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                            Text("settings.pro.upgrade.detail")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "#8E8E93"))
                        }
                        Spacer()
                        Text("VER")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(Color(hex: "#0C0C0E"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.pareGreen))
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Divider().overlay(Color.white.opacity(0.08))

                Button {
                    Task { await purchases.restorePurchases() }
                } label: {
                    SettingsRow(
                        icon: "arrow.clockwise",
                        title: "settings.pro.restore",
                        detail: "settings.pro.restore.detail",
                        tint: Color(hex: "#8E8E93"),
                        showsChevron: false
                    )
                }
                .buttonStyle(.plain)
            }

            #if DEBUG
            Divider().overlay(Color.white.opacity(0.08))

            Toggle(isOn: $purchases.debugForcePro) {
                SettingsRow(
                    icon: "flask.fill",
                    title: "Probar funciones Pro",
                    detail: purchases.debugForcePro ? "Pro activo (test)" : "Solo en builds de depuración",
                    tint: Color.purple,
                    showsChevron: false
                )
            }
            .tint(Color.purple)
            .padding(.vertical, 4)
            #endif
        }
    }

    // MARK: - Resto de secciones (sin cambios)

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
                Text("settings.title")
                    .font(.largeTitle.weight(.heavy))
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                Text("settings.subtitle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var notificationsSection: some View {
        SettingsSection(title: "settings.notifications") {
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
        @Bindable var rVM = routineVM

        return SettingsSection(title: "settings.routine") {
            Toggle(isOn: $rVM.morningEnabled) {
                SettingsRow(
                    icon: "sunrise.fill",
                    title: "Rutina de mañana",
                    detail: LocalizedStringKey(rVM.morningEnabled ? String(format: "%02d:%02d", rVM.morningHour, rVM.morningMinute) : String(localized: "Desactivada")),
                    tint: Color(hex: "#FF9500"),
                    showsChevron: false
                )
            }
            .tint(Color(hex: "#FF9500"))
            .padding(.vertical, 4)

            if rVM.morningEnabled {
                Divider().overlay(Color.white.opacity(0.08))
                HStack {
                    Text("Hora de aviso")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Spacer()
                    DatePicker("", selection: $rVM.morningTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .tint(Color(hex: "#FF9500"))
                }
                .padding(.vertical, 8)
            }

            Divider().overlay(Color.white.opacity(0.08))

            Toggle(isOn: $rVM.eveningEnabled) {
                SettingsRow(
                    icon: "moon.stars.fill",
                    title: "Rutina de noche",
                    detail: LocalizedStringKey(rVM.eveningEnabled ? String(format: "%02d:%02d", rVM.eveningHour, rVM.eveningMinute) : String(localized: "Desactivada")),
                    tint: Color(hex: "#5E5CE6"),
                    showsChevron: false
                )
            }
            .tint(Color(hex: "#5E5CE6"))
            .padding(.vertical, 4)

            if rVM.eveningEnabled {
                Divider().overlay(Color.white.opacity(0.08))
                HStack {
                    Text("Hora de aviso")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Spacer()
                    DatePicker("", selection: $rVM.eveningTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .tint(Color(hex: "#5E5CE6"))
                }
                .padding(.vertical, 8)
            }
        }
    }

    private var planningSection: some View {
        SettingsSection(title: "settings.planning") {
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
        SettingsSection(title: "settings.support") {
            if let url = viewModel.websiteURL {
                Link(destination: url) {
                    SettingsRow(
                        icon: "globe",
                        title: "Página Web",
                        detail: "Visita nuestro sitio oficial",
                        tint: .blue,
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)
            }

            Divider().overlay(Color.white.opacity(0.08))

            if let url = viewModel.emailURL {
                Link(destination: url) {
                    SettingsRow(
                        icon: "envelope.fill",
                        title: "Contáctanos",
                        detail: "Envíanos un email para ayuda o sugerencias",
                        tint: .orange,
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)
            }

            Divider().overlay(Color.white.opacity(0.08))

            if let url = viewModel.rateAppURL {
                Link(destination: url) {
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
    }

    private var legalSection: some View {
        SettingsSection(title: "settings.legal") {
            if let url = viewModel.privacyPolicyURL {
                Link(destination: url) {
                    SettingsRow(
                        icon: "hand.raised.fill",
                        title: "Política de Privacidad",
                        detail: "Tus datos son tuyos",
                        tint: Color.pareGreen,
                        showsChevron: true
                    )
                }
                .buttonStyle(.plain)
            }

            Divider().overlay(Color.white.opacity(0.08))

            if let url = viewModel.termsOfUseURL {
                Link(destination: url) {
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
    }

    private var aboutSection: some View {
        SettingsSection(title: "settings.about") {
            SettingsRow(
                icon: "info.circle.fill",
                title: "Pare Daily Focus Planner",
                detail: LocalizedStringKey(String(format: String(localized: "settings.version"), viewModel.appVersion)),
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
        .contentShape(Rectangle())
    }
}
