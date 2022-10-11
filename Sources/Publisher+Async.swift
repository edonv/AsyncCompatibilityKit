//
//  Publisher+Async.swift
//
//
//  Created by Edon Valdman on 10/11/22.
//

import Combine

@available(iOS, deprecated: 15.0, message: "AsyncCompatibilityKit is only useful when targeting iOS versions earlier than 15.")
@available(macOS, deprecated: 12.0, message: "AsyncCompatibilityKit is only useful when targeting macOS versions earlier than 12.0.")
public extension Publisher {
    /// Convert this publisher into an `AsyncThrowingStream` that
    /// can be iterated over asynchronously using `for try await`.
    /// The stream will yield each output value produced by the
    /// publisher and will finish once the publisher completes.
    var values: AsyncThrowingStream<Output, Error> {
        AsyncThrowingStream { continuation in
            var cancellable: AnyCancellable?
            let onTermination = { cancellable?.cancel() }

            continuation.onTermination = { @Sendable _ in
                onTermination()
            }

            cancellable = sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        continuation.finish()
                    case .failure(let error):
                        continuation.finish(throwing: error)
                    }
                }, receiveValue: { value in
                    continuation.yield(value)
                }
            )
        }
    }
}

@available(iOS, deprecated: 15.0, message: "AsyncCompatibilityKit is only useful when targeting iOS versions earlier than 15.")
@available(macOS, deprecated: 12.0, message: "AsyncCompatibilityKit is only useful when targeting macOS versions earlier than 12.0.")
public extension Publisher where Failure == Never {
    /// Convert this publisher into an `AsyncStream` that can
    /// be iterated over asynchronously using `for await`. The
    /// stream will yield each output value produced by the
    /// publisher and will finish once the publisher completes.
    var values: AsyncStream<Output> {
        AsyncStream { continuation in
            var cancellable: AnyCancellable?
            let onTermination = { cancellable?.cancel() }

            continuation.onTermination = { @Sendable _ in
                onTermination()
            }

            cancellable = sink(
                receiveCompletion: { _ in
                    continuation.finish()
                }, receiveValue: { value in
                    continuation.yield(value)
                }
            )
        }
    }
}
