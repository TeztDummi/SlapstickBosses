extends CharacterBody3D

const floorfriction = 15
const slidefriction = 0.5
const airfriction = 1.5
var SPEED = 2 #in loadmap
var SLIDEMULT = 1.5
var JUMP_VELOCITY = 12 #in loadmap
@onready var camera = $camera

@onready var healthbarpos = $"../canvas/hud/healthbar".position

var health = 100
var shockwavedmgdelay = 0
var hiteffect = 0
var dead = false
var doajump = 1
var candoublejump = false
var doublejump = 1
var djdelay = 0
var djseconds = 3
var screenshake = 0
var scroll = 0
var camlock = false
var coyote = 0
var slide = false
var motionblur = 0
var spaceenergy = 0
var cancrouch = false
var slidefallpos = 0
var falldamagemult = 0
var falloff = true
var emoting = false
var candash = false
var dashdelay = 0
var dashseconds = 1
var walljumpvel = Vector3.ZERO
var inwater = false
var jetpack = false
var physicsscale = 1
var surfboard = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$anim.play("idle")

func _process(delta):
	if coyote > 0: coyote -= delta
	
	
	if motionblur > 0: motionblur -= delta*20
	else: motionblur = 0
	if motionblur > 1: motionblur = 1
	
	var totalvel = sqrt(pow(velocity.x, 2)+pow(velocity.y, 2)+pow(velocity.z, 2))
	
	if !dead && emoting && ($anim.current_animation != "getfucked" || !$anim.is_playing() || !is_on_floor() || totalvel >= 2):
		emoting = false
		camera.current = true
	if !$"../tppivot/tppivot2/tpcam".current:
		emoting = false
	
	if motionblur < 0.5: $camera/motionblur.modulate = Color(1, 1, 1, motionblur/2)
	else: $camera/motionblur.modulate = Color(1, 1, 1, 0.5)
		
	if candoublejump:
		if djdelay > 0: djdelay -= delta/djseconds
		else:
			if djdelay != -10:
				$"../sfx".stream = load("res://audio/doublejumpcharged.mp3")
				$"../sfx".play()
				djdelay = -10
		$"../canvas/hud/doublejump".show()
		$"../canvas/hud/dash".position.y = 563.0-78
		
		$"../canvas/hud/doublejump".value = (1-djdelay)
	else:
		pass
		$"../canvas/hud/doublejump".hide()
		$"../canvas/hud/dash".position.y = 563.0
	
	if position.y <= -20 && falloff:
		hurt(100, "fall")
		
	#if !$"../map/WorldEnvironment".environment.adjustment_enabled:
		#$"../map/WorldEnvironment".environment.adjustment_enabled = true

	if hiteffect > 0:
		hiteffect = hiteffect*0.99-(delta*0.1)
			
		#$"../map/WorldEnvironment".environment.adjustment_brightness = 1+(hiteffect*1)
		#$"../map/WorldEnvironment".environment.adjustment_contrast = 1+(hiteffect*7)
		#$"../map/WorldEnvironment".environment.adjustment_saturation = 1-(hiteffect*0.99)
		$camera/damage.material.set_shader_parameter('amount', hiteffect)
		
		$"../canvas/hud/healthbar".position.x = healthbarpos.x+randf_range(-1, 1)*hiteffect*50
		$"../canvas/hud/healthbar".position.y = healthbarpos.y+randf_range(-1, 1)*hiteffect*50
		
	else:
		hiteffect = 0
		#$"../map/WorldEnvironment".environment.adjustment_brightness = 1
		#$"../map/WorldEnvironment".environment.adjustment_contrast = 1
		#$"../map/WorldEnvironment".environment.adjustment_saturation = 1
		
		$"../canvas/hud/healthbar".position = healthbarpos
		
	if !$camera.current && !$"../canvas/hud/talk".visible && !$"../canvas/hud/pause".visible && !get_viewport().get_camera_3d().has_meta("showhud"):
		$camera/gun.hide()
		$Armature.hide()
		$light.hide()
		if !$"../tppivot/tppivot2/tpcam".current && !$"../canvas/hud/transitionin".is_playing():
			$"../canvas/hud".hide()
		if $"../canvas/hud/transitionin".is_playing():
			$"../canvas/hud".show()
	else:
		$camera/gun.show()
		$Armature.show()
		$light.show()
		$"../canvas/hud".show()
	if get_viewport().get_camera_3d().has_meta("freecam"):
		$Armature.show()
		$camera/gun.hide()
		$"../canvas/hud".hide()
	if (emoting && !dead):
		$Armature.show()
		$camera/gun.hide()
		$"../canvas/hud".show()
		
		
	var windspeed = totalvel
	
	if inwater:
		windspeed *= 3
		$bubbles.emitting = totalvel > 2
		$bubbles.show()
		gravity = ProjectSettings.get_setting("physics/3d/default_gravity")*0.35
		$"../".setwater(true)
		inwater = false
	else:
		$bubbles.emitting = false
		gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
		$"../".setwater(false)
		$bubbles.hide()
	
	if dead || !camera.current: windspeed = 0
	var windpitch = clampf(windspeed/SPEED/6, 0.65, 3)
	var windvol = -80+clampf(windspeed/SPEED*6, 0, 80)
	$wind.pitch_scale = lerpf($wind.pitch_scale, windpitch, delta*5)
	$wind.volume_db = lerpf($wind.volume_db, windvol, delta*5)
	
	var linespeed = totalvel
	linespeed -= 5
	if dead || !camera.current: linespeed = 0
	
	var actionrad = 1.2+((1-(linespeed/50))*0.8)
	actionrad = clampf(actionrad, 1.2, 2)
	
	var prev = $camera/actionlines.material.get_shader_parameter("Radius")
	$camera/actionlines.material.set_shader_parameter("Radius", lerpf(prev, actionrad, delta*2))
		
	if !dead && $camera.current:
		var collider = $camera/raycast.get_collider()
		if collider != null:
			if collider.is_in_group("painting"):
				collider.hover = true
			if collider.is_in_group("clickable"):
				collider.get_parent().hover = true
			if collider.is_in_group("pipewheel"):
				collider.get_parent().hover = true
			if collider.is_in_group("poobottle"):
				collider.get_parent().hover = true
			if collider.is_in_group("acrylicpaint"):
				collider.get_parent().hover = true
			if collider.is_in_group("link"):
				collider.get_parent().hover = true
			if collider.is_in_group("copycredits"):
				collider.get_parent().hover = true
			if collider.is_in_group("item"):
				collider.get_parent().hover = true
			if collider.is_in_group("difficultybutton"):
				if collider.name == "easy": collider.get_parent().get_parent().get_parent().hovereasy = true
				if collider.name == "medium": collider.get_parent().get_parent().get_parent().hovermedium = true
				if collider.name == "hard": collider.get_parent().get_parent().get_parent().hoverhard = true
			if collider.is_in_group("dummidecal"):
				if sqrt(pow(position.x-collider.global_position.x, 2) + pow(position.z-collider.global_position.z, 2)) < 10:
					collider.get_parent().doit()
		var shootcollider = $camera/shootraycast.get_collider()
		if shootcollider != null:
			if shootcollider.is_in_group("sunlook"):
				shootcollider.get_parent().get_parent().suntimer = true
		if Input.is_action_pressed("click"):
			if $camera/shootraycast.get_collider() != null: 
				if $camera/gun.get_child(scroll) != null:
					if !$camera/gun.get_child(scroll).has_meta("held"):
						$camera/gun.get_child(scroll).shoot($camera/shootraycast) 
					
	if screenshake > 0.0001:
		screenshake = lerpf(screenshake, 0, delta*4)
		$camera.h_offset = randf_range(-1, 1)*screenshake
		$camera.v_offset = randf_range(-1, 1)*screenshake
		$camera/gun.position = Vector3($camera.h_offset*0.9, $camera.v_offset*0.9, 0)
	else:
		screenshake = 0
		$camera.h_offset = 0
		$camera.v_offset = 0
		$camera/gun.position = Vector3(0, 0, 0)
	$camera/gun.position.z = (-(1.0/$camera.fov-1.0/75)*45)+abs((1.0/$camera.fov-1.0/75)*4)
		
	if Input.is_action_just_pressed("scrollup"):
		scroll += 1
	if Input.is_action_just_pressed("scrolldown"): scroll -= 1
	if $camera/gun.get_children().size() >= 2:
		if scroll < 0: scroll = 1
		if scroll > 1: scroll = 0
	else: scroll = 0
	if scroll == 0:
		if $camera/gun.get_children().size() >= 1:
			$camera/gun.get_child(0).process_mode = Node.PROCESS_MODE_PAUSABLE
			$camera/gun.get_child(0).show()
		if $camera/gun.get_children().size() >= 2:
			$camera/gun.get_child(1).process_mode = Node.PROCESS_MODE_DISABLED
			$camera/gun.get_child(1).hide()
	if scroll == 1:
		if $camera/gun.get_children().size() >= 2:
			$camera/gun.get_child(1).process_mode = Node.PROCESS_MODE_PAUSABLE
			$camera/gun.get_child(1).show()
		if $camera/gun.get_children().size() >= 1:
			$camera/gun.get_child(0).process_mode = Node.PROCESS_MODE_DISABLED
			$camera/gun.get_child(0).hide()
	var look_dir = Input.get_vector("lookleft", "lookright", "lookup", "lookdown")
	rotatecam(look_dir.x*1000*delta, look_dir.y*1000*delta)
	
	var extra = slidefallpos-position.y
	if extra > 10: extra = 10
	
	if !dead:
		if slide && cancrouch:
			screenshake += (extra)*delta*0.01
			if sqrt(pow(velocity.x, 2) + pow(velocity.z, 2)) >= 25:
				$camera/slidething.transparency = lerpf($camera/slidething.transparency, 0.95, delta*3)
			else:
				$camera/slidething.transparency = lerpf($camera/slidething.transparency, clampf(1.1-(extra)*delta*5, 0.75, 1), delta*10)
			if $camera/slidething.transparency < 0: $camera/slidething.transparency = 0
			$camera/slidething.get_surface_override_material(0).uv2_offset.x -= (extra)*delta*0.1+delta*0.5
			$camera/slidething.get_surface_override_material(0).uv2_offset.z -= (extra)*delta*0.1+delta*0.5
		else:
			$camera/slidething.transparency = lerpf($camera/slidething.transparency, 1, delta*5)
		
		$camera/slidething.get_surface_override_material(0).uv2_offset.x -= (extra)*delta*0.1+delta*0.2
		$camera/slidething.get_surface_override_material(0).uv2_offset.z -= (extra)*delta*0.1+delta*0.2
		$camera/slidething.global_rotation.x = 0
		$camera/slidething.rotation.y = 0
		$camera/slidething.rotation.z = -PI/2
		#$slidepivot.global_rotation.y = atan2(velocity.x, velocity.z)
		$camera/slidething.scale = Vector3.ONE*3
	else:
		$camera/slidething.transparency = 1

