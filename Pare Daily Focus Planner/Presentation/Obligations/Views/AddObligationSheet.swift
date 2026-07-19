// AddObligationSheet.swift
import SwiftUI

struct AddObligationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ObligationsViewModel.self) private var obligationsVM

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
        } else {
            _holderName = State(initialValue: "")
            _hasExpiryDate = State(initialValue: false)
            _expiryDate = State(initialValue: Date())
            _hasActionStartDate = State(initialValue: false)
            _actionStartDate = State(initialValue: Date())
            _alertOffset = State(initialValue: nil)
            _documentsNeeded = State(initialValue: "")
            _notes = State(initialValue: "")
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
                            placeholder: "Nombre del titular...",
                            text: $holderName
                        )
                    }
                    
                    // Dates section
                    VStack(alignment: .leading, spacing: 14) {
                        sectionLabel("Fechas clave")
                        
                        VStack(spacing: 12) {
                            dateToggleRow(
                                title: "Tiene fecha de caducidad",
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
                            }
                            
                            Divider().background(Color(hex: "#2A2A2C"))
                            
                            dateToggleRow(
                                title: "Cuándo empezar a prepararlo",
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
                    
                    // Additional info section
                    VStack(alignment: .leading, spacing: 10) {
                        sectionLabel("Detalles adicionales")
                        
                        VStack(spacing: 12) {
                            customTextEditor(
                                placeholder: "Documentos necesarios...",
                                text: $documentsNeeded,
                                icon: "doc.text"
                            )
                            
                            customTextEditor(
                                placeholder: "Notas o detalles adicionales...",
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
                                Text("Eliminar trámite")
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
            .navigationTitle(editingObligation == nil ? "Añadir trámite" : "Editar trámite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.pareGreen)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .preferredColorScheme(.dark)
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
        do {
            try obligationsVM.save(
                template: template,
                existing: editingObligation,
                holderName: holderName,
                expiryDate: hasExpiryDate ? expiryDate : nil,
                actionStartDate: hasActionStartDate ? actionStartDate : nil,
                alertOffset: hasExpiryDate ? alertOffset : nil,
                notes: notes,
                documentsNeeded: documentsNeeded
            )
            dismiss()
        } catch {
            print("Failed to save obligation: \(error)")
        }
    }

    private var reminderPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("¿Cuándo quieres que te avise?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            Picker("Aviso", selection: $alertOffset) {
                Text("Sin aviso").tag(Optional<ObligationAlertOffset>.none)
                ForEach(ObligationAlertOffset.allCases) { offset in
                    Text(offset.label).tag(Optional(offset))
                }
            }
            .pickerStyle(.menu)
            .tint(Color.pareGreen)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#0C0C0E"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .onChange(of: alertOffset) { _, newValue in
                guard newValue != nil else { return }
                Task { await obligationsVM.requestNotificationPermission() }
            }
        }
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
