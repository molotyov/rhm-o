class_name FixedVec2

const SHIFT = 16
const SCALE = 1 << SHIFT

var x: int
var y: int

func _init(_x: int = 0, _y: int = 0):
	x = _x
	y = _y
	
func normalized() -> Reference:  # ✅ Reference instead of FixedVec2
	var len_sq = (x * x + y * y) >> SHIFT
	if len_sq == 0:
		return load("res://fixed/FixedVec2.gd").new(0, 0)  # ✅ load() instead of FixedVec2.new()
	var length = square_root_integer(len_sq)
	var nx = (x << SHIFT) / length
	var ny = (y << SHIFT) / length
	return load("res://fixed/FixedVec2.gd").new(nx, ny)  # ✅


static func from_string(xs: String, ys: String) -> Reference:  
	var fx = int(float(xs) * SCALE)
	var fy = int(float(ys) * SCALE)
	return load("res://fixed/FixedVec2.gd").new(fx, fy)  

static func from_floats(fx: float, fy: float) -> Reference:
	return load("res://fixed/FixedVec2.gd").new(int(fx * SCALE), int(fy * SCALE))

static func to_float(x: int, y: int) -> float:
	var fx = float(int(x) * SCALE)
	var fy = float(int(y) * SCALE)
	return load("res://fixed/FixedVec2.gd").new(fx, fy)  

static func coords(x, y) -> Reference:
	return load("res://fixed/FixedVec2.gd").new(
		to_fixed(x),
		to_fixed(y)
	)

static func to_fixed(val) -> int:
	if val is float:
		return int(val * SCALE)
	elif val is int:
		return val << SHIFT
	elif val is String:
		return int(float(val) * SCALE)
	else:
		return 0


func round():
	var f = to_float(x,y)
	var nx = f.x.round()
	var ny = f.y.round()
	return load("res://fixed/FixedVec2.gd").new(nx,ny)


func to_string() -> String:  
	return "(%s, %s)" % [float(x) / SCALE, float(y) / SCALE]

func length_squared() -> int:  # ✅ fine
	return (x * x + y * y) >> SHIFT


static func square_root_integer(n: int) -> int:
	if n < 0: return 0
	var x0 = n
	var x1 = (x0 + 1) >> 1
	while x1 < x0:
		x0 = x1
		x1 = (x0 + n / x0) >> 1
	return x0

func vec_add(other: Reference) -> Reference:
	return load("res://FixedVec2.gd").new(x + other.x, y + other.y)

func add_to(other: Reference) -> void:
	x += other.x
	y += other.y