func setsurfboard(val):
	$surfboard.visible = val
	surfboard = val
	floor_stop_on_slope = !val
	floor_block_on_wall = !val
	print("FLOOR ANGLE")
	print(floor_max_angle)
	if val:
		floor_max_angle = deg_to_rad(5)
		wall_min_slide_angle = deg_to_rad(45)
	else:
		$surfboard.rotation = Vector3.ZERO
		floor_max_angle = deg_to_rad(45)
		wall_min_slide_angle = deg_to_rad(15)

func _physics_process(delta):
	
	delta *= physicsscale
	
	if !dead && ($camera.current || emoting):
		
		if candash:
			$walljump.global_rotation = Vector3.ZERO
		# Add the gravity.
		if not is_on_floor():# || surfboard:
			velocity.y -= gravity * delta
			falldamagemult = velocity.y
			print("yunkers")
		else: 
			coyote = 0.1
			
			doublejump = 1
			
			if falldamagemult <= -20:
				var tempaudio = load("res://tempaudio.tscn").instantiate()
				add_child(tempaudio)
				tempaudio.stream = load("res://audio/land.wav")
				tempaudio.volume_db = clampf(-20-falldamagemult, -5, 25)
				tempaudio.play()
				moveeffect("land")
				
			falldamagemult = 0
			
		if shockwavedmgdelay > 0:
			shockwavedmgdelay -= delta
			
		for i in get_slide_collision_count():
			if get_slide_collision(i).get_collider() != null:
				var collision = get_slide_collision(i).get_collider()
				if collision.is_in_group("shockwave"):
					if shockwavedmgdelay <= 0:
						var direction = atan2(global_position.x-collision.global_position.x, global_position.z-collision.global_position.z)
						velocity.x += sin(direction)*30
						velocity.y += 30
						velocity.z += cos(direction)*30
						shockwavedmgdelay = 1
						hurt(20, "ragdoll")
				if collision.is_in_group("spike"):
					if shockwavedmgdelay <= 0:
						hurt(100, "ragdoll")
						shockwavedmgdelay = 1
						
		if cancrouch:
			if !$canuncrouch.is_colliding():
				slide = Input.is_action_pressed("crouch")
			else:
				slide = slide
		else:
			slide = false
			
		if !slide:
			$camera.position.y = lerpf($camera.position.y, 1.5, delta*10)
			if ($camera.position.y > 1.48): $camera.position.y = 1.5
		else:
			$camera.position.y = lerpf($camera.position.y, 1.0, delta*10)
			if ($camera.position.y < 1.02): $camera.position.y = 1.0
		$stand.disabled = slide
		$crouch.disabled = !slide
		
		if is_on_floor():
			if !slide && !surfboard:
				velocity.x *= 1-(floorfriction*delta)
				velocity.z *= 1-(floorfriction*delta)
			else:
				velocity.x *= 1-(slidefriction*delta)
				velocity.z *= 1-(slidefriction*delta)
		else:
			if !slide && !surfboard:
				var totelvel = sqrt(pow(velocity.x, 2) + pow(velocity.z, 2))
				var frict = airfriction
				totelvel /= 10
				if totelvel >= 1 && candash && !cancrouch:
					frict *= 1/totelvel
				velocity.x *= 1-(frict*delta)
				velocity.z *= 1-(frict*delta)
				
		if candash:
			var iscol = false
			for ray in $walljump.get_children():
				if ray.is_colliding():
					iscol = true
					break
			if iscol && !is_on_floor():
				walljumpvel.x = lerpf(walljumpvel.x, velocity.x, delta*1)
				walljumpvel.z = lerpf(walljumpvel.z, velocity.z, delta*1)
				var totalwallvel = sqrt(pow(walljumpvel.x, 2) + pow(walljumpvel.z, 2))
				if totalwallvel > 8*SPEED: totalwallvel = 8*SPEED
				var pitch = clampf((totalwallvel/SPEED)/2, 0.65, 3)
				var vol = -80+clampf((totalwallvel/SPEED)*20, 50, 80)  
				if $audio.stream.resource_path.get_file() != "wallslide.tres" || !$audio.playing:
					playaudio("res://audio/wallslide.tres")
					print("play wallslide sound")
					var tempaudio = load("res://tempaudio.tscn").instantiate()
					add_child(tempaudio)
					tempaudio.stream = load("res://audio/walllatch.mp3")
					tempaudio.pitch_scale = pitch
					tempaudio.volume_db = vol
					tempaudio.play()
				#$audio.pitch_scale = lerpf($audio.pitch_scale, pitch, delta*2)
				$audio.pitch_scale = pitch
				$audio.volume_db = vol
			else:
				if $audio.stream.resource_path.get_file() == "wallslide.tres":
					$audio.stop()
				#walljumpvel.x = lerpf(walljumpvel.x, velocity.x, delta)
				#walljumpvel.z = lerpf(walljumpvel.z, velocity.z, delta)
				var totalwallvel = sqrt(pow(walljumpvel.x, 2) + pow(walljumpvel.z, 2))
				var totalvel = sqrt(pow(velocity.x, 2) + pow(velocity.z, 2))
				walljumpvel = velocity
				
		#var ee = sqrt(pow(walljumpvel.x, 2) + pow(walljumpvel.z, 2))
		#print(ee)
		
		if jetpack:
			if Input.is_action_pressed("jump"):
				if !is_on_floor() && !is_on_wall():
					velocity.y += delta*70
			
		# Handle Jump.
		if Input.is_action_just_pressed("jump"):
			doajump = 1
		if !Input.is_action_pressed("jump"):
			doajump -= delta*20
		elif Input.is_action_pressed("jump"):
			doajump -= delta*10 #early jump press
		if Input.is_action_pressed("zoom"):
			$camera.fov = $"../".fov*(30.0/75.0)
		else:
			$camera.fov = $"../".fov
		if doajump > 0 && (is_on_floor() || coyote > 0):
			velocity.y = JUMP_VELOCITY
			coyote = 0
			playaudio("res://audio/jump.wav")
			moveeffect("jump")
			doajump = 0
			
		if candash:
			if !cancrouch:
				if Input.is_action_pressed("crouch"):
					if velocity.y > -50:
						velocity.x = lerpf(velocity.x, 0, delta*4)
						velocity.y -= delta*250
						velocity.z = lerpf(velocity.z, 0, delta*4)
		
			if dashdelay > 0: dashdelay -= delta/dashseconds
			else:
				if dashdelay != -10:
					$"../sfx".stream = load("res://audio/dashcharged.mp3")
					$"../sfx".play()
					dashdelay = -10
			$"../canvas/hud/dash".show()
			$"../canvas/hud/dash".value = (1-dashdelay)
			var iscol = false
			for ray in $walljump.get_children():
				if ray.is_colliding():
					iscol = true
					break
			if doajump > 0 && iscol:
				var closest = 0
				var closestdist = 100
				for ray in $walljump.get_children():
					if ray.is_colliding():
						var pos = ray.global_position-ray.get_collision_point()
						if sqrt(pow(pos.x, 2) + pow(pos.z, 2)) < closestdist:
							closestdist = sqrt(pow(pos.x, 2) + pow(pos.z, 2))
							closest = ray
				var angle = Vector3(-sin(closest.rotation.y), 0, -cos(closest.rotation.y))
				var xwall = 1-abs(-sin(rotation.y)-angle.x)/2
				var zwall = 1-abs(-cos(rotation.y)-angle.z)/2
				angle.x = lerpf(angle.x, -sin(rotation.y), xwall)
				angle.z = lerpf(angle.z, -cos(rotation.y), zwall)
				var totalwallvel = sqrt(pow(walljumpvel.x, 2) + pow(walljumpvel.z, 2))
				if totalwallvel > 8*SPEED: totalwallvel = 8*SPEED
				var power = 15
				velocity.x += angle.x*totalwallvel+angle.x*power
				velocity.y = JUMP_VELOCITY
				velocity.z += angle.z*totalwallvel+angle.z*power
				doajump = 0
				
				var pitch = clampf($audio.pitch_scale/2, 0.75, 1.5)
				var vol = $audio.volume_db
				var tempaudio = load("res://tempaudio.tscn").instantiate()
				add_child(tempaudio)
				tempaudio.stream = load("res://audio/walljump.mp3")
				tempaudio.pitch_scale = pitch
				tempaudio.volume_db = vol
				tempaudio.play()
		else:
			$"../canvas/hud/dash".hide()
				
		if candoublejump:
			if doublejump >= 1 && djdelay <= 0 && velocity.y < JUMP_VELOCITY*0.54 && !$djumpaccidentproofing.is_colliding():
				$"../canvas/hud/doublejump".modulate.v = 1
				if doajump > 0:
					velocity.y = JUMP_VELOCITY*1.5
					playaudio("res://audio/doublejump.wav")
					doublejump -= 1
					djdelay = 1
			else:
				$"../canvas/hud/doublejump".modulate.v = 0.75
				

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if Input.is_action_pressed("dash"):
			if candash:
				var totalvel = sqrt(pow(velocity.x, 2) + pow(velocity.z, 2))
				if totalvel < 1000 && dashdelay <= 0 && !is_on_floor():
					dashdelay = 1
					var power = 30
					if dashseconds < 0.2: power = 5
					if direction == Vector3.ZERO:
						if dashseconds < 0.2: velocity.y -= power*2
						else:
							velocity.x /= 5
							velocity.y -= power*0.3
							velocity.z /= 5
					else:
						velocity.x = totalvel*direction.x+direction.x*power
						if dashseconds < 0.2: velocity.y += power*2
						else: velocity.y = power*0.2
						velocity.z = totalvel*direction.z+direction.z*power
					var tempaudio = load("res://tempaudio.tscn").instantiate()
					add_child(tempaudio)
					if direction != Vector3.ZERO:
						tempaudio.stream = load("res://audio/dash.mp3")
					else:
						tempaudio.stream = load("res://audio/dashstop.mp3")
					tempaudio.play()
		
		if cancrouch:
			if !is_on_floor() && Input.is_action_just_pressed("crouch"):
				if velocity.y > -JUMP_VELOCITY*5:
					velocity.y -= JUMP_VELOCITY*5
					print("get down tonight")
					
		if surfboard:
			if (direction != Vector3.ZERO && is_on_floor()):
				var mult = 0.1
				
				velocity.x += direction.x*SPEED*mult
				velocity.z += direction.z*SPEED*mult
		
		if slide:
			if (direction != Vector3.ZERO && is_on_floor() && sqrt(pow(velocity.x, 2) + pow(velocity.z, 2)) > 1 && sqrt(pow(velocity.x, 2) + pow(velocity.z, 2)) < 5*SPEED*SLIDEMULT):
				var mult = 0.2
				if Input.is_action_just_pressed("crouch"):
					mult = 5
					var tempaudio = load("res://tempaudio.tscn").instantiate()
					add_child(tempaudio)
					tempaudio.stream = load("res://audio/slidestart.wav")
					tempaudio.volume_db = 5
					tempaudio.play()
					
				velocity.x += direction.x*SPEED*SLIDEMULT*mult
				velocity.z += direction.z*SPEED*SLIDEMULT*mult
				
			#print("velocity = "+str(sqrt(pow(velocity.x, 2) + pow(velocity.z, 2))))
			if sqrt(pow(velocity.x, 2) + pow(velocity.z, 2)) >= 25:
				for body in $groundslam.get_overlapping_bodies():
					if body.is_in_group("popcop"):
						body.die()
					if body.is_in_group("sodacan"):
						body.explode(true)
				
			if (is_on_floor()):
				if $audio.stream.resource_path.get_file() != "slide.tres" || !$audio.playing:
					playaudio("res://audio/slide.tres")
					print("play slide sound")
				var pitch = clampf(sqrt(pow(velocity.x, 2) + pow(velocity.z, 2))/SPEED/10, 0.65, 3)
				var vol = -80+clampf(sqrt(pow(velocity.x, 2) + pow(velocity.z, 2))/SPEED*10, 70, 90)
				$audio.pitch_scale = lerpf($audio.pitch_scale, pitch, delta*2)
				$audio.volume_db = vol
			
			if is_on_floor():
				if slidefallpos > position.y:
					var extra = slidefallpos-position.y
					if extra > 20: extra = 20
					velocity.x += direction.x*SPEED*SLIDEMULT*0.75*(extra)
					velocity.z += direction.z*SPEED*SLIDEMULT*0.75*(extra)
					screenshake += (extra)*0.05
					
					print("groundslam power: "+str(extra))
					
					if extra > 8:
						for body in $groundslam.get_overlapping_bodies():
							if body.is_in_group("popcop"):
								body.die()
					if extra > 0.2:
						for body in $groundslam.get_overlapping_bodies():
							if body.is_in_group("springmachine"):
								body.get_parent().launch()
					
					var tempaudio = load("res://tempaudio.tscn").instantiate()
					add_child(tempaudio)
					tempaudio.stream = load("res://audio/groundslam.wav")
					var vol = -80+(extra*5+20)
					tempaudio.volume_db = vol
					tempaudio.play()
					
		if !slide || !is_on_floor():
			if $audio.stream.resource_path.get_file() == "slide.tres":
				$audio.stop()
		
		if is_on_floor():
			slidefallpos = position.y
		else:
			if position.y > slidefallpos:
				slidefallpos = position.y
		
		if !slide && !surfboard:
			#walk
			if direction != Vector3.ZERO && is_on_floor():
				if $walktimer.is_stopped() && sqrt(pow(velocity.x, 2) + pow(velocity.z, 2)) >= 0.5*SPEED:
					var walksound = "res://audio/walk ("+str(randi_range(1, 4))+").wav"
					var djap = $djumpaccidentproofing.get_collider()
					if djap != null:
						if djap.is_in_group("snow"):
							walksound = "res://audio/snowwalk ("+str(randi_range(1, 4))+").wav"
					playaudio(walksound)
					moveeffect("run")
					$walktimer.wait_time = 0.4/SPEED
					$walktimer.start()
				if $anim.current_animation != "move": $anim.play("move")
			if direction == Vector3.ZERO && is_on_floor() && !emoting:
				if $anim.current_animation != "idle": $anim.play("idle")
					
			var control = 1
			if not is_on_floor():
				control = 0.2
			if direction:
				var futurevelocity_x = velocity.x + direction.x * SPEED * control
				var futurevelocity_z = velocity.z + direction.z * SPEED * control
				if sqrt(pow(futurevelocity_x, 2) + pow(futurevelocity_z, 2)) <= 5*SPEED:
					velocity.x = futurevelocity_x
					velocity.z = futurevelocity_z
		else:
			#slide
			if direction != Vector3.ZERO && is_on_floor():
				pass
				#if $anim.current_animation != "slide": $anim.play("slide")
			if direction == Vector3.ZERO && is_on_floor():
				pass
				#if $anim.current_animation != "idle": $anim.play("idle")
			
			var control = 0.2
			if not is_on_floor():
				control = 0
			if direction:
				var futurevelocity_x = velocity.x + direction.x * SPEED*SLIDEMULT * control
				var futurevelocity_z = velocity.z + direction.z * SPEED*SLIDEMULT * control
				if sqrt(pow(futurevelocity_x, 2) + pow(futurevelocity_z, 2)) <= 5*SPEED*SLIDEMULT:
					velocity.x = futurevelocity_x
					velocity.z = futurevelocity_z
					
		if slide && is_on_floor():
			if $anim.is_playing():
				if $anim.current_animation != "slide": $anim.play("slide")
			var skeldir = Vector2(velocity.x, velocity.z).normalized()
			$Armature/Skeleton3D.global_rotation.y = lerp_angle($Armature/Skeleton3D.global_rotation.y, atan2(skeldir.x, skeldir.y), delta*4)
		else:
			$Armature/Skeleton3D.rotation.y = 0
			
		var djap = $djumpaccidentproofing.get_collider();
		
		if surfboard:
			if djap != null:
				var djray = $djumpaccidentproofing
				if djray.get_collision_normal() == Vector3(0, 1, 0):
					$surfboard/surfboard.rotation.z = -rotation.y
					$surfboard.rotation = Vector3(PI/2, -rotation.y, 0)
				else:
					var rayvect = (djray.global_position-djray.get_collision_point()).normalized()
					var reflection = rayvect.reflect(djray.get_collision_normal())
					$surfboard.look_at(djray.get_collision_normal()+djray.get_collision_point())
					$surfboard/surfboard.rotation.z = -rotation.y
					var forwardvect = Vector2(djray.get_collision_normal().x, djray.get_collision_normal().z).normalized()
					var lookvect = Vector2(sin(rotation.y), cos(rotation.y))
					var angle = 1-abs((abs(forwardvect.angle_to(lookvect))-PI/2))/(PI/2)
					angle = clampf(angle*2, 0, 1)
					print(angle)
					var perpdir = -sign(forwardvect.angle_to(lookvect))
					velocity *= 1-(1*delta*(angle))
					var perpvel = 0.5*perpdir*angle*Vector2(-forwardvect.y, forwardvect.x)
					velocity.x += perpvel.x
					velocity.z += perpvel.y
					
					if Vector3.ZERO.distance_to(velocity) > 100:
						velocity = velocity.normalized()*100
					
					print(forwardvect)
					print(lookvect)
			else:
				$surfboard/surfboard.rotation.z = -rotation.y
				$surfboard.rotation = Vector3(PI/2, -rotation.y, 0)
		
		if djap != null && sqrt(pow(velocity.x, 2) + pow(velocity.z, 2)) >= 0.1 && is_on_floor():
			$sand.emitting = djap.is_in_group("sand")
			var slideeffect = clamp((sqrt(pow(velocity.x, 2) + pow(velocity.z, 2))-15)/25, 0, 1)
			if !slide: slideeffect = 0
			$slidepivot/slideparticle.transparency = lerpf($slidepivot/slideparticle.transparency, 1-slideeffect, delta*5)
			$walkparticle.emitting = true
			$slidepivot/slideparticle.emitting = true
		else:
			$sand.emitting = false
			$slidepivot/slideparticle.transparency = lerpf($slidepivot/slideparticle.transparency, 1, delta*20)
			$walkparticle.emitting = false
				
		if !is_on_floor():
			if $anim.is_playing() || slide:
				if $anim.current_animation != "jump": $anim.play("jump")
				
		velocity *= physicsscale
		move_and_slide()
		velocity /= physicsscale
	else:
		if $audio.stream.resource_path.get_file() == "slide.tres":
			$audio.stop()
		if $audio.stream.resource_path.get_file() == "wallslide.tres":
			$audio.stop()
			
