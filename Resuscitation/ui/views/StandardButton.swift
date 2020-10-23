import SwiftUI


struct StandardButton: View {
    
    static let DefaultButtonHeight: CGFloat = 100
    
    
    private let title: LocalizedStringKey
    
    private let width: CGFloat
    
    private let height: CGFloat
    
    private let action: () -> Void
    
    
    init(_ title: LocalizedStringKey, _ action: @escaping () -> Void) {
        self.init(title, Self.halfOfScreenWithSpacing, Self.DefaultButtonHeight, action)
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
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }

}


struct StandardButton_Previews: PreviewProvider {

    static var previews: some View {
        StandardButton("Label") { }
    }

}