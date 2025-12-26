extends Node3D
var diff = -1
@onready var player = $"../player"
var suntimer = false
var suntime = 0
var basketdelay = 0
var cloudstime = 0
var boingchallenge = 0
var currentlevel = "none"

var billboards = ["res://textures/billboard/ardoniasrock.png",
	"res://textures/billboard/gambling.png",
	"res://textures/billboard/gerbis.png",
	"res://textures/billboard/greanbean.png",
	"res://textures/billboard/ilikemen.png",
	"res://textures/billboard/lublordwhen.png",
	"res://textures/billboard/misterbigg.png",
	"res://textures/billboard/thebonemen.png",
	"res://textures/billboard/leave.png",
	"res://textures/billboard/theutrakill.png",
	"res://textures/billboard/darylldidit.png",
	"res://textures/billboard/tracysgreens.png",
	"res://textures/billboard/fnfgearmo.png",
	"res://textures/billboard/outerwilds.png",
	"res://textures/billboard/balatro.png"]

func lobbypower(val):
	if val:
		player.falloff = true
		for child in $"../player/camera/gun".get_children():
			if !child.has_meta("held"):
				child.queue_free()
		if $"../".lobbypower.has("slide"):
			player.cancrouch = true
		if $"../".lobbypower.has("doublejump"):
			player.candoublejump = true
			player.djseconds = 0.25
		if $"../".lobbypower.has("dash"):
			player.candash = true
			player.dashseconds = 2
	else:
		player.cancrouch = false
		player.candoublejump = false
		player.candash = false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	lobbypower(true)
	
	if $"../".bits <= 0 || $"../".freebits:
		$funnysigns.queue_free()
	if !$"../".didintro:
		$introstuff/introcam/introcam.current = true
		#$introstuff/introcam/introcam/blackfade.show()
		#$introstuff/introcam/introcam/clicktobegin.show()
	else:
		$cube/cube/cubeparticles.emitting = false
		$introstuff/introcam/introcam/blackfade.hide()
		$introstuff/introcam/introcam/clicktobegin.hide()
		if $"../".spooky: $"../music".stream = load("res://audio/music/spookylobby.mp3")
		elif $"../".christmas: $"../music".stream = load("res://audio/music/christmaslobby.mp3")
		else: $"../music".stream = load("res://audio/music/lobbymusic.mp3")
		$"../music".play()
	
	if $"../".bitbags.has("basketball"):
		$bballbitsarea.queue_free()
		
	if !$"../".beatsomethingnormal:
		$alleytrespass.queue_free()
		$"challenge guy".queue_free()
		
	
	if $"../".didintro:
		_on_updateday_timeout()
		$updateday.start()
		
func _process(delta):
	
	if !$"../".didintro:
		if Input.is_action_just_pressed("click"):
			$introstuff/anim.play("default")
			$"../".didintro = true
	$DirectionalLight3D.position = player.position
	
	if $DirectionalLight3D/sun.transparency <= 0:
		if suntimer: suntime += delta
		else: suntime = 0
		suntimer = false
	
		if suntime >= 5:
			if $DirectionalLight3D/sun/anim.is_playing() && $DirectionalLight3D/sun/anim.current_animation != "shoot":
				$DirectionalLight3D/sun/anim.play("shoot")
			
	if basketdelay > 0: basketdelay -= delta
			
	if $bballbitsarea != null:
		for body in $bballbitsarea.get_overlapping_bodies():
			if body.is_in_group("basketball"):
				body.set_meta("wasinbitarea", true)
				
	cloudstime += delta*0.2
	$platform/platformclouds.position.y = sin(cloudstime)*50
	$platform/platformclouds.rotation.y += 0.0005
	
	if boingchallenge > 0:
		if player.is_on_floor():
			var doit = false
			for i in player.get_slide_collision_count():
				if !player.get_slide_collision(i).get_collider().name.begins_with("boing"):
					doit = true
					break
			if doit:
				setboingchallenge(0)
	
func _on_removesignplat_body_entered(body):
	if body.is_in_group("playergroup"):
		if $funnysigns/delplat != null:
			$funnysigns/delplat.queue_free()
		$"../".freebits = true
		$funnysigns/casette/audio.play()
		$"../".save_game()
func _on_area_body_entered(body):
	pass # Replace with function body.

func _on_thanksfatso_body_entered(body):
	if body.is_in_group("playergroup"):
		$"../".setAchievement("thanksfatso")
		