func moveeffect(anim):
	var effect = load("res://moveeffects.tscn").instantiate()
	effect.effect = anim
	effect.position = position
	effect.rotation = Vector3(0, atan2(-velocity.x, -velocity.z), 0)
	get_parent().add_child(effect)
		
func playaudio(stream, pitch = 1, vol = 5):
	$audio.stream = load(stream)
	$audio.pitch_scale = pitch
	$audio.volume_db = vol
	$audio.play()
		
func rotatecam(movecamx, movecamy):
	if !camlock:
		if !$"../tppivot/tppivot2/tpcam".current:
			if !Input.is_action_pressed("zoom"):
				rotate_y(-movecamx * ($"../".sensitivity/1000))
				$camera.rotate_x(-movecamy * ($"../".sensitivity/1000))
			else:
				rotate_y(-movecamx * ($"../".sensitivity/1000)/5)
				$camera.rotate_x(-movecamy * ($"../".sensitivity/1000)/5)
			$camera.rotation.x = clamp($camera.rotation.x, -PI/2, PI/2)
			
			if (atan2(movecamx, movecamy) != 0):
				$camera/motionblur.rotation = -atan2(movecamx, movecamy)
			motionblur += sqrt(pow(movecamx,2)+pow(movecamy,2))*($"../".sensitivity/1000)
		
		else:
			$"../tppivot".rotate_y(-movecamx * ($"../".sensitivity/1000))
			$"../tppivot/tppivot2".rotate_x(-movecamy * ($"../".sensitivity/1000))
			$"../tppivot/tppivot2".rotation.x = clamp($"../tppivot/tppivot2".rotation.x, -PI/2, PI/2)
			if $"../tppivot/tppivot2/tpraycast".is_colliding():
				var colpoint = $"../tppivot/tppivot2/tpraycast".get_collision_point()
				var raypoint = $"../tppivot/tppivot2/tpraycast".global_position
				var dist = sqrt(pow(colpoint.x-raypoint.x, 2)+pow(colpoint.y-raypoint.y, 2)+pow(colpoint.z-raypoint.z, 2))
				$"../tppivot/tppivot2/tpcam".position.z = dist
			else:
				$"../tppivot/tppivot2/tpcam".position.z = 5
				
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if $camera.current || $"../tppivot/tppivot2/tpcam".current:
				rotatecam(event.relative.x, event.relative.y)
	if Input.is_action_just_pressed("emote"):
		if is_on_floor() && !emoting && !dead && !slide && camera.current:
			emoting = true
			$"../tppivot/tppivot2/tpcam".current = true
			$"../".tplock = $light
			$anim.play("getfucked")
			$"../tppivot".rotation.y = rotation.y+PI
			$"../tppivot/tppivot2".rotation.x = 0
		elif emoting && !dead:
			emoting = false
			camera.current = true
				
				
	if Input.is_action_just_pressed("rightclick"):
		if !dead && $camera.current:
			var collider = $camera/raycast.get_collider()
			if collider != null:
				if collider.is_in_group("pipewheel"):
					collider.get_parent().spin()
				if collider.is_in_group("grease"):
					collider.pet()
	if Input.is_action_just_pressed("click"):
		if !dead && $camera.current:
			var collider = $camera/raycast.get_collider()
			if collider != null:
				if collider.is_in_group("painting"):
					collider.spos = camera.global_position
					collider.srot = camera.global_rotation
					collider.playanim()
				if collider.is_in_group("pipewheel"):
					collider.get_parent().spin()
				if collider.is_in_group("clickable"):
					collider.get_parent().clicked()
				if collider.is_in_group("poobottle"):
					collider.get_parent().take()
				if collider.is_in_group("acrylicpaint"):
					collider.get_parent().takepaint()
				if collider.is_in_group("difficultybutton"):
					collider.get_parent().get_parent().get_parent().diffselect(collider.name)
				if collider.is_in_group("talk"):
					collider.talk()
				if collider.is_in_group("link"):
					OS.shell_open(collider.get_parent().get_meta("link"))
					$camera.rotation_degrees.x = 90
				if collider.is_in_group("copycredits"):
					collider.get_parent().get_parent().copycredits()
				if collider.is_in_group("door"):
					collider.get_child(0).play("open")
					if collider.name == "paintingdoor":
						$"../".transitionfunc(["loadmap", "res://maps/artstoreinside.tscn", -1])
					if collider.name == "exitpaintingdoor":
						$"../".transitionfunc(["loadmap", "res://maps/lobby.tscn", -1, "none", Vector3(0, 1, 10)])
					if collider.name == "exitcreditsdoor":
						$"../".transitionfunc(["loadmap", "res://maps/lobby.tscn", -1, "none", Vector3(-7, 0, -4)])
					if collider.name == "lobbydoor":
						$"../".transitionfunc(["loadmap", "res://maps/lobby.tscn", -1])
					if collider.name == "creditsdoor":
						$"../".transitionfunc(["loadmap", "res://maps/credits.tscn", -1])
						$"../".transitionmusic("res://audio/music/creditstheme.mp3", 1, false)
				if collider.is_in_group("item"):
					collider.get_parent().pickup()
				if collider.is_in_group("grease"):
					collider.pickup()
