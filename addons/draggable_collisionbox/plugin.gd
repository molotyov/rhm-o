tool
extends EditorPlugin

# --- Behavior knobs ---
const HANDLE_PX := 7.0          # handle hit radius in screen pixels
const EDGE_PX := 6.0            # edge hit thickness in screen pixels
const MIN_SIZE := 1.0           # minimum width/height in local units
const DRAW_HANDLES := true

const COLOR_DEFAULT := Color(0.2, 0.9, 1.0, 0.9)
const COLOR_SHIFT := Color.orange
const COLOR_CTRL := Color.greenyellow
const COLOR_BOTH := Color.slategray

enum DragMode {
	NONE,
	MOVE, MOVE_RAY,
	RESIZE_L, RESIZE_R, RESIZE_T, RESIZE_B,
	RESIZE_TL, RESIZE_TR, RESIZE_BL, RESIZE_BR
}

var _selection: EditorSelection
var _active: Node = null

var _drag_mode = DragMode.NONE
var _dragging := false
var _shift_held := false
var _ctrl_held := false

var _start_x := 0.0
var _start_y := 0.0
var _start_w := 0.0
var _start_h := 0.0

var _start_mouse_local := Vector2.ZERO

func _enter_tree() -> void:
	_selection = get_editor_interface().get_selection()
	if _selection and not _selection.is_connected("selection_changed", self, "_on_selection_changed"):
		_selection.connect("selection_changed", self, "_on_selection_changed")

	set_force_draw_over_forwarding_enabled()
	_on_selection_changed()

func _exit_tree() -> void:
	if _selection and _selection.is_connected("selection_changed", self, "_on_selection_changed"):
		_selection.disconnect("selection_changed", self, "_on_selection_changed")

func handles(object: Object) -> bool:
	return _is_collision_box(object)

func _on_selection_changed() -> void:
	_active = _get_single_selected_node()
	_dragging = false
	_shift_held = false
	_ctrl_held = false
	_drag_mode = DragMode.NONE
	update_overlays()
	
func forward_canvas_gui_input(event: InputEvent) -> bool:
	if not _is_collision_box(_active):
		return false
	
	if event is InputEventKey and event.scancode == KEY_SHIFT:
		_shift_held = event.pressed
		
	if event is InputEventKey and event.scancode == KEY_CONTROL:
		_ctrl_held = event.pressed
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			return _begin_drag(event.position)
		else:
			if _dragging:
				_end_drag()
				return true
			return false

	if event is InputEventMouseMotion:
		if _dragging:
			_update_drag(event.position, _shift_held, _ctrl_held)
			update_overlays()
			return true
		else:
			# Redraw for hover feedback if you add it later.
			update_overlays()
			return false

	return false

func forward_canvas_draw_over_viewport(overlay: Control) -> void:
	if not _is_collision_box(_active):
		return

	var xform := _get_canvas_xform(_active)
	if xform == null:
		return

	var rect_screen := _get_rect_screen(_active, xform)
	# Draw outline
	overlay.draw_rect(rect_screen, _get_color(), false, 2.0)
	if DRAW_HANDLES:
	
		for p in _get_handle_points_screen(rect_screen):
			overlay.draw_circle(p, HANDLE_PX, _get_color())
			overlay.draw_circle(p, HANDLE_PX - 2.0, Color(0.05, 0.05, 0.05, 0.9))
		
func _get_canvas_xform(n: Node2D) -> Transform2D:
	return n.get_viewport_transform()

func _get_rect_local(n: Node) -> Rect2:
	var cx := float(n.get("x"))
	var cy := float(n.get("y"))
	var w := float(n.get("width"))
	var h := float(n.get("height"))
	return Rect2(Vector2(cx - w, cy - h), Vector2(w*2, h*2))

func _local_to_screen(n: Node, canvas_xform: Transform2D, local_p: Vector2) -> Vector2:
	var global_p := (n as Node2D).to_global(local_p)
	return canvas_xform.xform(global_p)

func _screen_to_local(n: Node, canvas_xform: Transform2D, screen_p: Vector2) -> Vector2:
	var global_p = canvas_xform.affine_inverse().xform(screen_p)
	return (n as Node2D).to_local(global_p)

func _get_rect_screen(n: Node, canvas_xform: Transform2D) -> Rect2:
	var r := _get_rect_local(n)

	# Convert 4 corners to screen; build a screen-space AABB (safe for scale; assumes no rotation as requested).
	var p0 := _local_to_screen(n, canvas_xform, r.position)
	var p1 := _local_to_screen(n, canvas_xform, r.position + Vector2(r.size.x, 0))
	var p2 := _local_to_screen(n, canvas_xform, r.position + Vector2(0, r.size.y))
	var p3 := _local_to_screen(n, canvas_xform, r.position + r.size)

	var minx := min(min(p0.x, p1.x), min(p2.x, p3.x))
	var maxx := max(max(p0.x, p1.x), max(p2.x, p3.x))
	var miny := min(min(p0.y, p1.y), min(p2.y, p3.y))
	var maxy := max(max(p0.y, p1.y), max(p2.y, p3.y))

	return Rect2(Vector2(minx, miny), Vector2(maxx - minx, maxy - miny))

