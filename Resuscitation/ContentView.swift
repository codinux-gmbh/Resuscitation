import SwiftUI


struct ContentView: View {
    
    @Inject private var presenter: Presenter
    
    
    static private let ButtonHeight = halfOfScreenWithSpacing
    
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: LazyView(LogsOverviewDialog(presenter))) {
                        Text("Logs")
                            .frame(width: Self.halfOfScreenWithSpacing, height: Self.ButtonHeight)
                            .overlay(StandardBorder())
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: LazyView(SettingsDialog())) {
                        Text("Options")
                            .frame(width: Self.halfOfScreenWithSpacing, height: Self.ButtonHeight)
                            .overlay(StandardBorder())
                    }
                    .disabled(true)
                }
                
                Spacer()
                
                NavigationLink(destination: LazyView(CodeDialog(presenter))) {
                    Text("Start Code")
                        .frame(width: Self.screenWidth, height: Self.ButtonHeight)
                        .overlay(StandardBorder())
                }
                
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
