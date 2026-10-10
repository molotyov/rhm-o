extends Control

var char_name = ""
var character = preload("res://characters/base/BaseChar.tscn")

func initialize_name():
	print("ok")


func _ready():
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("mouse_exited", self, "_on_mouse_exited")
	rect_pivot_offset = rect_size / 2

func _on_mouse_entered():
	if self.disabled == false:
		set("z", 10)
		_tween_scale(Vector2(1.1, 1.1))

	
	
func _on_mouse_exited():
	_tween_scale(Vector2(1.0, 1.0))


func _tween_scale(target: Vector2):
	var tween = get_tree().create_tween().bind_node(self)
	tween.set_trans(Tween.TRANS_QUAD)   
	tween.set_ease(Tween.EASE_OUT)     
	tween.tween_property(self, "rect_scale", target, 0.1)


