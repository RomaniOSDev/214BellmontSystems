import SwiftUI

struct AppToolbarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(Color("AppSurface").opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func appToolbarStyle() -> some View {
        modifier(AppToolbarStyle())
    }
}

struct AppFormStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
    }
}

extension View {
    func appFormStyle() -> some View {
        modifier(AppFormStyle())
    }
}
