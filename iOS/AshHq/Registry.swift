import SwiftUI
import PhoenixLiveViewNative

struct AshHqRegistry: CustomRegistry {
    enum TagName: String {
        case calloutText = "callout-text"
    }
    typealias AttributeName = EmptyRegistry.None
    
    static func lookup(_ name: TagName, element: Element, context: LiveContext<AshHqRegistry>) -> some View {
        print(name)
        switch name {
        case .calloutText:
            return CalloutTextView(element: element, context: context)
        }
    }
}
