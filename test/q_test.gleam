import gleam/float
import gleeunit
import q
import vec/vec3

pub fn main() -> Nil {
  gleeunit.main()
}

// --- Constants ---

pub fn identity_quaternion_test() {
  let quat = q.identity
  assert quat.x == 0.0
  assert quat.y == 0.0
  assert quat.z == 0.0
  assert quat.w == 1.0
}

// --- Creation ---

pub fn from_axis_angle_test() {
  // 90 degree rotation around Y axis
  let quat = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.5708)

  // Check approximate values (quaternion components for 90° Y rotation)
  assert float.loosely_equals(quat.x, 0.0, 0.0001)
  assert float.loosely_equals(quat.y, 0.7071, 0.01)
  assert float.loosely_equals(quat.z, 0.0, 0.0001)
  assert float.loosely_equals(quat.w, 0.7071, 0.01)
}

pub fn from_axis_angle_identity_test() {
  // Zero rotation should be identity
  let quat = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 0.0)

  assert float.loosely_equals(quat.x, 0.0, 0.0001)
  assert float.loosely_equals(quat.y, 0.0, 0.0001)
  assert float.loosely_equals(quat.z, 0.0, 0.0001)
  assert float.loosely_equals(quat.w, 1.0, 0.0001)
}

pub fn from_euler_test() {
  // 90 degree rotation around Y axis
  let quat = q.from_euler(vec3.Vec3(0.0, 1.5708, 0.0))

  assert float.loosely_equals(quat.x, 0.0, 0.0001)
  assert float.loosely_equals(quat.y, 0.7071, 0.01)
  assert float.loosely_equals(quat.z, 0.0, 0.0001)
  assert float.loosely_equals(quat.w, 0.7071, 0.01)
}

pub fn from_euler_identity_test() {
  let quat = q.from_euler(vec3.Vec3(0.0, 0.0, 0.0))

  assert float.loosely_equals(quat.x, 0.0, 0.0001)
  assert float.loosely_equals(quat.y, 0.0, 0.0001)
  assert float.loosely_equals(quat.z, 0.0, 0.0001)
  assert float.loosely_equals(quat.w, 1.0, 0.0001)
}

pub fn to_euler_test() {
  // Test a simple rotation without gimbal lock issues
  let original_euler = vec3.Vec3(0.3, 0.5, 0.2)
  let quat = q.from_euler(original_euler)
  let euler = q.to_euler(quat)

  // Due to Euler angle ambiguity, we can't always get exact match
  // Instead verify that converting back gives same quaternion
  let quat2 = q.from_euler(euler)

  // Check quaternions are equivalent (may have opposite signs for same rotation)
  let dot = q.dot(quat, quat2)
  assert float.loosely_equals(float.absolute_value(dot), 1.0, 0.01)
}

pub fn from_to_rotation_test() {
  // Rotate from X axis to Z axis
  let from = vec3.Vec3(1.0, 0.0, 0.0)
  let to = vec3.Vec3(0.0, 0.0, 1.0)
  let quat = q.from_to_rotation(from, to)

  // Rotate the from vector and check it matches to
  let rotated = q.rotate(quat, from)

  assert float.loosely_equals(rotated.x, to.x, 0.01)
  assert float.loosely_equals(rotated.y, to.y, 0.01)
  assert float.loosely_equals(rotated.z, to.z, 0.01)
}

pub fn from_to_rotation_parallel_test() {
  // Same direction should be identity
  let from = vec3.Vec3(1.0, 0.0, 0.0)
  let to = vec3.Vec3(1.0, 0.0, 0.0)
  let quat = q.from_to_rotation(from, to)

  assert float.loosely_equals(quat.x, 0.0, 0.0001)
  assert float.loosely_equals(quat.y, 0.0, 0.0001)
  assert float.loosely_equals(quat.z, 0.0, 0.0001)
  assert float.loosely_equals(quat.w, 1.0, 0.0001)
}

pub fn from_to_rotation_opposite_test() {
  // Opposite directions should rotate 180 degrees
  let from = vec3.Vec3(1.0, 0.0, 0.0)
  let to = vec3.Vec3(-1.0, 0.0, 0.0)
  let quat = q.from_to_rotation(from, to)

  // Should be approximately 180 degree rotation
  let angle = q.angle(quat)
  assert float.loosely_equals(angle, 3.1416, 0.01)
}