func kill(effect):
	print("died to death")
	
	hiteffect = 0.5
	
	dead = true
	$"../canvas/hud/died".play("start")
	
	$"../tppivot/tppivot2/tpcam".current = true
	
	$"../tppivot/tppivot2".rotation_degrees.x = -30
	
	$"../music".stream = load("res://audio/music/deathmusic.mp3")
	$"../music".play()
	
	$"../canvas/hud/timer".hide()
	
	var currenthead = $Armature/Skeleton3D/headbone/offset.get_child(0)
	if currenthead.has_meta("deathsound"):
		var tempaudio = load("res://tempaudio.tscn").instantiate()
		add_child(tempaudio)
		tempaudio.stream = load("res://audio/deathsounds/"+str(currenthead.get_meta("deathsound"))+".mp3")
		tempaudio.play()
	
	if effect == "ragdoll":
		var hitaudio = load("res://tempaudio.tscn").instantiate()
		add_child(hitaudio)
		hitaudio.stream = load("res://audio/death ("+str(randi_range(1, 3))+").wav")
		hitaudio.pitch_scale = randf_range(0.75, 1.25)
		hitaudio.play()
		
		var ragdoll = load("res://ragdoll.tscn").instantiate()
		ragdoll.color = $"../".bodycolor
		ragdoll.head = $"../".head
		ragdoll.vel = velocity
		ragdoll.rotation.y = rotation.y
		ragdoll.position = position
		$"../map".add_child(ragdoll)
		$"../".tplock = ragdoll.get_child(1).get_child(0)
		
	if effect == "squish":
		var hitaudio = load("res://tempaudio.tscn").instantiate()
		add_child(hitaudio)
		hitaudio.stream = load("res://audio/squishdeath.mp3")
		hitaudio.pitch_scale = randf_range(0.75, 1.25)
		hitaudio.play()
		
		var ragdoll = load("res://squish.tscn").instantiate()
		ragdoll.color = $"../".bodycolor
		ragdoll.head = $"../".head
		ragdoll.rotation.y = rotation.y
		ragdoll.position = position
		$"../map".add_child(ragdoll)
		$"../".tplock = ragdoll.get_child(1).get_child(0)
		$"../"
		
	if effect == "bluelaser":
		var hitaudio = load("res://tempaudio.tscn").instantiate()
		add_child(hitaudio)
		hitaudio.stream = load("res://audio/squishdeath.mp3")
		hitaudio.pitch_scale = randf_range(0.75, 1.25)
		hitaudio.play()
		
		var ragdoll = load("res://laserdeath.tscn").instantiate()
		ragdoll.rotation.y = rotation.y
		ragdoll.position = position
		ragdoll.position.y = 0
		$"../map".add_child(ragdoll)
		$"../".tplock = ragdoll
		
	if effect == "lasernopile":
		var hitaudio = load("res://tempaudio.tscn").instantiate()
		add_child(hitaudio)
		hitaudio.stream = load("res://audio/squishdeath.mp3")
		hitaudio.pitch_scale = randf_range(0.75, 1.25)
		hitaudio.play()
		
		var ragdoll = load("res://laserdeath.tscn").instantiate()
		ragdoll.rotation.y = rotation.y
		ragdoll.position = position
		ragdoll.position.y = 0
		ragdoll.pile = false
		$"../map".add_child(ragdoll)
		$"../".tplock = ragdoll
		
	if effect == "radiation":
		var hitaudio = load("res://tempaudio.tscn").instantiate()
		add_child(hitaudio)
		hitaudio.stream = load("res://audio/death ("+str(randi_range(1, 3))+").wav")
		hitaudio.pitch_scale = randf_range(0.75, 1.25)
		hitaudio.play()
		
		var ragdoll = load("res://ragdoll.tscn").instantiate()
		ragdoll.color = Color.SEA_GREEN
		ragdoll.head = $"../".head
		ragdoll.vel = velocity
		ragdoll.rotation.y = rotation.y
		ragdoll.position = position
		$"../map".add_child(ragdoll)
		$"../".tplock = ragdoll.get_child(1).get_child(0)
		
	if effect == "freeze":
		var hitaudio = load("res://tempaudio.tscn").instantiate()
		add_child(hitaudio)
		hitaudio.stream = load("res://audio/death ("+str(randi_range(1, 3))+").wav")
		hitaudio.pitch_scale = randf_range(0.75, 1.25)
		hitaudio.play()
		
		var ragdoll = load("res://freezeragdoll.tscn").instantiate()
		ragdoll.color = $"../".bodycolor
		ragdoll.head = $"../".head
		ragdoll.vel = velocity
		ragdoll.rotation.y = rotation.y
		ragdoll.position = position
		$"../map".add_child(ragdoll)
		$"../".tplock = ragdoll.get_child(1).get_child(0)
		
	if effect == "fall":
		var hitaudio = load("res://tempaudio.tscn").instantiate()
		add_child(hitaudio)
		hitaudio.stream = load("res://audio/elevator/falldeath.mp3")
		hitaudio.play()
		
		var ragdoll = load("res://fallragdoll.tscn").instantiate()
		ragdoll.color = $"../".bodycolor
		ragdoll.head = $"../".head
		ragdoll.vel = velocity
		ragdoll.rotation.y = rotation.y
		ragdoll.position = position
		$"../tppivot/tppivot2".rotation_degrees.x = -90
		$"../map".add_child(ragdoll)
		$"../".tplock = ragdoll.get_child(2)
		
	if effect == "lava":
		var hitaudio = load("res://tempaudio.tscn").instantiate()
		add_child(hitaudio)
		hitaudio.stream = load("res://audio/lavadeath.mp3")
		hitaudio.play()
		
		var ragdoll = load("res://lavaragdoll.tscn").instantiate()
		ragdoll.head = $"../".head
		ragdoll.vel = Vector3(0, 10, 0)
		ragdoll.rotation.y = rotation.y
		ragdoll.position = position
		$"../tppivot/tppivot2".rotation_degrees.x = -90
		$"../map".add_child(ragdoll)
		$"../".tplock = ragdoll.get_child(2)
		
	if effect == "darkmagic":
		var hitaudio = load("res://tempaudio.tscn").instantiate()
		add_child(hitaudio)
		hitaudio.stream = load("res://audio/darkmagicdeath.mp3")
		hitaudio.play()
		
		var ragdoll = load("res://darkmagicdeath.tscn").instantiate()
		ragdoll.rotation.y = rotation.y
		ragdoll.position = position
		$"../map".add_child(ragdoll)
		$"../".tplock = ragdoll.get_child(0)

