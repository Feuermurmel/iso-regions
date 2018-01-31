import Foundation

public extension Array {
    func all(where where_: (Element) -> Bool) -> Bool {
        return !contains(where: { !where_($0) })
    }
}
