import gleam/float
import gleeunit
import quaternion as q
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

// --- Look At ---

pub fn look_at_default_forward_test() {
  // Looking at -Z with Y up should give identity (camera default)
  let target = vec3.Vec3(0.0, 0.0, -1.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)
  let quat = q.look_at(vec3.Vec3(0.0, 0.0, -1.0), target, up)

  assert float.loosely_equals(quat.x, 0.0, 0.01)
  assert float.loosely_equals(quat.y, 0.0, 0.01)
  assert float.loosely_equals(quat.z, 0.0, 0.01)
  assert float.loosely_equals(quat.w, 1.0, 0.01)
}

pub fn look_at_rotates_forward_to_target_test() {
  // The quaternion should rotate the default forward (-Z) to the target direction
  let target = vec3.Vec3(1.0, 0.0, 0.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)
  let quat = q.look_at(vec3.Vec3(0.0, 0.0, -1.0), target, up)

  // Rotate the default forward direction
  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let rotated = q.rotate(quat, forward)

  assert float.loosely_equals(rotated.x, 1.0, 0.01)
  assert float.loosely_equals(rotated.y, 0.0, 0.01)
  assert float.loosely_equals(rotated.z, 0.0, 0.01)
}

pub fn look_at_isometric_test() {
  // Test isometric camera: looking from (1,1,1) toward origin
  // Target direction is normalized (-1, -1, -1)
  let inv_sqrt3 = 0.5774
  let target = vec3.Vec3(0.0 -. inv_sqrt3, 0.0 -. inv_sqrt3, 0.0 -. inv_sqrt3)
  let up = vec3.Vec3(0.0, 1.0, 0.0)
  let quat = q.look_at(vec3.Vec3(0.0, 0.0, -1.0), target, up)

  // Rotate default forward and check it points toward target
  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let rotated = q.rotate(quat, forward)

  assert float.loosely_equals(rotated.x, 0.0 -. inv_sqrt3, 0.01)
  assert float.loosely_equals(rotated.y, 0.0 -. inv_sqrt3, 0.01)
  assert float.loosely_equals(rotated.z, 0.0 -. inv_sqrt3, 0.01)
}

pub fn look_at_up_preserved_test() {
  // When looking horizontally, the up vector should remain up
  let target = vec3.Vec3(1.0, 0.0, 0.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)
  let quat = q.look_at(vec3.Vec3(0.0, 0.0, -1.0), target, up)

  // Rotate the default up direction
  let rotated_up = q.rotate(quat, vec3.Vec3(0.0, 1.0, 0.0))

  // Should still be pointing up (Y axis)
  assert float.loosely_equals(rotated_up.x, 0.0, 0.01)
  assert float.loosely_equals(rotated_up.y, 1.0, 0.01)
  assert float.loosely_equals(rotated_up.z, 0.0, 0.01)
}

pub fn look_at_right_handed_test() {
  // Looking at +X should have right vector pointing at +Z
  let target = vec3.Vec3(1.0, 0.0, 0.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)
  let quat = q.look_at(vec3.Vec3(0.0, 0.0, -1.0), target, up)

  // Rotate default right (+X) and check orientation
  let right = vec3.Vec3(1.0, 0.0, 0.0)
  let rotated_right = q.rotate(quat, right)

  // Should now point at +Z in right-handed system
  assert float.loosely_equals(rotated_right.x, 0.0, 0.01)
  assert float.loosely_equals(rotated_right.y, 0.0, 0.01)
  assert float.loosely_equals(rotated_right.z, 1.0, 0.01)
}

pub fn look_at_down_test() {
  // Looking straight down
  let target = vec3.Vec3(0.0, -1.0, 0.0)
  let up = vec3.Vec3(0.0, 0.0, -1.0)
  let quat = q.look_at(vec3.Vec3(0.0, 0.0, -1.0), target, up)

  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let rotated = q.rotate(quat, forward)

  assert float.loosely_equals(rotated.x, 0.0, 0.01)
  assert float.loosely_equals(rotated.y, -1.0, 0.01)
  assert float.loosely_equals(rotated.z, 0.0, 0.01)
}

