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
    static let saveFile = "saveddata.json"
    @Published private(set) var people: [Prospect]
    
    init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let data = try? Data(contentsOf: paths[0].appendingPathComponent(Self.saveFile)) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                self.people = decoded
                return
            }
        }
        self.people = []
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let url = paths[0].appendingPathComponent(Self.saveFile)
            do {
                try encoded.write(to: url)
            } catch {
                print(error.localizedDescription)
            }
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
