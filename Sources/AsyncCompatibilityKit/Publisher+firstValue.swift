//
//  Publisher+firstValue.swift
//  
//
//  Created by petrpavlik on 10/11/22.
//

import Combine
import Foundation

public extension Publisher where Failure == Never {
    /// Retrieve the first emitted value asynchronously.
    ///
    /// Any following emissions are ignored.
    var firstValue: Output {
        get async {
            await withCheckedContinuation { c in
                var cancellable: AnyCancellable?
                let onTermination = { cancellable?.cancel() }
                
                cancellable = self.first().sink { value in
                    c.resume(returning: value)
                    onTermination()
                }
            }
        }
    }
}

public extension Publisher {
    /// Retrieve the first emitted value asynchronously, or an error.
    ///
    /// Any following emissions are ignored.
    var firstValue: Output {
        get async throws {
            try await withCheckedThrowingContinuation { c in
                var cancellable: AnyCancellable?
                let onTermination = { cancellable?.cancel() }
                
                cancellable = self.first().sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        c.resume(throwing: error)
                    }
                    
                    onTermination()
                }, receiveValue: { value in
                    c.resume(returning: value)
                })
            }
        }
    }
}