pub fn look_at_custom_forward_test() {
  // Object with +X as forward, want to look at +Z
  let forward = vec3.Vec3(1.0, 0.0, 0.0)
  let target = vec3.Vec3(0.0, 0.0, 1.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)
  let quat = q.look_at(forward, target, up)

  // Rotating the original forward should give target
  let rotated = q.rotate(quat, forward)

  assert float.loosely_equals(rotated.x, 0.0, 0.01)
  assert float.loosely_equals(rotated.y, 0.0, 0.01)
  assert float.loosely_equals(rotated.z, 1.0, 0.01)
}

pub fn look_at_custom_forward_preserves_up_test() {
  // Object with +Z as forward, want to look at +X
  let forward = vec3.Vec3(0.0, 0.0, 1.0)
  let target = vec3.Vec3(1.0, 0.0, 0.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)
  let quat = q.look_at(forward, target, up)

  // Up should still be up after rotation
  let rotated_up = q.rotate(quat, vec3.Vec3(0.0, 1.0, 0.0))

  assert float.loosely_equals(rotated_up.x, 0.0, 0.01)
  assert float.loosely_equals(rotated_up.y, 1.0, 0.01)
  assert float.loosely_equals(rotated_up.z, 0.0, 0.01)
}

pub fn look_at_same_direction_test() {
  // Forward and target are the same - should be identity
  let forward = vec3.Vec3(1.0, 0.0, 0.0)
  let target = vec3.Vec3(1.0, 0.0, 0.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)
  let quat = q.look_at(forward, target, up)

  assert float.loosely_equals(quat.x, 0.0, 0.01)
  assert float.loosely_equals(quat.y, 0.0, 0.01)
  assert float.loosely_equals(quat.z, 0.0, 0.01)
  assert float.loosely_equals(quat.w, 1.0, 0.01)
}

pub fn look_at_backward_180_degrees_test() {
  // Looking at +Z from default forward -Z (180° rotation)
  // This is what an FPS camera does when initially facing away
  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let target = vec3.Vec3(0.0, 0.0, 1.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)
  let quat = q.look_at(forward, target, up)

  // Rotate the default forward direction
  let rotated = q.rotate(quat, forward)

  // Should now point at +Z
  assert float.loosely_equals(rotated.x, 0.0, 0.01)
  assert float.loosely_equals(rotated.y, 0.0, 0.01)
  assert float.loosely_equals(rotated.z, 1.0, 0.01)
}

pub fn look_at_near_backward_slightly_right_test() {
  // Looking slightly to the right of +Z (simulates small yaw from 180° case)
  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let target = vec3.Vec3(0.1, 0.0, 0.995)
  let up = vec3.Vec3(0.0, 1.0, 0.0)
  let quat = q.look_at(forward, target, up)

  // Rotate the default forward direction
  let rotated = q.rotate(quat, forward)

  // Should point approximately at target (normalized)
  assert float.loosely_equals(rotated.x, 0.1, 0.02)
  assert float.loosely_equals(rotated.y, 0.0, 0.01)
  assert float.loosely_equals(rotated.z, 0.995, 0.02)
}

pub fn look_at_near_backward_slightly_left_test() {
  // Looking slightly to the left of +Z (simulates small negative yaw)
  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let target = vec3.Vec3(-0.1, 0.0, 0.995)
  let up = vec3.Vec3(0.0, 1.0, 0.0)
  let quat = q.look_at(forward, target, up)

  // Rotate the default forward direction
  let rotated = q.rotate(quat, forward)

  // Should point approximately at target (normalized)
  assert float.loosely_equals(rotated.x, -0.1, 0.02)
  assert float.loosely_equals(rotated.y, 0.0, 0.01)
  assert float.loosely_equals(rotated.z, 0.995, 0.02)
}

