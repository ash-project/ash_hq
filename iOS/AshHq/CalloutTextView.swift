import SwiftUI
import PhoenixLiveViewNative
import OSLog

struct CalloutTextView: View {
    let context: LiveContext<AshHqRegistry>
    let text: String
    
    init(element: Element, context: LiveContext<AshHqRegistry>) {
        self.context = context
        if let str = element.attrIfPresent("text") {
           self.text = str
        } else {
            self.text = ""
        }
    }
    
    var body: some View {
        return Text(self.text).foregroundColor(.orange)
    }
}
