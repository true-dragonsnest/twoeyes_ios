//
//  PaginatedList.swift
//  App
//
//  Created by Yongsik Kim on 4/25/25.
//

import Foundation
import SwiftUI

private let T = #fileID

protocol PaginatedListFetcher {
    associatedtype ItemType
    associatedtype NextTokenType
    
    
}

@Observable
class PaginatedList<ItemType, NextTokenType> {
    typealias Fetcher = (_ nextToken: NextTokenType?, _ pageSize: Int) async throws -> (items: [ItemType], nextToken: NextTokenType?)
    let pageSize: Int
    
    // backward offset from current end of list to trigger next fetch
    // ie, when current count = 100, triggerOffset = 3, if index >= 100 - 3 will triger next fetch.
    let triggerOffset: Int
    
    let fetcher: Fetcher
 
    private(set) var items: [ItemType] = []
    private(set) var nextToken: NextTokenType?
    private(set) var isEndOfList = false
    private(set) var fetching = false
    
    init(pageSize: Int, triggerOffset: Int, startPoint: NextTokenType? = nil, fetcher: @escaping Fetcher) {
        self.pageSize = pageSize
        self.triggerOffset = triggerOffset
        self.nextToken = startPoint
        self.fetcher = fetcher
    }
    
    subscript(index: Int) -> ItemType? {
        items[safe: index]
    }
    
    func reset() {
        items = []
        nextToken = nil
        isEndOfList = false
        fetching = false
    }
    
    private func needsFetching(offset: Int) -> Bool {
        if isEndOfList {
            return false
        }
        if offset >= items.count - triggerOffset {
            return true
        }
        return false
    }
    
    private func performFetch(at offset: Int, forced: Bool = false) async throws -> Bool {
        "FETCH #\(offset): request (forced = \(forced))".ld(T)
        
        do {
            let result = try await fetcher(nextToken, pageSize)
            guard Task.isCancelled == false else { return false }
            
            nextToken = result.items.isEmpty ? nil : result.nextToken
            if result.items.isEmpty == false {
                items.append(contentsOf: result.items)
            }
            "FETCH #\(offset): \(result.items.count), next = \(o: nextToken) -> \(items.count)".ld(T)
        } catch {
            guard Task.isCancelled == false else { return false }
            "FETCH #\(offset): failed : \(error)".le(T)
            throw error
        }
        
        return true
    }
    
    private struct FetchRequest {
        let offset: Int
        let forced: Bool
        let list: PaginatedList<ItemType, NextTokenType>?
    }
    
    private var fetchReqQ: RequestQueue<FetchRequest> = .init() { req in
        guard let list = req.list else { return }
        guard req.forced || list.needsFetching(offset: req.offset) else { return }
        
        _ = try? await list.performFetch(at: req.offset, forced: req.forced)
    }
    
    func prefetchIfNeeded(at offset: Int, forced: Bool = false) {
        fetchReqQ.send(.init(offset: offset, forced: forced, list: self))
    }
}