func heal(amount):
	if !dead && $camera.current:
		health += amount
		if health > 100:
			health = 100
			
		var hitaudio = load("res://tempaudio.tscn").instantiate()
		add_child(hitaudio)
		hitaudio.stream = load("res://audio/heal.mp3")
		hitaudio.pitch_scale = randf_range(0.75, 1.25)
		hitaudio.play()

func hurt(dmg, effect):
	if !dead && ($camera.current || emoting):
		if emoting:
			emoting = false
			camera.current = true
		
		if $"../map/lobbyportal" != null:
			pass
		else:
			health -= dmg
			print("ow my balls: " + str(dmg))
			hiteffect += float(dmg)/100
			$"../".audioeffectcool = 1
			$"../canvas/hud/healthparticles".restart()
			for child in $"../canvas/hud/damageparticles".get_children():
				child.restart()
				$"../canvas/hud/damagegradient/anim".play("default")
			
			if health <= 0:
				if $"../map/lobbyportal" != null:
					health = 100
					position = $"../map/lobbyportal".position
				elif $"../map/lobby" != null:
					if $"../map/".currentlevel != "none":
						health = 100
						var point = $"../map/".get_node("levelrespawn")
						position = point.position
						velocity = Vector3.ZERO
					else:
						kill(effect)
						health = 0
				else:
					kill(effect)
					health = 0
			
			if health > 0:
				var hitaudio = load("res://tempaudio.tscn").instantiate()
				add_child(hitaudio)
				
				if dmg < 5:
					hitaudio.stream = load("res://audio/hurt0.mp3")
				if dmg >= 5 && dmg < 15:
					hitaudio.stream = load("res://audio/hurt1.mp3")
				if dmg >= 15 && dmg < 50:
					hitaudio.stream = load("res://audio/hurt2.mp3")
				if dmg >= 50:
					hitaudio.stream = load("res://audio/hurt3.mp3")

				hitaudio.pitch_scale = randf_range(0.75, 1.25)
				hitaudio.play()
				
