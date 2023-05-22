//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Suneetha Nallamotu on 5/17/23.
//

import SwiftUI
import CodeScanner
import UserNotifications

enum FilterType {
    case none, contacted, uncontacted
}

struct ProspectsView: View {
    @EnvironmentObject var prospects: Prospects
    var filter: FilterType
    @State private var isScanning = false
    var title: String {
        switch filter {
        case .none:
            return "All People"
        case .contacted:
            return "Contacted People"
        case .uncontacted:
            return "Un Contacted People"
            
        }
    }
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter {$0.isContacted}
        case .uncontacted:
            return prospects.people.filter{ !$0.isContacted}
        }
    }
    var body: some View {
        NavigationStack {
            //VStack {
                //Text("People: \(prospects.people.count)")
                List{
                    ForEach(filteredProspects) { prospect in
                        VStack(alignment: .leading){
                            Text(prospect.name)
                                .font(.headline)
                                .bold()
                            Text(prospect.email)
                                .foregroundColor(.secondary)
                        }
                        .swipeActions {
                            if prospect.isContacted {
                                Button {
                                    prospects.toggle(prospect: prospect)
                                } label: {
                                    Label("Mark UnContacted", systemImage: "person.crop.circle.badge.xmark")
                                }
                                .tint(.blue)
                            }
                            else {
                                Button {
                                    prospects.toggle(prospect: prospect)
                                } label: {
                                    Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark.")
                                }
                                .tint(.green)
                                Button {
                                    addNotifications(prospect: prospect)
                                } label: {
                                    Label("Remind Me", systemImage: "bell")
                                }
                                .tint(.orange)
                            }
                            
                        }
                            
                    }
                }

            //}
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
//                        let prospect = Prospect()
//                        prospect.name = "suni"
//                        prospect.email = "myemail@gmail.com"
//                        //prospect.isContacted = true
//                        prospects.people.append(prospect)
                        isScanning = true
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
            }
            .sheet(isPresented: $isScanning) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Suneetha \n suneetha@gmail.com") { result in
                    scanQR(result: result)
                }
                .presentationDetents([.medium])
            }
            
        }
        
    }
    func scanQR(result: Result<ScanResult, ScanError>) {
        
        switch result {
        case .success(let result):
            let people = Prospect()
             let peopleString  = result.string.components(separatedBy: "\n")
            if peopleString.count == 2 {
                people.name = peopleString[0]
                people.email = peopleString[1]
                prospects.add(people)
            }
            
        case .failure(let error):
            print("\(error.localizedDescription)")
        }
    }
    
    func addNotifications(prospect: Prospect){
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        let addRequest = {
            content.title = prospect.name
            content.subtitle = prospect.email
            content.sound = .default
            
            let timer = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: timer)
            center.add(request)
        }
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("authorization failed: \(error?.localizedDescription)")
                    }
                    
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
