extends Node3D

var mat = Material
var hidegross = false
var head = "res://objects/defaultobject.tscn"
var vel = Vector3.ZERO
var squished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if hidegross: $RigidBody3D/mesh/grosstuff.hide()
	
	var headrigid = load(head).instantiate()
	$RigidBody3D2.add_child(headrigid)
	
	if squished:
		$RigidBody3D/mesh.position = Vector3(0, 0.3, -0.8)
		$RigidBody3D/mesh.rotation = Vector3(90, 0, 0)
		$RigidBody3D/mesh.scale = Vector3(1, 1, 0.1)
		$RigidBody3D/CollisionShape3D.position = Vector3(0, 0.3, -0.8)
		$RigidBody3D/CollisionShape3D.rotation = Vector3(90, 0, 0)
		$RigidBody3D/CollisionShape3D.scale = Vector3(1, 1, 0.1)
		headrigid.position.y += 0.5
		headrigid.rotation = Vector3(90, 0, 0)
		headrigid.scale = Vector3(1, 1, 0.1)
		$RigidBody3D2/CollisionShape3D.rotation = Vector3(90, 0, 0)
		$RigidBody3D2/CollisionShape3D.scale = Vector3(1, 1, 0.1)
		$RigidBody3D.gravity_scale = 0.2
		$RigidBody3D2.gravity_scale = 0.2
		print("tf goin on")
	
	$RigidBody3D.linear_velocity = vel
	$RigidBody3D2.linear_velocity = vel
	
	if is_in_group("playersoftbody"):
		$Skeleton3D.physical_bones_start_simulation()
		$Skeleton3D/mesh.set_surface_override_material(0, mat)
	elif is_in_group("playerrigidbody"):
		$RigidBody3D/mesh.set_surface_override_material(0, mat)
