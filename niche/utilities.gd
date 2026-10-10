extends Node

class_name u

static func int_min(n1: int, n2: int):
	if n1 < n2:
		return n1
	return n2

static func frames(n, fps = 60):
	return (n / float(fps))



static func fade_in(node: Node):
	node.modulate.a = 0.0
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.1)
