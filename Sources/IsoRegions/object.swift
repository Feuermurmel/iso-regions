public struct Boundary2D {
    let vertex1: Vector2
    let vertex2: Vector2
}

public struct Object2D {
    let boundary: [Boundary2D]
}

public struct Boundary3D {
    let vertex1: Vector3
    let vertex2: Vector3
    let vertex3: Vector3
}

public struct Object3D {
    let boundary: [Boundary3D]
}

