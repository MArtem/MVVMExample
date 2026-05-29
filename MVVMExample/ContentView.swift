import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("MVVMExample")
                .font(.largeTitle.bold())

            Text("Reusable baseline installed. The MVVM demo flow will be implemented from the project specification.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ContentView()
}
