import Foundation

extension Array {
    func all(where where_: (Element) -> Bool) -> Bool {
        return !contains(where: { !where_($0) })
    }
}

extension Dictionary {
    mutating func getOrUpdate(_ key: Key, computeValue: @autoclosure () -> Value) -> Value {
        if let value = self[key] {
            return value
        } else {
            let value = computeValue()
            self[key] = value
            
            return value
        }
    }
}

func log(_ message: String) {
    printWithCurrentProgressIndicator(message)
}
