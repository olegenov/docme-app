//
//  ContentView.swift
//  docme
//
//  Created by Никита Китаев on 04/05/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.theme) var theme
    @EnvironmentObject var themeController: DSThemeController

    var body: some View {
        VStack {
            TitleView(text: "Some title")
            Picker("Тема", selection: Binding(
                get: { themeController.mode },
                set: { newMode in
                    DS.setMode(newMode)
                }
            )) {
                ForEach(ThemeMode.allCases) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
        .background(theme.gradients.background)
    }
}

#Preview {
    ContentView()
}
