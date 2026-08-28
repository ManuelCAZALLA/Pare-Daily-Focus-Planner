// TramiteWidgets.swift
import WidgetKit
import SwiftUI

@main
struct TramiteWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        ObligationWidget()
        RoutineWidget()
    }
}