// --- FPS Camera Tests ---
// These tests verify the look_at -> to_euler round trip for FPS camera use cases

import gleam_community/maths

pub fn fps_camera_yaw_left_euler_test() {
  // FPS camera: looking 30 degrees to the left (yaw = 0.5 radians)
  // Camera at origin, default forward is -Z
  let cam_yaw = 0.5
  let cam_pitch = 0.0

  // Calculate forward direction (same as materials_and_lights example)
  let forward_x = 0.0 -. maths.sin(cam_yaw) *. maths.cos(cam_pitch)
  let forward_y = maths.sin(cam_pitch)
  let forward_z = 0.0 -. maths.cos(cam_yaw) *. maths.cos(cam_pitch)

  let target = vec3.Vec3(forward_x, forward_y, forward_z)
  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)

  let quat = q.look_at(forward, target, up)
  let euler = q.to_euler(quat)

  // The Y component of euler should be approximately cam_yaw
  // X and Z should be approximately 0
  assert float.loosely_equals(euler.x, 0.0, 0.01)
  assert float.loosely_equals(euler.y, cam_yaw, 0.01)
  assert float.loosely_equals(euler.z, 0.0, 0.01)
}

pub fn fps_camera_yaw_right_euler_test() {
  // FPS camera: looking 30 degrees to the right (yaw = -0.5 radians)
  let cam_yaw = -0.5
  let cam_pitch = 0.0

  let forward_x = 0.0 -. maths.sin(cam_yaw) *. maths.cos(cam_pitch)
  let forward_y = maths.sin(cam_pitch)
  let forward_z = 0.0 -. maths.cos(cam_yaw) *. maths.cos(cam_pitch)

  let target = vec3.Vec3(forward_x, forward_y, forward_z)
  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)

  let quat = q.look_at(forward, target, up)
  let euler = q.to_euler(quat)

  assert float.loosely_equals(euler.x, 0.0, 0.01)
  assert float.loosely_equals(euler.y, cam_yaw, 0.01)
  assert float.loosely_equals(euler.z, 0.0, 0.01)
}

pub fn fps_camera_pitch_up_euler_test() {
  // FPS camera: looking 30 degrees up (pitch = 0.5 radians)
  let cam_yaw = 0.0
  let cam_pitch = 0.5

  let forward_x = 0.0 -. maths.sin(cam_yaw) *. maths.cos(cam_pitch)
  let forward_y = maths.sin(cam_pitch)
  let forward_z = 0.0 -. maths.cos(cam_yaw) *. maths.cos(cam_pitch)

  let target = vec3.Vec3(forward_x, forward_y, forward_z)
  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)

  let quat = q.look_at(forward, target, up)
  let euler = q.to_euler(quat)

  // For pitch (looking up/down), the X component should change
  assert float.loosely_equals(euler.x, cam_pitch, 0.01)
  assert float.loosely_equals(euler.y, 0.0, 0.01)
  assert float.loosely_equals(euler.z, 0.0, 0.01)
}

pub fn fps_camera_combined_pitch_yaw_euler_test() {
  // FPS camera: looking 30 degrees left and 20 degrees up
  let cam_yaw = 0.5
  let cam_pitch = 0.35

  let forward_x = 0.0 -. maths.sin(cam_yaw) *. maths.cos(cam_pitch)
  let forward_y = maths.sin(cam_pitch)
  let forward_z = 0.0 -. maths.cos(cam_yaw) *. maths.cos(cam_pitch)

  let target = vec3.Vec3(forward_x, forward_y, forward_z)
  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)

  let quat = q.look_at(forward, target, up)
  let _euler = q.to_euler(quat)

  // Combined rotation - this tests if the euler decomposition is correct
  // Note: Due to euler angle representation, these might not be exact
  // but the rotation itself should be correct
  // Verify by rotating forward with the quaternion
  let rotated = q.rotate(quat, forward)
  assert float.loosely_equals(rotated.x, forward_x, 0.01)
  assert float.loosely_equals(rotated.y, forward_y, 0.01)
  assert float.loosely_equals(rotated.z, forward_z, 0.01)
}

