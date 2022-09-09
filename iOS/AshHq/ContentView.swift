import SwiftUI
import PhoenixLiveViewNative

struct ContentView: View {
    @State var coordinator: LiveViewCoordinator<AshHqRegistry> = {
        var config = LiveViewConfiguration()
        config.navigationMode = .enabled
        return LiveViewCoordinator(URL(string: "http://localhost:4000")!, config: config)
    }()

    var body: some View {
        LiveView(coordinator: coordinator).background(.orange).ignoresSafeArea()
    }
}
