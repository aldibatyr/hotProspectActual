//
//  Prospect.swift
//  hotProspectActual
//
//  Created by Aldiyar Batyrbekov on 6/28/20.
//  Copyright © 2020 Aldiyar Batyrbekov. All rights reserved.
//

import Foundation

class Prospect: Identifiable, Codable {
    let id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
}

class Prospects: ObservableObject {
    static let saveKey = "SavedData"
    @Published private(set) var people: [Prospect]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                self.people = decoded
                return
            }
        }
        self.people = []
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    func add(prospect: Prospect) {
        people.append(prospect)
        save()
    }
}
