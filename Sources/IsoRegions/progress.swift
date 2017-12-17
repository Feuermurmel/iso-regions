import Foundation

fileprivate struct FilePointerOutputStream: TextOutputStream {
    let filePointer: UnsafeMutablePointer<FILE>!
    
    public var connectedToATerminal: Bool {
        return isatty(fileno(stderr)) != 0
    }
    
    public mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}

fileprivate var standardErrorStream = FilePointerOutputStream(filePointer: stderr)

weak fileprivate var currentProgressIndicator: ProgressIndicator?

final class ProgressIndicator {
    fileprivate var outputStream: FilePointerOutputStream
    fileprivate var currentProgress: String = ""
    
    fileprivate init(outputStream: FilePointerOutputStream) {
        self.outputStream = outputStream
    }
    
    deinit {
        printToStream("", reuseLine: true)
    }
    
    func print(_ message: String) {
        if currentProgress != "" {
            // Clear the current line
            printToStream("", reuseLine: true)
        }
        
        printToStream(message, reuseLine: false)
        
        if currentProgress != "" {
            printToStream(currentProgress, reuseLine: true)
        }
    }
    
    func setProgress(_ progress: String) {
        self.currentProgress = progress
        printToStream(currentProgress, reuseLine: true)
    }
    
    fileprivate func printToStream(_ message: String, reuseLine: Bool) {
        Swift.print(
            message,
            reuseLine ? "\u{1b}[K\u{1b}[G" : "",
            separator: "",
            terminator: reuseLine ? "" : "\n",
            to: &outputStream)
    }
}

func createProgressIndicator() -> ProgressIndicator {
    precondition(currentProgressIndicator == nil)
    
    let progressIndicator = ProgressIndicator(outputStream: standardErrorStream)
    
    currentProgressIndicator = progressIndicator
    
    return progressIndicator
}

func printWithCurrentProgressIndicator(_ message: String) {
    let progressIndicator = currentProgressIndicator ?? createProgressIndicator()
    
    progressIndicator.print(message)
}
