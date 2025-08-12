extends Node3D
var diff = -1
@onready var player = $"../player"
var suntimer = false
var suntime = 0
var basketdelay = 0
var cloudstime = 0

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

# Called when the node enters the scene tree for the first time.
func _ready():
	
	print(%player)
	
	if $"../".lobbypower.has("slide"):
		player.cancrouch = true
		
		#var gun = load("res://bitchslapper.tscn").instantiate()
		#$"../player/camera/gun".add_child(gun)
		#$"../player".scroll = 1
	
	if $"../".bits <= 0 || $"../".freebits:
		$funnysigns.queue_free()
	
	if !$"../".didintro:
		$introstuff/introcam/introcam.current = true
	else:
		$cube/cube/cubeparticles.emitting = false
		$introstuff/introcam/introcam/blackfade.hide()
		$introstuff/introcam/introcam/clicktobegin.hide()
		$"../music".stream = load("res://audio/music/lobbymusic.mp3")
		$"../music".play()
	
	if $"../".bitbags.has("basketball"):
		$bballbitsarea.queue_free()
		
	if !$"../".beatsomethingnormal:
		$alleytrespass.queue_free()
		$"challenge guy".queue_free()
		
func _process(delta):
	if !$"../".didintro:
		if Input.is_action_just_pressed("click"):
			$introstuff/anim.play("default")
			$"../".didintro = true
	$DirectionalLight3D.position = player.position
	if suntimer: suntime += delta
	else: suntime = 0
	suntimer = false
	
	if basketdelay > 0: basketdelay -= delta
	
	if suntime >= 5:
		if $DirectionalLight3D/sun/anim.is_playing() && $DirectionalLight3D/sun/anim.current_animation != "shoot":
			$DirectionalLight3D/sun/anim.play("shoot")
			
	if $bballbitsarea != null:
		for body in $bballbitsarea.get_overlapping_bodies():
			if body.is_in_group("basketball"):
				body.set_meta("wasinbitarea", true)
				
	cloudstime += delta*0.2
	$platform/platformclouds.position.y = sin(cloudstime)*50
	$platform/platformclouds.rotation.y += 0.0005
	
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
		$"../music".stream = load("res://audio/music/lobbymusic.mp3")
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
