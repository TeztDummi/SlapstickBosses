extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var diff = 0
var chal = "none"
var level = 1
var revivelist = []
var hurtlist = []

func _ready() -> void:
	var gun = load("res://laserpointer.tscn").instantiate()
	$"../player/camera/gun".add_child(gun)
	$"../player".scroll = 1
	
	$"../player".candoublejump = true
	$"../player".djseconds = 2
	
	$lavaanim.play("RESET")
	
func dodafreeze():
	$spleefboss.freezeattack()
	
func endbreak():
	$anim.playfps("breakchain", 12)
	$stoneplataudio.play()

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "breakchain":
		$spleefboss.move = true
		$anim.playfps("sink", 8)
	if anim_name == "sink":
		$stoneplat.queue_free()
	if anim_name == "jumptolevel2":
		$spleefboss.move = true
		$spleefboss.lasergoup = false
		
func _process(delta: float) -> void:
	pass
	
func nextlevel():
	level += 1
	revivelist = get_node("level"+str(level)).get_children()
	hurtlist = get_node("level"+str(level-1)).get_children()
	$revivetimer.start()
	
func levelgroup():
	return get_node("level"+str(level))

func _on_lavaarea_area_entered(area: Area3D) -> void:
	print("eneterd lava: "+str(area))
	if area.name == "lavacheck":
		var splash = load("res://spleef/lavaparticles.tscn").instantiate()
		splash.position = area.global_position
		#splash.position.y = $lava.position.y
		add_child(splash)
		if area.get_parent().is_in_group("spleefboss"):
			area.get_parent().fallinlava()
		if area.get_parent().is_in_group("playergroup"):
			area.get_parent().hurt(100, "lava")

func _on_revivetimer_timeout() -> void:
	if player.position.y >= get_node("level"+str(level)).position.y:
		if revivelist.size() > 0:
			var randid = randi_range(0, revivelist.size()-1)
			var block = revivelist.pop_at(randid)
			if !block.is_in_group("bossrevives"):
				block.revive()
		if hurtlist.size() > 0:
			var randid2 = randi_range(0, hurtlist.size()-1)
			hurtlist.pop_at(randid2).hurt()
		if hurtlist.size() <= 0 && revivelist.size() <= 0:
			if level == 2:
				$revivetimer.stop()
				$spleefboss.move = false
				$spleefboss.vulnerable = false
				$spleefboss.setattack(4)
				$spleefboss.position.x = 0
				$spleefboss.position.z = 0
				$spleefboss.position.y -= 6
				$spleefboss.lasergoup = true
				$lavaanim.play("level2")
			
func _on_lavaanim_animation_finished(anim_name: StringName) -> void:
	print("done did")
	if anim_name == "level2":
		$anim.playfps("jumptolevel2")
