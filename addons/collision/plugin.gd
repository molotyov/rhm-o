
tool
extends EditorPlugin

var selected_nodes = []

func _enter_tree():
	connect("scene_changed", self, "_on_scene_changed")

func handles(object) -> bool:
	return object is CollisionBox

func make_visible(visible: bool):
	pass

func _on_scene_changed(scene):
	_deselect_all()

func forward_canvas_gui_input(event):
	_update_selection()
	return false

func _process(delta):
	_update_selection()

func _update_selection():
	_deselect_all()
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	for node in selection:
		if node is CollisionBox or node is Hitbox:
			node.editor_selected = true
			node.update()

func _deselect_all():
	var root = get_editor_interface().get_edited_scene_root()
	if not root:
		return
	for node in _get_all_children(root):
		if node is CollisionBox or node is Hitbox:
			node.editor_selected = false

func _get_all_children(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		result.append(child)
		result += _get_all_children(child)
	return result

# res://addons/collision_box_selector/plugin.cfg
