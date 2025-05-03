extends Marker3D

var hitdelay = 0
var ammo = 3
@onready var player = $"../../../../player"

# Called when the node enters the scene tree for the first time.
func _ready():
	$catrpg/shotparticle.get_surface_override_material(0).albedo_texture.current_frame = 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitdelay > 0:
		hitdelay -= delta

func shoot(raycast):
	if hitdelay <= 0:
		if $AnimationPlayer.current_animation != "intro" || !$AnimationPlayer.is_playing():
			hitdelay = 0.75
			ammo -= 1
			if ammo >= 0:
				$catrpg/shotparticle.get_surface_override_material(0).albedo_texture.current_frame = 0
				var pos = raycast.get_collision_point()
				var rocket = load("res://catrocket.tscn").instantiate()
				$catrpg/shootfrom.look_at_from_position($catrpg/shootfrom.global_position, pos)
				rocket.pos = ($catrpg/shootfrom.global_position-pos).normalized()
				rocket.position = $catrpg/shootfrom.global_position
				$"../../../../map".add_child(rocket)
				$AnimationPlayer.play("shoot")
				$audio.play()
				$audio.pitch_scale = randf_range(0.9, 1.1)
				player.screenshake += 0.1

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		if ammo <= 0:
			$AnimationPlayer.play("reload")
			$audio2.play()
			
func reload():
	ammo = 3
