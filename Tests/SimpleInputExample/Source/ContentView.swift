// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/09/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SimpleInput
import SwiftUI

struct ContentView: View {
    @State var input: SimpleInput?
    @State var text: String = ""
    
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            
            Text(text.isEmpty ? "No Input" : "Input was: \(text)")
            
            VStack {
                Button(action: handleShowInput) {
                    Text("Show Input")
                }
            }.padding()
        }
        .simpleInput($input)
    }
    
    func handleShowInput() {
        input = SimpleInput(
            title: "Test",
            message: "Message",
            field: .init(placeholder: "placeholder", value: text),
            buttons: [
                .normal("OK") { entered in text = entered },
                .cancel() { text = "Input cancelled" }
            ]
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
