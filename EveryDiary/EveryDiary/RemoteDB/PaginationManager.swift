//
//  PaginationManager.swift
//  EveryDiary
//
//  Created by Dahlia on 3/12/24.
//
import Firebase

class PaginationManager {
    private let db = Firestore.firestore()
    private var query: Query? = nil
    private var lastDocumentSnapshot: DocumentSnapshot?
    private var listener: ListenerRegistration?
    var isDeleted: Bool = false
    
    func getNextPage(completion: @escaping ([DiaryEntry]?) -> Void) {
        guard let userID = DiaryManager.shared.getUserID() else {
            completion(nil)
            return
        }
        
        var collection = db.collection("users")
            .document(userID)
            .collection("diaries")
            .order(by: "dateString", descending: true)
            .whereField("isDeleted", isEqualTo: isDeleted)
        
        if let lastDocumentSnapshot = lastDocumentSnapshot {
            collection = collection.start(afterDocument: lastDocumentSnapshot)
        }
        
        let query = collection.limit(to: 15)
        
        query.addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
//                print("Error fetching documents: \(error)")
                completion(nil)
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                completion(nil)
                return
            }
            
            let entries = snapshot.documents.compactMap { document -> DiaryEntry? in
                do {
                    let entry = try document.data(as: DiaryEntry.self)
                    return entry
                } catch {
                    print("Error decoding document: \(error)")
                    return nil
                }
            }
            
            if let lastDocument = snapshot.documents.last {
                self.lastDocumentSnapshot = lastDocument
            }
            completion(entries)
        }
    }
    
    func resetQuery() {
        query = nil
        lastDocumentSnapshot = nil
    }
}