func updatelook():
	
	var loadoutfit = load($"../".outfit).instantiate()
	for child in $Armature/Skeleton3D/headbone/attachments.get_children():
		child.queue_free()
	if loadoutfit.has_node("Armature/Skeleton3D/head"):
		var headattachments = loadoutfit.get_node("Armature/Skeleton3D/head")
		for child in headattachments.get_children():
			child.reparent($Armature/Skeleton3D/headbone/attachments)
			child.position = headattachments.position
			child.rotation = headattachments.rotation-$Armature/Skeleton3D/headbone.rotation
			child.scale = headattachments.scale
	var mainbody = loadoutfit.get_node("Armature/Skeleton3D/main")
	$Armature/Skeleton3D/Cube.name = "deletebody"
	$Armature/Skeleton3D/deletebody.queue_free()
	mainbody.reparent($Armature/Skeleton3D)
	mainbody.position = Vector3.ZERO
	mainbody.rotation = Vector3.ZERO
	mainbody.name = "Cube"
	if $"../".outfitcolors.has($"../".outfit):
		if mainbody.has_meta("extracolors"):
			for i in range(1, mainbody.get_meta("extracolors")+1):
				var curcolorrgb = $"../".outfitcolors[$"../".outfit][str(i)]
				var curcolor = Color(curcolorrgb["r"], curcolorrgb["g"], curcolorrgb["b"])
				mainbody.get_surface_override_material(i).albedo_color = curcolor
	if mainbody.has_meta("textedit"):
		var text = mainbody.get_node("text/text")
		text.text = $"../".outfittext
	#loadoutfit.queue_free()
	
	$Armature/Skeleton3D/Cube.get_surface_override_material(0).albedo_color = $"../".bodycolor
	
	for child in $Armature/Skeleton3D/headbone/offset.get_children():
		child.queue_free()
	var loadhead = load($"../".head).instantiate()
	for child in loadhead.get_children():
		if child is MeshInstance3D:
			child.layers = 32
		for childagain in child.get_children():
			if childagain is MeshInstance3D:
				childagain.layers = 32
			for childagainagain in childagain.get_children():
				if childagainagain is MeshInstance3D:
					childagainagain.layers = 32
				if childagainagain is OmniLight3D:
					childagainagain.layers = 32
	$Armature/Skeleton3D/headbone/offset.add_child(loadhead)
	
func setshaders(val):
	for child in $camera.get_children():
		if child is ColorRect:
			child.visible = val

func _on_cubeleavearea_area_exited(area: Area3D) -> void:
	pass
	#print("area exiting: ")
	#if area.name == "cubearea" && !dead:
		#$"../".escapecube("player")
