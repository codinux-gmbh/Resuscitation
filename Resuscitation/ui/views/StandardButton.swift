import SwiftUI


struct StandardButton: View {
    
    static let DefaultButtonHeight: CGFloat = Self.screenHeight / 8 < 100 ? Self.screenHeight / 8 : 100
    
    
    private let title: LocalizedStringKey
    
    private let width: CGFloat
    
    private let height: CGFloat
    
    private let action: () -> Void
    
    
    init(_ title: LocalizedStringKey, _ action: @escaping () -> Void) {
        self.init(title, Self.halfOfScreenWithSpacing, Self.DefaultButtonHeight, action)
    }
    
    init(_ title: LocalizedStringKey, _ width: CGFloat = Self.halfOfScreenWithSpacing, _ action: @escaping () -> Void) {
        self.init(title, width, Self.DefaultButtonHeight, action)
    }
    
    init(_ title: LocalizedStringKey, _ width: CGFloat = Self.halfOfScreenWithSpacing, _ height: CGFloat = Self.DefaultButtonHeight, _ action: @escaping () -> Void) {
        self.title = title
        self.width = width
        self.height = height
        self.action = action
    }

    var body: some View {
        Button(title, action: self.action)
            .frame(width: width, height: height, alignment: .center)
            .overlay(StandardBorder())
    }

}


struct StandardButton_Previews: PreviewProvider {

    static var previews: some View {
        StandardButton("Label") { }
    }

}
