extends AnimationPlayer

var curframe = 0
var fps = 48
var playing = false
var speed = 1
var prevframe = 0
var theframe = 0

func _ready() -> void:
	speed = speed_scale
	speed_scale = 0
	
func playfps(name, newfps = 48):
	play(name)
	playing = true
	curframe = 0
	fps = newfps
	
func _process(delta: float) -> void:
	if playing && get_animation(current_animation) != null:
		curframe += delta*speed
		var length = get_animation(current_animation).length
		if curframe > length:
			if get_animation(current_animation).loop_mode == Animation.LOOP_NONE:
				curframe = length
				playing = false
				animation_finished.emit(current_animation)
				#stop()
			else:
				curframe -= length
		prevframe = theframe
		theframe = floor(curframe*fps)/fps
		var functrack = get_animation(current_animation).find_track("..", Animation.TYPE_METHOD)
		if functrack == -1:
			functrack = get_animation(current_animation).find_track(".", Animation.TYPE_METHOD)
		if functrack != -1:
			if prevframe != theframe:
				#print(get_animation(current_animation).add_marker())
				var anus = get_animation(current_animation).track_find_key(functrack, theframe, Animation.FIND_MODE_APPROX)
				if anus != -1: print(anus)
				if anus != -1:
					get_animation(current_animation).track_set_enabled(functrack, true)
				else:
					get_animation(current_animation).track_set_enabled(functrack, false)
			else:
				get_animation(current_animation).track_set_enabled(functrack, false)
		seek(theframe)
