// ObligationWidgetView.swift
import SwiftUI
import WidgetKit

struct ObligationWidgetView: View {
    let entry: PareWidgetEntry
    @Environment(\.widgetFamily) private var family

    private var obligations: [WidgetObligation] {
        guard let urgent = entry.urgentObligation else { return [] }
        var result = [urgent]
        for obligation in entry.obligations where obligation.id != urgent.id {
            result.append(obligation)
            break
        }
        return result
    }

    var body: some View {
        switch family {
        case .systemSmall: small
        default: medium
        }
    }

    // MARK: - Small

    private var small: some View {
        VStack(alignment: .leading, spacing: 8) {
            PareWidgetHeader(title: String(localized: "widget.obligation.short"))

            if let obligation = entry.urgentObligation {
                Spacer(minLength: 0)
                HStack(spacing: 8) {
                    Image(systemName: obligation.categoryIcon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.urgency(obligation.daysRemaining))
                    Text(obligation.title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                Spacer(minLength: 2)

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(obligation.daysRemaining)")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.urgency(obligation.daysRemaining))
                    Text(daysUnit(obligation.daysRemaining))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer(minLength: 0)
            } else {
                Spacer(minLength: 0)
                VStack(alignment: .leading, spacing: 6) {
                    Text("✓")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.pareGreen)
                    Text(String(localized: "widget.noObligations"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }
        }
        .widgetURL(URL(string: "pare://obligations"))
    }

    // MARK: - Medium

    private var medium: some View {
        VStack(alignment: .leading, spacing: 10) {
            PareWidgetHeader(title: String(localized: "widget.obligation.short"))

            if obligations.isEmpty {
                Spacer(minLength: 0)
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.pareGreen)
                    Text(String(localized: "widget.noObligations"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Spacer(minLength: 0)
            } else {
                VStack(spacing: 8) {
                    ForEach(obligations) { obligation in
                        obligationRow(obligation)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .widgetURL(URL(string: "pare://obligations"))
    }

    private func obligationRow(_ obligation: WidgetObligation) -> some View {
        HStack(spacing: 10) {
            Image(systemName: obligation.categoryIcon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.urgency(obligation.daysRemaining))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(obligation.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(categoryName(for: obligation.title))
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(obligation.daysRemaining)")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.urgency(obligation.daysRemaining))
                Text(daysUnit(obligation.daysRemaining))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    // MARK: - Helpers

    /// Extrae la unidad ("días", "days", "Tage"...) del formato localizado "%lld días".
    private func daysUnit(_ days: Int) -> String {
        let format = String(localized: "widget.days")
        let parts = format.split(separator: "%lld", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count > 1 else { return "" }
        return String(parts[1]).trimmingCharacters(in: .whitespaces)
    }

    private func categoryName(for templateID: String) -> String {
        ObligationTemplate.all.first { $0.title == templateID }?.category.title ?? ""
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    ObligationWidget()
} timeline: {
    PareWidgetEntry.placeholder
}
