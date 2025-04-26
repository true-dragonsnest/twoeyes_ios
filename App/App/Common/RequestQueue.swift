//
//  RequestQueue.swift
//  App
//
//  Created by Yongsik Kim on 4/25/25.
//

import Foundation
import Combine

class RequestQueue<Request: Sendable> {
    private let q = PassthroughSubject<Request, Never>()
    private var task: Task<Void, Never>?
    private let onRequest: (Request) async -> Void
    private let debounce: TimeInterval?
    private var sink: AnyCancellable?
    
    init(debounce: TimeInterval? = nil,
         onRequest: @escaping @Sendable (Request) async -> Void)
    {
        self.debounce = debounce
        self.onRequest = onRequest
        
        setupQueue()
        
        func setupQueue() {
            let stream = AsyncStream<Request> { cont in
                sink?.cancel()
                if let debounce {
                    sink = q.debounce(for: .seconds(debounce),
                                      scheduler: DispatchQueue.global()).sink
                    {
                        cont.yield($0)
                    }
                } else {
                    sink = q.sink {
                        cont.yield($0)
                    }
                }
            }
            
            task?.cancel()
            task = Task {
                for await req in stream {
                    await onRequest(req)
                }
            }
        }
    }
    
    deinit {
        task?.cancel()
        sink?.cancel()
    }
    
    func send(_ req: Request) {
        q.send(req)
    }
}
