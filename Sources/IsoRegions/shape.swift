import Linalg

public protocol Boundary {
}

public struct Boundary1D: Boundary {
    public let vertex1: Vector1
}

public struct Boundary2D: Boundary {
    public let vertex1: Vector2
    public let vertex2: Vector2
}

public struct Boundary3D: Boundary {
    public let vertex1: Vector3
    public let vertex2: Vector3
    public let vertex3: Vector3
}

public struct Shape<Boundary: IsoRegions.Boundary> {
    public let boundary: [Boundary]
}

public typealias Shape1D = Shape<Boundary1D>
public typealias Shape2D = Shape<Boundary2D>
public typealias Shape3D = Shape<Boundary3D>
