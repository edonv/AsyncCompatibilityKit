//
//  Future+Async.swift
//
//
//  Created by Edon Valdman on 10/11/22.
//

import Combine

@available(iOS, deprecated: 15.0, message: "AsyncCompatibilityKit is only useful when targeting iOS versions earlier than 15.")
@available(macOS, deprecated: 12.0, message: "AsyncCompatibilityKit is only useful when targeting macOS versions earlier than 12.0.")
public extension Future {
    /// Convert this `Future` into a throwing async computed property.
    /// It will yield its one output value and then finish.
    var value: Output {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                var cancellable: AnyCancellable?
                let onTermination = { cancellable?.cancel() }
                
                // TODO: leaking continuation: https://www.hackingwithswift.com/quick-start/concurrency/how-to-use-continuations-to-convert-completion-handlers-into-async-functions#:~:text=On%20the%20other%20hand%2C%20if%20you%20fail%20to,any%20resources%20it’s%20using%20to%20be%20held%20indefinitely.
                cancellable = sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        
                        onTermination()
                        
//                        guard case .failure(let error) = completion else {
//                            return
//                        }
//                        continuation.resume(throwing: error)

                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
            }
        }
    }
}

@available(iOS, deprecated: 15.0, message: "AsyncCompatibilityKit is only useful when targeting iOS versions earlier than 15.")
@available(macOS, deprecated: 12.0, message: "AsyncCompatibilityKit is only useful when targeting macOS versions earlier than 12.0.")
public extension Future where Failure == Never {
    /// Convert this `Future` into an async computed property.
    /// It will yield its one output value and then finish.
    var value: Output {
        get async {
            await withCheckedContinuation { continuation in
                var cancellable: AnyCancellable?
                let onTermination = { cancellable?.cancel() }
                
                cancellable = sink(
                    receiveCompletion: { _ in
                        onTermination()
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
            }
        }
    }
}
