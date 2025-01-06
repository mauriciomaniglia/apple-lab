import Foundation

// MARK: - Custom Operation
class MyOperation: Operation {
    private let taskName: String

    init(taskName: String) {
        self.taskName = taskName
    }

    override func main() {
        // Check if the operation is cancelled before starting work
        if isCancelled {
            return
        }

        print("\(taskName) started on thread: \(Thread.current)")

        // Simulate some work
        Thread.sleep(forTimeInterval: 1.0)

        // Check cancellation again
        if isCancelled {
            return
        }

        print("\(taskName) finished on thread: \(Thread.current)")
    }
}

func main() {
    // Create an OperationQueue
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 2  // We allow up to 2 operations in parallel

    // Create some operations
    let operationA = MyOperation(taskName: "Operation A")
    let operationB = MyOperation(taskName: "Operation B")
    let operationC = MyOperation(taskName: "Operation C (depends on A and B)")

    // Set dependencies (C should start only after A and B finish)
    operationC.addDependency(operationA)
    operationC.addDependency(operationB)

    // Add operations to the queue
    queue.addOperation(operationA)
    queue.addOperation(operationB)
    queue.addOperation(operationC)

    // Optionally wait for them to finish (synchronously block)
    // If you don't wait, the program might exit before printing all logs
    queue.waitUntilAllOperationsAreFinished()

    print("All operations completed. Main thread is ending.")
}

// Entry point
main()
