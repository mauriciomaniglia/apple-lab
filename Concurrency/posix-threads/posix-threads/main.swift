import Foundation

private func pthreadRoutine(_ pointer: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    print("POSIX: Hello from pthread!")
    sleep(5)
    print("POSIX: pthread finishing work")

    return nil
}

func main() {
    print("Main thread start.")

    var pthread: pthread_t?

    let createError = pthread_create(&pthread, nil, { pointer in
        return pthreadRoutine(pointer)
    }, nil)

    if createError == 0 {
        print("POSIX: Thread created successfully.")

        // Join the thread to wait for its completion
        // pthread_join blocks the current thread until the target thread terminates
        if let thread = pthread {
            pthread_join(thread, nil)
            print("POSIX: Thread joined. Main thread continues.")
        }
    } else {
        print("Error creating pthread: \(createError)")
    }

    print("Main thread end.")
}


main()