func _get_handle_points_screen(rs: Rect2) -> Array:
	var tl := rs.position
	var tr := rs.position + Vector2(rs.size.x, 0)
	var bl := rs.position + Vector2(0, rs.size.y)
	var br := rs.position + rs.size
	var tm := rs.position + Vector2(rs.size.x * 0.5, 0)
	var bm := rs.position + Vector2(rs.size.x * 0.5, rs.size.y)
	var lm := rs.position + Vector2(0, rs.size.y * 0.5)
	var rm := rs.position + Vector2(rs.size.x, rs.size.y * 0.5)
	return [tl, tm, tr, rm, br, bm, bl, lm]

func _begin_drag(mouse_screen: Vector2) -> bool:
	var xform := _get_canvas_xform(_active)
	if xform == null:
		return false

	var rect_screen := _get_rect_screen(_active, xform)
	var mode := _pick_drag_mode(mouse_screen, rect_screen)
	if mode == DragMode.NONE:
		return false

	_drag_mode = mode
	_dragging = true

	_start_x = int(_active.get("x"))
	_start_y = int(_active.get("y"))
	_start_w = int(_active.get("width"))
	_start_h = int(_active.get("height"))
	
	_start_mouse_local = _screen_to_local(_active, xform, mouse_screen)

	return true

func _update_drag(mouse_screen: Vector2, shift_held: bool, ctrl_held: bool) -> void:
	var xform := _get_canvas_xform(_active)
	if xform == null:
		return

	var mouse_local := _screen_to_local(_active, xform, mouse_screen)
	var delta := mouse_local - _start_mouse_local

	var new_x := _start_x
	var new_y := _start_y
	var new_w := _start_w
	var new_h := _start_h
	
	var shift_mod_for :float= 1.0 if shift_held else 0.5
	var shift_mod_against :float= 0.0 if shift_held else 0.5
	
	var current_aspect_ratio = max(_start_w, 1) / max(_start_h, 1)
	
	match _drag_mode:
		DragMode.MOVE:
			new_x += delta.x
			new_y += delta.y

		DragMode.RESIZE_R:
			new_w += int(delta.x * shift_mod_for)
			new_x += int(delta.x * shift_mod_against)
			if ctrl_held:
				new_h += int(delta.x * shift_mod_for / current_aspect_ratio)
			
		DragMode.RESIZE_L:
			new_w -= int(delta.x * shift_mod_for)
			new_x += int(delta.x * shift_mod_against)
			if ctrl_held:
				new_h -= int(delta.x * shift_mod_for / current_aspect_ratio)
				
		DragMode.RESIZE_B:
			new_h += int(delta.y * shift_mod_for)
			new_y += int(delta.y * shift_mod_against)
			if ctrl_held:
				new_w += int(delta.y * shift_mod_for / current_aspect_ratio)

		DragMode.RESIZE_T:
			new_h -= int(delta.y * shift_mod_for)
			new_y += int(delta.y * shift_mod_against)
			if ctrl_held:
				new_w -= int(delta.y * shift_mod_for / current_aspect_ratio)

		DragMode.RESIZE_TR:
			if ctrl_held:
				new_w += int(delta.x * shift_mod_for)
				new_h += int(delta.x * shift_mod_for / current_aspect_ratio)
				new_x += int(delta.x * shift_mod_against)
				new_y -= int(delta.x * shift_mod_against / current_aspect_ratio)
				continue
			new_w += int(delta.x * shift_mod_for)
			new_x += int(delta.x * shift_mod_against)
			new_h -= int(delta.y * shift_mod_for)
			new_y += int(delta.y * shift_mod_against)
			
		DragMode.RESIZE_TL:
			if ctrl_held:
				new_w -= int(delta.x * shift_mod_for)
				new_h -= int(delta.x * shift_mod_for / current_aspect_ratio)
				new_x += int(delta.x * shift_mod_against)
				new_y += int(delta.x * shift_mod_against / current_aspect_ratio)
				continue
			new_w -= int(delta.x * shift_mod_for)
			new_x += int(delta.x * shift_mod_against)
			new_h -= int(delta.y * shift_mod_for)
			new_y += int(delta.y * shift_mod_against)

		DragMode.RESIZE_BR:
			if ctrl_held:
				new_w += int(delta.x * shift_mod_for)
				new_h += int(delta.x * shift_mod_for / current_aspect_ratio)
				new_x += int(delta.x * shift_mod_against)
				new_y += int(delta.x * shift_mod_against / current_aspect_ratio)
				continue
			new_w += int(delta.x * shift_mod_for)
			new_x += int(delta.x * shift_mod_against)
			new_h += int(delta.y * shift_mod_for)
			new_y += int(delta.y * shift_mod_against)

		DragMode.RESIZE_BL:
			if ctrl_held:
				new_w -= int(delta.x * shift_mod_for)
				new_h -= int(delta.x * shift_mod_for / current_aspect_ratio)
				new_x += int(delta.x * shift_mod_against)
				new_y -= int(delta.x * shift_mod_against / current_aspect_ratio)
				continue
			new_w -= int(delta.x * shift_mod_for)
			new_x += int(delta.x * shift_mod_against)
			new_h += int(delta.y * shift_mod_for)
			new_y += int(delta.y * shift_mod_against)

		_:
			pass

	if new_w < MIN_SIZE:
		new_w = MIN_SIZE
	if new_h < MIN_SIZE:
		new_h = MIN_SIZE
		
	_active.set("x", new_x)
	_active.set("y", new_y)
	_active.set("width", new_w)
	_active.set("height", new_h)
	
