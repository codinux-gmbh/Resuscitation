import SwiftUI


struct StandardBorder: View {

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray, lineWidth: 1)
    }

}


struct StandardBorder_Previews: PreviewProvider {

    static var previews: some View {
        StandardBorder()
    }

}
