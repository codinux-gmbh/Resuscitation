import SwiftUI


struct ContentView: View {
    
    static private let ButtonHeight: CGFloat = 50
    
    static private let TopButtonsWidth = halfOfScreenWithSpacing
    
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink("Logs", destination: LogsOverviewDialog())
                        .frame(width: Self.TopButtonsWidth, height: Self.ButtonHeight, alignment: .leading)
                        .padding(.leading, 12)
                        .disabled(true)
                    
                    Spacer()
                    
                    NavigationLink("Options", destination: SettingsDialog())
                        .frame(width: Self.TopButtonsWidth, height: Self.ButtonHeight, alignment: .trailing)
                        .padding(.trailing, 12)
                        .disabled(true)
                }
                
                Spacer()
                
                NavigationLink("Start Code", destination: CodeDialog())
                    .frame(width: Self.screenWidth, height: Self.ButtonHeight)
                
                Spacer()
            }
        }
        .hideNavigationBar()
        .background(Color.blue)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
