import SwiftUI


struct RightHalfScreenWidthButton: View {
    
    static let DefaultButtonHeight: CGFloat = 100
    
    
    private let title: LocalizedStringKey
    
    private let height: CGFloat
    
    private let action: () -> Void
    
    
    init(_ title: LocalizedStringKey, _ action: @escaping () -> Void) {
        self.init(title, Self.DefaultButtonHeight, action)
    }
    
    init(_ title: LocalizedStringKey, _ height: CGFloat = Self.DefaultButtonHeight, _ action: @escaping () -> Void) {
        self.title = title
        self.height = height
        self.action = action
    }

    var body: some View {
        Button(title, action: self.action)
            .frame(width: Self.halfOfScreenWithSpacing, height: height, alignment: .trailing)
            .padding(.trailing, 12)
    }

}


struct RightHalfScreenWidthButton_Previews: PreviewProvider {

    static var previews: some View {
        RightHalfScreenWidthButton("Label") { }
    }

}
