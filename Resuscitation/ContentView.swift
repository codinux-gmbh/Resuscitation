import SwiftUI


struct ContentView: View {
    
    @Inject private var presenter: Presenter
    
    
    static private let ButtonHeight: CGFloat = 50
    
    static private let TopButtonsWidth = halfOfScreenWithSpacing
    
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink("Logs", destination: LazyView(LogsOverviewDialog(presenter)))
                        .frame(width: Self.TopButtonsWidth, height: Self.ButtonHeight, alignment: .leading)
                        .padding(.leading, 12)
                    
                    Spacer()
                    
                    NavigationLink("Options", destination: LazyView(SettingsDialog()))
                        .frame(width: Self.TopButtonsWidth, height: Self.ButtonHeight, alignment: .trailing)
                        .padding(.trailing, 12)
                        .disabled(true)
                }
                
                Spacer()
                
                NavigationLink("Start Code", destination: LazyView(CodeDialog(presenter)))
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
