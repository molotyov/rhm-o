extends Node

class_name g 

var fixed = FixedMath.new()

func _ready():
	var result = fixed.abs("-1")
	print(result)