func killthatmfer():
	player.hurt(100, "bluelaser")
	$"../".setAchievement("sunkissedglow")

func _on_anim_animation_finished(anim_name):
	if anim_name == "default":
		player.camera.current = true
		$cube/cube/cubeparticles.emitting = false
		if $"../".spooky: $"../music".stream = load("res://audio/music/spookylobby.mp3")
		elif $"../".christmas: $"../music".stream = load("res://audio/music/christmaslobby.mp3")
		else: $"../music".stream = load("res://audio/music/lobbymusic.mp3")
		$"../music".play()
		$gearmo/clicktotalkanim.play("default")

func _on_bballarea_body_entered(body):
	if body.is_in_group("basketball"):
		if basketdelay <= 0:
			if body.linear_velocity.y > 0.1:
				body.linear_velocity.y = -1
			else:
				$hoop/audio.play()
				basketdelay = 1
				$"../".baskets += 1
				$"../".save_game()
				if body.has_meta("wasinbitarea"):
					if !$"../".bitbags.has("basketball"):
						var popup = load("res://popup.tscn").instantiate()
						popup.bits = 200
						$"../".bits += 200
						$"../sfx".stream = load("res://audio/gainbits.mp3")
						$"../sfx".play()
						$"../canvas/hud".add_child(popup)
						$basketballparticle.emitting = true
						$"../".bitbags["basketball"] = true
				#$"../".setAchievement("thanksfatso")

func _on_alleytrespass_body_entered(body: Node3D) -> void:
	if body.is_in_group("playergroup"):
		if !body.dead:
			if player.position.x < -1:
				if $"../".crustytime <= 2:
					print("crusty kill em!!")
					$"../canvas/hud/talk".start("crustytrespass")


func _on_pssttimer_timeout() -> void:
	if $"../".beatsomethingnormal && $"../".crustytime == 1:
		$psstaudio.play()
		$psst.show()
		$psst.play("default")

func _on_updateday_timeout() -> void:
	if $"../".didintro:
		var time = float(Time.get_datetime_dict_from_system(0)["second"])
		time += Time.get_datetime_dict_from_system(0)["minute"]*60
		time += Time.get_datetime_dict_from_system(0)["hour"]*60*60
		time += Time.get_datetime_dict_from_system(0)["day"]*60*60*24
		#print("Lobby Seconds: "+str(time))
		time /= (1.0/$daycycle.speed_scale)
		time = wrap(time, 0, 24)
		#print("Lobby Hour: "+str(time))
		$daycycle.play("cycle")
		$daycycle.seek(time)
		
func setboingchallenge(num):
	if $"../".lobbypower.has("slide") && $"../".lobbypower.has("doublejump"):
		boingchallenge = num
		if num == 9:
			$"../".transitionmusic("res://audio/music/maingamegood.mp3", 4, false)
		if num == 1:
			$"../".transitionmusic("res://audio/music/maingametheme.mp3", 4, true)
		if num == 0 || num == 10:
			if $"../".spooky: $"../".transitionmusic("res://audio/music/spookylobby.mp3", 2, true)
			elif $"../".christmas: $"../".transitionmusic("res://audio/music/christmaslobby.mp3", 2, true)
			else: $"../".transitionmusic("res://audio/music/lobbymusic.mp3", 2, true)
		if num == 10:
			boingchallenge = 0
			$"../sfx2".stream = load("res://audio/goalreached.mp3")
			$"../sfx2".play()
			
			$"../".setAchievement("boingchallenge")
			
			if !$"../".beatchallenges.has("boingchallenge"):
				$"../".beatchallenges["boingchallenge"] = true
				var popup = load("res://popup.tscn").instantiate()
				popup.bits = $"../".getchalbits("boingchallenge")
				$"../".bits += $"../".getchalbits("boingchallenge")
				$"../sfx".stream = load("res://audio/gainbits.mp3")
				$"../sfx".play()
				$"../canvas/hud".add_child(popup)
				
				$boingwinner/winparticle.emitting = true
			else:
				$boingwinner/winparticleconfetti.emitting = true
				
		for child in get_children():
			if child.name.begins_with("boing"):
				if child.has_meta("boingchallenge"):
					if child.get_meta("boingchallenge") == num:
						child.get_node("boingchallenge").show()
					else:
						child.get_node("boingchallenge").hide()

func _on_skyscraperarea_body_entered(body: Node3D) -> void:
	#$platform/StaticBody3D/CollisionShape3D.disabled = true
	print("disable floor")