func _end_drag() -> void:
	_dragging = false
#	_shift_held = false
#	_ctrl_held = false
	
	var end_x := int(_active.get("x"))
	var end_y := int(_active.get("y"))
	var end_w := int(_active.get("width"))
	var end_h := int(_active.get("height"))

	var ur := get_undo_redo()
	ur.create_action("Edit CollisionBox (drag)")
	ur.add_do_property(_active, "x", end_x)
	ur.add_do_property(_active, "y", end_y)
	ur.add_do_property(_active, "width", end_w)
	ur.add_do_property(_active, "height", end_h)
	ur.add_do_method(_active, "property_list_changed_notify")
	
	ur.add_undo_property(_active, "x", _start_x)
	ur.add_undo_property(_active, "y", _start_y)
	ur.add_undo_property(_active, "width", _start_w)
	ur.add_undo_property(_active, "height", _start_h)
	ur.add_undo_method(_active, "property_list_changed_notify")
	ur.commit_action()
	
	_drag_mode = DragMode.NONE
	update_overlays()

func _pick_drag_mode(mouse: Vector2, rs: Rect2) -> int:
	var tl := rs.position
	var tr := rs.position + Vector2(rs.size.x, 0)
	var bl := rs.position + Vector2(0, rs.size.y)
	var br := rs.position + rs.size
	var tm := rs.position + Vector2(rs.size.x * 0.5, 0)
	var bm := rs.position + Vector2(rs.size.x * 0.5, rs.size.y)
	var lm := rs.position + Vector2(0, rs.size.y * 0.5)
	var rm := rs.position + Vector2(rs.size.x, rs.size.y * 0.5)

	if mouse.distance_to(tl) <= HANDLE_PX: return DragMode.RESIZE_TL
	if mouse.distance_to(tr) <= HANDLE_PX: return DragMode.RESIZE_TR
	if mouse.distance_to(bl) <= HANDLE_PX: return DragMode.RESIZE_BL
	if mouse.distance_to(br) <= HANDLE_PX: return DragMode.RESIZE_BR
	if mouse.distance_to(tm) <= HANDLE_PX: return DragMode.RESIZE_T
	if mouse.distance_to(bm) <= HANDLE_PX: return DragMode.RESIZE_B
	if mouse.distance_to(lm) <= HANDLE_PX: return DragMode.RESIZE_L
	if mouse.distance_to(rm) <= HANDLE_PX: return DragMode.RESIZE_R

	var left_dist := abs(mouse.x - rs.position.x)
	var right_dist := abs(mouse.x - (rs.position.x + rs.size.x))
	var top_dist := abs(mouse.y - rs.position.y)
	var bot_dist := abs(mouse.y - (rs.position.y + rs.size.y))

	var inside_x := mouse.x >= rs.position.x and mouse.x <= rs.position.x + rs.size.x
	var inside_y := mouse.y >= rs.position.y and mouse.y <= rs.position.y + rs.size.y
	var inside := inside_x and inside_y

	if inside_y and left_dist <= EDGE_PX: return DragMode.RESIZE_L
	if inside_y and right_dist <= EDGE_PX: return DragMode.RESIZE_R
	if inside_x and top_dist <= EDGE_PX: return DragMode.RESIZE_T
	if inside_x and bot_dist <= EDGE_PX: return DragMode.RESIZE_B

	if inside:
		return DragMode.MOVE

	return DragMode.NONE

func _get_single_selected_node() -> Node:
#	if not _selection:
#		return null
	var nodes := get_editor_interface().get_selection().get_selected_nodes()
	if nodes.empty():
		return null
	return nodes[0]

func _is_collision_box(o: Object) -> bool:
	if o == null:
		return false
	if not (o is Node2D):
		return false

	var n := o as Node
	var has_fields := ("x" in n) and ("y" in n) and ("width" in n) and ("height" in n)

	if not has_fields:
		return false

	return true
	
# VISUALS
func _get_color() -> Color:
	if _ctrl_held and _shift_held:
		return COLOR_BOTH
	if _ctrl_held:
		return COLOR_CTRL
	if _shift_held:
		return COLOR_SHIFT
	return COLOR_DEFAULT
