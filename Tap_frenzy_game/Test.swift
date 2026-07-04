//
//  Test.swift
//  Tap_frenzy_game
//
//  Created by TEST on 2026-06-20.
//

import SwiftUI

struct Test: View {
    var body: some View {
        VStack {
            Text("You have arrived at the Detail Screen!")
                .font(.largeTitle)
                .bold()
        }

        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    Test()
}