// --- Operations ---

pub fn multiply_test() {
  // Two 45 degree Y rotations should equal 90 degree Y rotation
  let rot45 = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 0.7854)
  let combined = q.multiply(rot45, rot45)

  let angle = q.angle(combined)
  assert float.loosely_equals(angle, 1.5708, 0.01)
}

pub fn multiply_identity_test() {
  let rot = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.5708)
  let result = q.multiply(rot, q.identity)

  assert float.loosely_equals(result.x, rot.x, 0.0001)
  assert float.loosely_equals(result.y, rot.y, 0.0001)
  assert float.loosely_equals(result.z, rot.z, 0.0001)
  assert float.loosely_equals(result.w, rot.w, 0.0001)
}

pub fn normalize_test() {
  // Create unnormalized quaternion
  let quat = q.Quaternion(1.0, 1.0, 1.0, 1.0)
  let normalized = q.normalize(quat)

  // Check magnitude is 1
  let mag_sq =
    normalized.x
    *. normalized.x
    +. normalized.y
    *. normalized.y
    +. normalized.z
    *. normalized.z
    +. normalized.w
    *. normalized.w

  assert float.loosely_equals(mag_sq, 1.0, 0.0001)
}

pub fn conjugate_test() {
  let quat = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.5708)
  let conj = q.conjugate(quat)

  // Conjugate should negate x, y, z components
  assert float.loosely_equals(conj.x, 0.0 -. quat.x, 0.0001)
  assert float.loosely_equals(conj.y, 0.0 -. quat.y, 0.0001)
  assert float.loosely_equals(conj.z, 0.0 -. quat.z, 0.0001)
  assert float.loosely_equals(conj.w, quat.w, 0.0001)
}

pub fn inverse_test() {
  let quat = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.5708)
  let inv = q.inverse(quat)

  // q * q^-1 should be identity
  let result = q.multiply(quat, inv)

  assert float.loosely_equals(result.x, 0.0, 0.01)
  assert float.loosely_equals(result.y, 0.0, 0.01)
  assert float.loosely_equals(result.z, 0.0, 0.01)
  assert float.loosely_equals(result.w, 1.0, 0.01)
}

pub fn dot_test() {
  let q1 = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 0.5)
  let q2 = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 0.5)

  let dot_val = q.dot(q1, q2)

  // Identical quaternions should have dot product of 1
  assert float.loosely_equals(dot_val, 1.0, 0.01)
}

pub fn dot_orthogonal_test() {
  let q1 = q.from_axis_angle(vec3.Vec3(1.0, 0.0, 0.0), 1.5708)
  let q2 = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.5708)

  let dot_val = q.dot(q1, q2)

  // Orthogonal rotations should have low dot product
  assert dot_val <. 1.0
  assert dot_val >. -1.0
}

// --- Interpolation ---

pub fn slerp_midpoint_test() {
  let start = q.identity
  let end = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 3.1416)

  let mid = q.spherical_linear_interpolation(from: start, to: end, t: 0.5)

  // Midpoint should be approximately 90 degrees
  let angle = q.angle(mid)
  assert float.loosely_equals(angle, 1.5708, 0.1)
}

pub fn slerp_endpoints_test() {
  let start = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 0.5)
  let end = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 2.0)

  // t=0 should return start
  let result_start =
    q.spherical_linear_interpolation(from: start, to: end, t: 0.0)
  assert float.loosely_equals(result_start.x, start.x, 0.01)
  assert float.loosely_equals(result_start.y, start.y, 0.01)
  assert float.loosely_equals(result_start.z, start.z, 0.01)
  assert float.loosely_equals(result_start.w, start.w, 0.01)

  // t=1 should return end
  let result_end =
    q.spherical_linear_interpolation(from: start, to: end, t: 1.0)
  assert float.loosely_equals(result_end.x, end.x, 0.01)
  assert float.loosely_equals(result_end.y, end.y, 0.01)
  assert float.loosely_equals(result_end.z, end.z, 0.01)
  assert float.loosely_equals(result_end.w, end.w, 0.01)
}

