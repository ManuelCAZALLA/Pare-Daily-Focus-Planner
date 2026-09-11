import Foundation
import PDFKit
import UIKit

enum ObligationPDFExporter {
    static func export(obligation: LifeObligation, template: ObligationTemplate) throws -> URL {
        let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
        let summaryData = renderer.pdfData { context in
            context.beginPage()
            let margin: CGFloat = 44
            var y: CGFloat = margin

            func draw(_ text: String, font: UIFont, color: UIColor = .label, spacing: CGFloat = 12) {
                let rect = CGRect(x: margin, y: y, width: pageBounds.width - margin * 2, height: pageBounds.height - y - margin)
                let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let height = (text as NSString).boundingRect(with: CGSize(width: rect.width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil).height
                (text as NSString).draw(in: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: ceil(height)), withAttributes: attributes)
                y += ceil(height) + spacing
            }

            draw("Recuerda tus Trámites", font: .systemFont(ofSize: 13, weight: .semibold), color: .systemGreen, spacing: 24)
            draw(template.title, font: .systemFont(ofSize: 28, weight: .bold), spacing: 8)
            draw(template.category.title, font: .systemFont(ofSize: 14), color: .secondaryLabel, spacing: 28)
            let formatter = DateFormatter()
            formatter.locale = .current
            formatter.dateStyle = .long
            func field(_ title: String, _ value: String?) {
                guard let value, !value.isEmpty else { return }
                draw(title.uppercased(), font: .systemFont(ofSize: 10, weight: .bold), color: .secondaryLabel, spacing: 4)
                draw(value, font: .systemFont(ofSize: 15), spacing: 18)
            }
            field("Titular", obligation.holderName)
            field("Fecha de vencimiento", obligation.expiryDate.map(formatter.string(from:)))
            field("Fecha para empezar", obligation.actionStartDate.map(formatter.string(from:)))
            field("Documentación necesaria", obligation.documentsNeeded)
            field("Notas", obligation.notes)
            draw("Generado el \(formatter.string(from: Date()))", font: .systemFont(ofSize: 10), color: .secondaryLabel, spacing: 0)
        }

        let document = PDFDocument(data: summaryData)!
        if let scannedData = obligation.scannedDocumentData, let scannedDocument = PDFDocument(data: scannedData) {
            for index in 0..<scannedDocument.pageCount {
                if let page = scannedDocument.page(at: index) {
                    document.insert(page, at: document.pageCount)
                }
            }
        }
        guard let data = document.dataRepresentation() else { throw CocoaError(.fileWriteUnknown) }
        let safeName = template.title.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName)-\(UUID().uuidString)").appendingPathExtension("pdf")
        try data.write(to: url, options: .atomic)
        return url
    }
}
