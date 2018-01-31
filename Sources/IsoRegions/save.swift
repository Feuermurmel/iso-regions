import Foundation

public protocol Saveable {
    func save(toFile: String) throws
}

struct LinesProducerSaveable: Saveable {
    let linesProducer: ((String) -> Void) -> Void
    
    func save(toFile: String) throws {
        try write(
            content: join(lines: gatherElements(fromProducer: linesProducer)),
            to: URL(fileURLWithPath: toFile))
    }
}

fileprivate func directoryExists(at url: URL) -> Bool {
    return (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
}

func write(content: String, to: URL) throws {
    let dirPath = to.deletingLastPathComponent()
    
    if !directoryExists(at: dirPath) {
        try FileManager.default.createDirectory(at: dirPath, withIntermediateDirectories: false)
    }
    
    try content.write(to: to, atomically: true, encoding: String.Encoding.utf8)
}

func gatherElements<T>(fromProducer: ((T) -> Void) -> Void) -> [T] {
    var array: [T] = []
    
    fromProducer({ element in array.append(element) })
    
    return array
}

func join(lines: [String]) -> String {
    var string = ""
    
    for i in lines {
        string += i + "\n"
    }
    
    return string
}

public extension Object2D {
    func toSaveable(unitSizeInMetres: Double = 1e-3, lineThicknessInUnits: Double = 0.2, storePhysicalSize: Bool = true) -> Saveable {
        precondition(boundary.count > 0, "Empty object cannot be saved.")
        
        return LinesProducerSaveable { emitLine in
            let vertices = self.boundary.flatMap({ return [$0.vertex1, $0.vertex2] })
            let bounds = (
                x: (min: vertices.map({ $0.x }).min()!, max: vertices.map({ $0.x }).max()!),
                y: (min: vertices.map({ $0.y }).min()!, max: vertices.map({ $0.y }).max()!))
            let size = (x: bounds.x.max - bounds.x.min, y: bounds.y.max - bounds.y.min)
            let width = size.x * unitSizeInMetres * 1000
            let height = size.y * unitSizeInMetres * 1000
            
            let dimensions: String
            
            if storePhysicalSize {
                dimensions = " width=\"\(width)mm\" height=\"\(height)mm\""
            } else {
                dimensions = ""
            }
            
            let viewBox = " viewBox=\"\(bounds.x.min) \(bounds.y.min) \(size.x) \(size.y)\""
            let xmlns = " xmlns=\"http://www.w3.org/2000/svg\""
            
            emitLine("<svg\(dimensions)\(viewBox)\(xmlns)>")
            emitLine("    <g stroke-width=\"\(lineThicknessInUnits)\" stroke=\"black\">")
            
            for i in self.boundary {
                emitLine("        <line x1=\"\(i.vertex1.x)\" y1=\"\(i.vertex1.y)\" x2=\"\(i.vertex2.x)\" y2=\"\(i.vertex2.y)\" />")
            }
            
            emitLine("    </g>")
            emitLine("</svg>")
        }
    }
}

public extension Object3D {
    func toSaveable() -> Saveable {
        return LinesProducerSaveable { emitLine in
            emitLine("solid default")
            
            for i in self.boundary {
                emitLine("    facet normal \(0.0) \(0.0) \(0.0)")
                emitLine("        outer loop")
                
                for j in [i.vertex1, i.vertex2, i.vertex3] {
                    emitLine("            vertex \(j.x) \(j.y) \(j.z)")
                }
                
                emitLine("        endloop")
                emitLine("    endfacet")
            }
            
            emitLine("endsolid default")
        }
    }
}
