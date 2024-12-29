import Foundation

func main() {
    print("Main thread start - \(Thread.current)")

    let backgroundThread = Thread {
        print("Background thread start - \(Thread.current)")
        Thread.sleep(forTimeInterval: 5.0)
        print("Background thread end - \(Thread.current)")
    }
    backgroundThread.name = "t1"
    backgroundThread.start()

    // Wait for the background thread
    while !backgroundThread.isFinished {
        Thread.sleep(forTimeInterval: 0.1)
    }

    print("Main thread end - \(Thread.current)")
}

main()
