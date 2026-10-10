tool

extends CollisionBox

class_name Hitbox, "res://niche/node_icons2.png"

const COMBO_PUSHBACK_COEFFICIENT = "0.4"
const COMBO_SAME_MOVE_KNOCKBACK_INCREASE_AMOUNT_GROUNDED = "1.25"
const COMBO_SAME_MOVE_KNOCKBACK_INCREASE_AMOUNT_AERIAL = "1.05"
const COMBO_SAME_MOVE_HITSTUN_DECREASE_AMOUNT = 1
const PRORATION_HITSTUN_ADJUSTMENT_AMOUNT = 0

const MAX_KNOCKBACK = "30"
var active = false
var enabled = false
var host
var already_hit_objects = []



enum HitboxType{
	Normal, 
}


signal hit_something(obj, hitbox)
signal got_parried()
signal got_blocked()



export  var activated = true

export  var _c_Damage = 0
export  var damage: int = 0
export  var damage_in_combo: int = - 1
export  var minimum_damage: int = 0
export  var chip_damage_modifier = "1.0"
export  var _c_Fuck_You = 0
export var start_frame: int = 0
export var active_frames: int = 0

export var _c_Hit = 0
export var hitstun_ticks = 0
export var hitlag_ticks = 0
export var hits_grounded_opponent = true
export var hits_aerial_opponent = true
export var queue_state = ""

export var _c_Knockback = 0
export var knockback_x: String = "1"
export var knockback_y: String = "-1"
export var knockback_multiplier: String = "10"


func activate_hitbox():
	print("worked af22")

	if active:
		return
	already_hit_objects = []
	if host:
		update_position(host.get_pos().x, host.get_pos().y)
	active = true
	enabled = true


func deactivate_hitbox():
	if active == false:
		return
	active = false
	enabled = false


func hit(thing):
	if thing.is_in_group("Character") and not thing.name in already_hit_objects:
		print("worked af")


func _process(delta):
	if host:
		update_position(host.get_pos().x * x_facing(), host.get_pos().y)

func can_draw_box():
	return (active and enabled)
	
