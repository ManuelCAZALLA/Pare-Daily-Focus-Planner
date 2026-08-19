// AddObligationSheet.swift
import SwiftUI
import PDFKit
import QuickLook
import RevenueCatUI

struct AddObligationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ObligationsViewModel.self) private var obligationsVM
    @Environment(PurchasesService.self) private var purchases

    let template: ObligationTemplate
    let editingObligation: LifeObligation?

    // MARK: - Form State
    @State private var holderName: String = ""
    @State private var hasExpiryDate: Bool = false
    @State private var expiryDate: Date = Date()
    @State private var hasActionStartDate: Bool = false
    @State private var actionStartDate: Date = Date()
    @State private var alertOffset: ObligationAlertOffset?
    @State private var documentsNeeded: String = ""
    @State private var notes: String = ""
    @State private var showDocumentScanner = false
    @State private var showPaywall = false
    @State private var previewURL: URL?
    @State private var escalatedAlertsEnabled = false

    init(template: ObligationTemplate, editingObligation: LifeObligation?) {
        self.template = template
        self.editingObligation = editingObligation
        
        // Initial state logic
        if let editingObligation {
            _holderName = State(initialValue: editingObligation.holderName ?? "")
            _hasExpiryDate = State(initialValue: editingObligation.expiryDate != nil)
            _expiryDate = State(initialValue: editingObligation.expiryDate ?? Date())
            _hasActionStartDate = State(initialValue: editingObligation.actionStartDate != nil)
            _actionStartDate = State(initialValue: editingObligation.actionStartDate ?? Date())
            _alertOffset = State(initialValue: editingObligation.alertOffset)
            _documentsNeeded = State(initialValue: editingObligation.documentsNeeded ?? "")
            _notes = State(initialValue: editingObligation.notes ?? "")
            _escalatedAlertsEnabled = State(initialValue: editingObligation.escalatedAlertsEnabled)
        } else {
            _holderName = State(initialValue: "")
            _hasExpiryDate = State(initialValue: false)
            _expiryDate = State(initialValue: Date())
            _hasActionStartDate = State(initialValue: false)
            _actionStartDate = State(initialValue: Date())
            _alertOffset = State(initialValue: nil)
            _documentsNeeded = State(initialValue: "")
            _notes = State(initialValue: "")
            _escalatedAlertsEnabled = State(initialValue: false)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header section detailing the template
                    headerCard
                    
                    // Basic info section
                    VStack(alignment: .leading, spacing: 10) {
                        sectionLabel("Información básica")
                        
                        customTextField(
                            placeholder: "obligations.holder",
                            text: $holderName
                        )
                    }
                    
                    // Dates section
                    VStack(alignment: .leading, spacing: 14) {
                        sectionLabel("Fechas clave")
                        
                        VStack(spacing: 12) {
                            dateToggleRow(
                                title: "obligations.expiry",
                                isOn: $hasExpiryDate,
                                date: $expiryDate
                            )
                            
                            if hasExpiryDate {
                                DatePicker(
                                    "Fecha de vencimiento",
                                    selection: $expiryDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.graphical)
                                .tint(Color.pareGreen)
                                .transition(.opacity.combined(with: .slide))

                                reminderPicker
                                escalatedAlertsSection
                            }
                            
                            Divider().background(Color(hex: "#2A2A2C"))
                            
                            dateToggleRow(
                                title: "obligations.actionStart",
                                isOn: $hasActionStartDate,
                                date: $actionStartDate
                            )
                            
                            if hasActionStartDate {
                                DatePicker(
                                    "Fecha para empezar",
                                    selection: $actionStartDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.graphical)
                                .tint(Color.pareGreen)
                                .transition(.opacity.combined(with: .slide))
                            }
                        }
                        .padding(14)
                        .background(Color(hex: "#1A1A1C"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 1)
                        )
                    }

                    scannedDocumentSection
                    
                    // Additional info section
                    VStack(alignment: .leading, spacing: 10) {
                        sectionLabel("Detalles adicionales")
                        
                        VStack(spacing: 12) {
                            customTextEditor(
                                placeholder: "obligations.documents",
                                text: $documentsNeeded,
                                icon: "doc.text"
                            )
                            
                            customTextEditor(
                                placeholder: "obligations.notes",
                                text: $notes,
                                icon: "pencil"
                            )
                        }
                    }
                    
                    // Delete button if editing
                    if editingObligation != nil {
                        Button(role: .destructive, action: delete) {
                            HStack {
                                Spacer()
                                Image(systemName: "trash")
                                Text("obligations.delete")
                                Spacer()
                            }
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.red)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(Color(hex: "#0C0C0E").ignoresSafeArea())
            .navigationTitle(editingObligation == nil ? "obligations.add" : "obligations.edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("obligations.cancel") {
                        obligationsVM.scannedDocumentData = nil
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "#8E8E93"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("obligations.save") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.pareGreen)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .preferredColorScheme(.dark)
        }
        #if !os(watchOS)
        .sheet(isPresented: $showDocumentScanner) {
            DocumentScanner(
                onScan: { data in
                    obligationsVM.scannedDocumentData = data
                    showDocumentScanner = false
                },
                onCancel: { showDocumentScanner = false }
            )
        }
        .quickLookPreview($previewURL)
        #endif
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.pareGreen.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: template.category.systemImage)
                    .font(.title3)
                    .foregroundStyle(Color.pareGreen)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(template.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Text(template.category.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(hex: "#1A1A1C"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var scannedDocumentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("obligation.scan.section")

            if let data = obligationsVM.scannedDocumentData {
                HStack(spacing: 14) {
                    documentThumbnail(for: data)

                    VStack(alignment: .leading, spacing: 10) {
                        Button("obligation.scan.view") {
                            previewURL = makePreviewURL(for: data)
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.pareGreen)

                        Button("obligation.scan.delete", role: .destructive) {
                            obligationsVM.scannedDocumentData = nil
                            previewURL = nil
                        }
                        .font(.subheadline.weight(.semibold))
                    }

                    Spacer()
                }
                .padding(14)
                .background(Color(hex: "#1A1A1C"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                #if !os(watchOS)
                Button {
                    if purchases.isProActive {
                        showDocumentScanner = true
                    } else {
                        showPaywall = true
                    }
                } label: {
                    Label("obligation.scan", systemImage: "doc.viewfinder")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.pareGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.pareGreen.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                #endif
            }
        }
    }

    @ViewBuilder
    private func documentThumbnail(for data: Data) -> some View {
        #if !os(watchOS)
        if let page = PDFDocument(data: data)?.page(at: 0),
           let image = page.thumbnail(of: CGSize(width: 88, height: 112), for: .mediaBox).cgImage {
            Image(uiImage: UIImage(cgImage: image))
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            Image(systemName: "doc.fill")
                .font(.title2)
                .foregroundStyle(Color.pareGreen)
                .frame(width: 72, height: 92)
                .background(Color.pareGreen.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        #endif
        #if os(watchOS)
        EmptyView()
        #endif
    }

    private func makePreviewURL(for data: Data) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("obligation-document-\(UUID().uuidString)")
            .appendingPathExtension("pdf")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    private func sectionLabel(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .kerning(1.0)
            .padding(.leading, 4)
    }

    private func customTextField(placeholder: LocalizedStringKey, text: Binding<String>, icon: String? = nil) -> some View {
        HStack(spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
            }
            TextField(placeholder, text: text)
                .font(.body)
                .foregroundStyle(.white)
                .tint(Color.pareGreen)
        }
        .padding(14)
        .background(Color(hex: "#1A1A1C"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 1)
        )
    }

    private func customTextEditor(placeholder: LocalizedStringKey, text: Binding<String>, icon: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                    .padding(.top, 2)
            }
            
            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(Color(hex: "#48484A"))
                        .padding(.top, 2)
                }
                TextField("", text: text, axis: .vertical)
                    .font(.body)
                    .foregroundStyle(.white)
                    .tint(Color.pareGreen)
                    .lineLimit(2...6)
            }
        }
        .padding(14)
        .background(Color(hex: "#1A1A1C"), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 1)
        )
    }

    private func dateToggleRow(title: LocalizedStringKey, isOn: Binding<Bool>, date: Binding<Date>) -> some View {
        Toggle(isOn: isOn.animation(.spring(duration: 0.25))) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
                
                if isOn.wrappedValue {
                    Text(date.wrappedValue.formatted(date: .long, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(Color.pareGreen)
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: Color.pareGreen))
    }

    private func save() {
        if editingObligation == nil && !obligationsVM.canAddObligation {
            showPaywall = true
            return
        }
        do {
            try obligationsVM.save(
                template: template,
                existing: editingObligation,
                holderName: holderName,
                expiryDate: hasExpiryDate ? expiryDate : nil,
                actionStartDate: hasActionStartDate ? actionStartDate : nil,
                alertOffset: hasExpiryDate ? alertOffset : nil,
                notes: notes,
                documentsNeeded: documentsNeeded,
                scannedDocumentData: obligationsVM.scannedDocumentData,
                escalatedAlertsEnabled: escalatedAlertsEnabled
            )
            dismiss()
        } catch {
            print("Failed to save obligation: \(error)")
        }
    }

    private var reminderPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("obligations.reminder")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            Picker("Aviso", selection: $alertOffset) {
                Text("obligations.noAlert").tag(Optional<ObligationAlertOffset>.none)
                ForEach(ObligationAlertOffset.allCases) { offset in
                    if offset.isProFeature && !purchases.isProActive {
                        HStack {
                            Text(offset.label)
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(Color.pareGreen)
                        }
                        .tag(Optional<ObligationAlertOffset>.none)
                    } else {
                        Text(offset.label).tag(Optional(offset))
                    }
                }
            }
            .pickerStyle(.menu)
            .tint(Color.pareGreen)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#0C0C0E"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .onChange(of: alertOffset) { _, newValue in
                guard let newValue else { return }
                if newValue.isProFeature && !purchases.isProActive {
                    alertOffset = nil
                    showPaywall = true
                    return
                }
                Task { await obligationsVM.requestNotificationPermission() }
            }
        }
    }

    private var escalatedAlertsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("pro.escalatedAlerts.title")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            Toggle(
                "pro.escalatedAlerts.toggle",
                isOn: Binding(
                    get: { escalatedAlertsEnabled },
                    set: { newValue in
                        if newValue && !purchases.isProActive {
                            showPaywall = true
                        } else {
                            escalatedAlertsEnabled = newValue
                            if newValue {
                                Task { await obligationsVM.requestNotificationPermission() }
                            }
                        }
                    }
                )
            )
            .tint(Color.pareGreen)

            if escalatedAlertsEnabled {
                Text("pro.escalatedAlerts.schedule")
                    .font(.caption)
                    .foregroundStyle(Color.pareGreen)
            }
        }
        .padding(.top, 4)
    }

    private func delete() {
        guard let editingObligation else { return }
        do {
            try obligationsVM.delete(editingObligation)
            dismiss()
        } catch {
            print("Failed to delete obligation: \(error)")
        }
    }
}