pub fn lerp_test() {
  let start = q.identity
  let end = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.5708)

  let mid = q.linear_interpolation(from: start, to: end, t: 0.5)

  // Result should be normalized
  let mag_sq =
    mid.x *. mid.x +. mid.y *. mid.y +. mid.z *. mid.z +. mid.w *. mid.w
  assert float.loosely_equals(mag_sq, 1.0, 0.01)
}

// --- Vector Rotation ---

pub fn rotate_identity_test() {
  let v = vec3.Vec3(1.0, 0.0, 0.0)
  let rotated = q.rotate(q.identity, v)

  assert float.loosely_equals(rotated.x, v.x, 0.0001)
  assert float.loosely_equals(rotated.y, v.y, 0.0001)
  assert float.loosely_equals(rotated.z, v.z, 0.0001)
}

pub fn rotate_90_degrees_y_test() {
  // Rotate X axis 90 degrees around Y should give -Z axis
  let quat = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.5708)
  let v = vec3.Vec3(1.0, 0.0, 0.0)
  let rotated = q.rotate(quat, v)

  assert float.loosely_equals(rotated.x, 0.0, 0.01)
  assert float.loosely_equals(rotated.y, 0.0, 0.01)
  assert float.loosely_equals(rotated.z, -1.0, 0.01)
}

pub fn rotate_90_degrees_x_test() {
  // Rotate Y axis 90 degrees around X should give Z axis
  let quat = q.from_axis_angle(vec3.Vec3(1.0, 0.0, 0.0), 1.5708)
  let v = vec3.Vec3(0.0, 1.0, 0.0)
  let rotated = q.rotate(quat, v)

  assert float.loosely_equals(rotated.x, 0.0, 0.01)
  assert float.loosely_equals(rotated.y, 0.0, 0.01)
  assert float.loosely_equals(rotated.z, 1.0, 0.01)
}

pub fn rotate_180_degrees_test() {
  // 180 degree rotation should negate the vector
  let quat = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 3.1416)
  let v = vec3.Vec3(1.0, 0.0, 0.0)
  let rotated = q.rotate(quat, v)

  assert float.loosely_equals(rotated.x, -1.0, 0.01)
  assert float.loosely_equals(rotated.y, 0.0, 0.01)
  assert float.loosely_equals(rotated.z, 0.0, 0.01)
}

pub fn rotate_preserves_length_test() {
  let quat = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.2)
  let v = vec3.Vec3(3.0, 4.0, 5.0)
  let rotated = q.rotate(quat, v)

  // Calculate lengths
  let orig_len_sq = v.x *. v.x +. v.y *. v.y +. v.z *. v.z
  let rot_len_sq =
    rotated.x *. rotated.x +. rotated.y *. rotated.y +. rotated.z *. rotated.z

  assert float.loosely_equals(orig_len_sq, rot_len_sq, 0.01)
}

// --- Queries ---

pub fn angle_identity_test() {
  let angle = q.angle(q.identity)
  assert float.loosely_equals(angle, 0.0, 0.0001)
}

pub fn angle_90_degrees_test() {
  let quat = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.5708)
  let angle = q.angle(quat)
  assert float.loosely_equals(angle, 1.5708, 0.01)
}

pub fn angle_180_degrees_test() {
  let quat = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 3.1416)
  let angle = q.angle(quat)
  assert float.loosely_equals(angle, 3.1416, 0.01)
}

pub fn axis_identity_test() {
  let result = q.axis(q.identity)

  // Identity has no well-defined axis
  assert result == Error(Nil)
}

pub fn axis_y_rotation_test() {
  let quat = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.5708)
  let assert Ok(axis) = q.axis(quat)

  assert float.loosely_equals(axis.x, 0.0, 0.01)
  assert float.loosely_equals(axis.y, 1.0, 0.01)
  assert float.loosely_equals(axis.z, 0.0, 0.01)
}

pub fn axis_x_rotation_test() {
  let quat = q.from_axis_angle(vec3.Vec3(1.0, 0.0, 0.0), 2.0)
  let assert Ok(axis) = q.axis(quat)

  assert float.loosely_equals(axis.x, 1.0, 0.01)
  assert float.loosely_equals(axis.y, 0.0, 0.01)
  assert float.loosely_equals(axis.z, 0.0, 0.01)
}
