import Foundation

func listDirectory(atPath path: String, showHidden: Bool, detailed: Bool) {
    let fileManager = FileManager.default

    do {
        // Get contents of the directory
        let contents = try fileManager.contentsOfDirectory(atPath: path)

        // Filter and sort files
        var filteredContents = contents
        if !showHidden {
            filteredContents = contents.filter { !$0.hasPrefix(".") }
        }
        filteredContents.sort()

        // Display the contents
        for item in filteredContents {
            if detailed {
                let fullPath = (path as NSString).appendingPathComponent(item)
                if let attributes = try? fileManager.attributesOfItem(atPath: fullPath) {
                    let size = attributes[.size] as? Int ?? 0
                    let modificationDate = attributes[.modificationDate] as? Date ?? Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .short
                    print("\(size) bytes \(dateFormatter.string(from: modificationDate)) \(item)")
                }
            } else {
                print(item)
            }
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

func main() {
    let arguments = CommandLine.arguments

    // Default to current directory if no path is provided
    var directoryPath = FileManager.default.currentDirectoryPath

    // Flags
    var showHidden = false
    var detailed = false

    // Parse arguments
    for arg in arguments.dropFirst() {
        switch arg {
        case "-a":
            showHidden = true
        case "-l":
            detailed = true
        default:
            // Assumes it's a directory path
            directoryPath = arg
        }
    }

    // Ensure the path is absolute
    if !directoryPath.hasPrefix("/") {
        let cwd = FileManager.default.currentDirectoryPath
        directoryPath = (cwd as NSString).appendingPathComponent(directoryPath)
    }

    // List the directory
    listDirectory(atPath: directoryPath, showHidden: showHidden, detailed: detailed)
}

main()
