extends AudioStreamPlayer2D

class_name VariableSound2D

export  var pitch_variation = 0.1
export  var one_shot = false
export  var streams: Array = []
var pitch_scale_ = 0.0





func _ready():
	pitch_scale_ = pitch_scale
	if autoplay:
		play()
	if one_shot:
		connect("finished", self, "queue_free")


func play(p = 0.0):
	.play(p)
