//
//  ContentView.swift
//  HotProspects
//
//  Created by Suneetha Nallamotu on 5/16/23.
//

import SwiftUI
import UserNotifications

class delayTimer: ObservableObject {
    @Published var outputString: String = ""
     var value = 0 {
         willSet {
             objectWillChange.send()
         }
    }
    init() {
        for i in 1...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                self.value += 1
            }
        }
    }
    @MainActor
    func getResults() async {
        let fetchTask = Task  { () -> String in
            let url = URL(string: "https://hws.dev/readings.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode([Double].self, from: data)
            return "Result is found \(decodedData.count)"
        }
        let fetchResult = await fetchTask.result
        switch fetchResult {
        case .success(let str):
            outputString = str
        case .failure(let error):
            outputString = "error \(error.localizedDescription)"
        }
    }
}


struct ContentView: View {
    @StateObject var delay = delayTimer()
    @State var backgroundColor = Color.red
    var sequenceArray = Array(1...60)
    var winningProperty: String  {
        let nums = sequenceArray.random(5)
        let strNums = nums.map { String($0) }
        let joinedString = strNums.joined(separator: ",")
        return "\(joinedString)"
    }
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            //Text("count is \(delay.value)")
            Text("\(delay.outputString)")
                .background(backgroundColor)
            Text(winningProperty)
            Text("Change Color")
                .contextMenu {
                    Button(role: .destructive) {
                        backgroundColor = .red
                    } label: {
                        Label("Red", systemImage: "checkmark.fill")
                    }
                    Button {
                        backgroundColor = .blue
                    } label: {
                        Text("Blue")
                    }
                    Button {
                        backgroundColor = .green
                    } label: {
                        Text("Green")
                    }

                }
            List {
                Text("Swipe me")
                    .swipeActions {
                        Button(role:.destructive) {
                            print("delete action")
                        } label: {
                            Label("red", systemImage: "checkmark.circle.fill")
                        }

                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            print("leading delete")
                        } label: {
                            Label("Orange", systemImage: "pin")
                        }
                        .tint(.orange)

                    }
            }
            
            Button("Request Permisson") {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set")
                    }
                    else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            Button("Schedule Notification") {
                let content = UNMutableNotificationContent()
                content.title = "notifications"
                content.subtitle = "my local notifications \(delay.outputString)"
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
                
                
            }
            .buttonStyle(.borderedProminent)
        }
        .task {
            await delay.getResults()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
