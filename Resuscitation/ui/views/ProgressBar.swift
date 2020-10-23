import SwiftUI


struct ProgressBar: View {
    
    static private let CornerRadius: CGFloat = 20
    
    
    @Binding private var progress: CGFloat
    
    private let isOriginOnTheRight: Bool
    
    
    init(_ progress: Binding<CGFloat>, _ isOriginOnTheRight: Bool = false) {
        self._progress = progress
        self.isOriginOnTheRight = isOriginOnTheRight
    }
    

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                
                createBar(.gray, geometry.size.width)
                
                createBar(.blue, geometry.size.width * progress)
                    .alignHorizontally(isOriginOnTheRight ? .trailing : .leading)
            }
        }
    }
    
    
    private func createBar(_ color: Color, _ width: CGFloat) -> some View {
        return RoundedRectangle(cornerRadius: Self.CornerRadius)
                .foregroundColor(color)
                .frame(width: width > 0 ? width : 0)
    }

}


struct ProgressBar_Previews: PreviewProvider {

    static var previews: some View {
        ProgressBar(.constant(0.4))
            .frame(width: 300, height: 30)
    }

}
