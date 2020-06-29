//
//  ProspectsView.swift
//  hotProspectActual
//
//  Created by Aldiyar Batyrbekov on 6/27/20.
//  Copyright © 2020 Aldiyar Batyrbekov. All rights reserved.
//

import SwiftUI
import CodeScanner
import UserNotifications

enum FilterType {
    case none, contacted, uncontacted
}
enum SortType {
    case byNameAsc, byNameDesc, none
}
struct ProspectsView: View {
    @State private var isShowingScanner = false
    @State private var isSortingOptionsPresented = false
    @State private var sortOption = SortType.none
    @EnvironmentObject var prospects: Prospects
    let filter: FilterType
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    var sortedProspects: [Prospect] {
        switch sortOption {
        case .byNameAsc:
            return filteredProspects.sorted {lhs, rhs in
                lhs.name < rhs.name
            }
        case .byNameDesc:
            return filteredProspects.sorted {lhs, rhs in
                lhs.name > rhs.name
            }
        case .none:
            return filteredProspects
        }
        
        
    }
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedProspects) { prospect in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        if prospect.isContacted {
                            Spacer()
                            Circle()
                                .fill(Color.green)
                                .frame(width: 20, height: 20)
                        }
                    }
                        
                    .contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted") {
                            self.prospects.toggle(prospect)
                        }
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(title)
            .navigationBarItems(leading: Button(action: {
                self.isSortingOptionsPresented = true
            }, label: {
                Text("Sort Options")
            }), trailing: Button(action: {
                self.isShowingScanner = true
            }, label: {
                Image(systemName: "qrcode.viewfinder")
                Text("Scan")
            }))
        }
    .actionSheet(isPresented: $isSortingOptionsPresented, content: {
        ActionSheet(title: Text("Sort Options"), buttons: [
            .default(Text("Name Ascending"), action: {
                self.sortOption = .byNameAsc
            }),
            .default(Text("Name Descending"), action: {
                self.sortOption = .byNameDesc
            }),
            .default(Text("None"), action: {
                self.sortOption = .none
            }),
            .cancel()
        ])
    })
        .sheet(isPresented: $isShowingScanner, content: {
            CodeScannerView(codeTypes: [.qr], simulatedData: "Aldi\naldi@test.com", completion: self.handleScan)
        })
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(let code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            
            self.prospects.add(prospect: person)
        case .failure(let error):
            print("Scanning failed")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            //            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
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
                        print("Won't show the notifications")
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