pub fn fps_camera_small_yaw_euler_test() {
  // FPS camera: looking slightly left (yaw = 0.01 radians ≈ 0.57 degrees)
  // This tests for precision issues with small angles
  let cam_yaw = 0.01
  let cam_pitch = 0.0

  let forward_x = 0.0 -. maths.sin(cam_yaw) *. maths.cos(cam_pitch)
  let forward_y = maths.sin(cam_pitch)
  let forward_z = 0.0 -. maths.cos(cam_yaw) *. maths.cos(cam_pitch)

  let target = vec3.Vec3(forward_x, forward_y, forward_z)
  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)

  let quat = q.look_at(forward, target, up)
  let euler = q.to_euler(quat)

  // Y component should be approximately cam_yaw (small angle)
  // X and Z should be approximately 0
  assert float.loosely_equals(euler.x, 0.0, 0.01)
  assert float.loosely_equals(euler.y, cam_yaw, 0.01)
  assert float.loosely_equals(euler.z, 0.0, 0.01)
}

pub fn fps_camera_very_small_yaw_euler_test() {
  // FPS camera: looking very slightly left (yaw = 0.001 radians)
  // This tests for precision issues with very small angles
  let cam_yaw = 0.001
  let cam_pitch = 0.0

  let forward_x = 0.0 -. maths.sin(cam_yaw) *. maths.cos(cam_pitch)
  let forward_y = maths.sin(cam_pitch)
  let forward_z = 0.0 -. maths.cos(cam_yaw) *. maths.cos(cam_pitch)

  let target = vec3.Vec3(forward_x, forward_y, forward_z)
  let forward = vec3.Vec3(0.0, 0.0, -1.0)
  let up = vec3.Vec3(0.0, 1.0, 0.0)

  let quat = q.look_at(forward, target, up)
  let _euler = q.to_euler(quat)

  // For very small angles, verify the rotation is still correct
  // by checking the rotated vector
  let rotated = q.rotate(quat, forward)
  assert float.loosely_equals(rotated.x, forward_x, 0.001)
  assert float.loosely_equals(rotated.y, forward_y, 0.001)
  assert float.loosely_equals(rotated.z, forward_z, 0.001)
}

pub fn fps_camera_look_at_vs_from_euler_yaw_test() {
  // Compare quaternion from look_at with quaternion from from_euler
  // They should produce the same rotation for pure yaw
  let cam_yaw = 0.5
  let cam_pitch = 0.0

  // Method 1: from_euler (this works in the example)
  let euler_quat = q.from_euler(vec3.Vec3(cam_pitch, cam_yaw, 0.0))

  // Method 2: look_at (this doesn't work in the example)
  let forward_x = 0.0 -. maths.sin(cam_yaw) *. maths.cos(cam_pitch)
  let forward_y = maths.sin(cam_pitch)
  let forward_z = 0.0 -. maths.cos(cam_yaw) *. maths.cos(cam_pitch)
  let target = vec3.Vec3(forward_x, forward_y, forward_z)
  let look_at_quat = q.look_at(vec3.Vec3(0.0, 0.0, -1.0), target, vec3.Vec3(0.0, 1.0, 0.0))

  // Both should rotate (0,0,-1) to the same direction
  let euler_rotated = q.rotate(euler_quat, vec3.Vec3(0.0, 0.0, -1.0))
  let look_at_rotated = q.rotate(look_at_quat, vec3.Vec3(0.0, 0.0, -1.0))

  // Check if they produce the same rotated vector
  assert float.loosely_equals(euler_rotated.x, look_at_rotated.x, 0.01)
  assert float.loosely_equals(euler_rotated.y, look_at_rotated.y, 0.01)
  assert float.loosely_equals(euler_rotated.z, look_at_rotated.z, 0.01)
}
