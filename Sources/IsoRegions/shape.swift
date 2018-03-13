import Linalg

public struct Boundary2D {
    public let vertex1: Vector2
    public let vertex2: Vector2
}

public struct Shape2D {
    public let boundary: [Boundary2D]
}

public struct Boundary3D {
    public let vertex1: Vector3
    public let vertex2: Vector3
    public let vertex3: Vector3
}

public struct Shape3D {
    public let boundary: [Boundary3D]
}
