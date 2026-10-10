
class_name FixedMath

const SHIFT = 16
const SCALE = 1 << SHIFT
const FixedVec2String = preload("res://fixed/FixedVec2String.gd")
const FixedVec2 = preload("res://fixed/FixedVec2.gd")

static func from_float(n: float) -> int:
	return int(n * SCALE)

static func to_float(f: int) -> float:
	return float(f) / SCALE

static func from_string(s: String) -> int:
	return int(float(s) * SCALE)

static func fixed_to_string(f:int) -> String:
	return str(float(f) / (1 << SHIFT))

static func add(x: String, y: String) -> String:
	return fixed_to_string(from_string(x) + from_string(y))

static func sub(x: String, y: String) -> String:
	return fixed_to_string(from_string(x) - from_string(y))

static func mul(x: String, y: String) -> String:
	return fixed_to_string((from_string(x) * from_string(y)) >> SHIFT)

static func div(x: String, y: String) -> String:
	var _y = from_string(y)
	if _y == 0: return "0"
	return fixed_to_string((from_string(x) << SHIFT) / _y)

static func normalized_vec(x: String, y: String) -> FixedVec2String:
	var fx = int(float(x) * (1 << 16))
	var fy = int(float(y) * (1 << 16))
	var len_sq = (fx * fx + fy * fy) >> 16
	if len_sq == 0:
		return FixedVec2String.new("0", "0")
	var length = square_root_integer(len_sq)
	var nx = (fx << 16) / length
	var ny = (fy << 16) / length
	return FixedVec2String.new(
		str(float(nx) / (1 << 16)),
		str(float(ny) / (1 << 16))
	)

static func square_root_integer(n: int) -> int:
	if n < 0: return 0
	var x0 = n
	var x1 = (x0 + 1) >> 1
	while x1 < x0:
		x0 = x1
		x1 = (x0 + n / x0) >> 1
	return x0

func normalized_vec_times(x: String ,y: String, magnitude: String) -> FixedVec2String:
	var vec = load("res://fixed/FixedVec2.gd").from_string(x,y)
	var norm = vec.normalized()
	var ma = from_string(magnitude)
	var rx = (norm.x * ma) >> SHIFT
	var ry = (norm.y * ma) >> SHIFT
	
	return FixedVec2String.new(
		str(float(rx) / SCALE),
		str(float(ry) / SCALE)
	)

func vec_mul(x: String ,y: String, r: String) -> FixedVec2String:
	var vec = load("res://fixed/FixedVec2.gd").from_string(x,y)
	var ma = from_string(r)
	var rx = (vec.x * ma) >> SHIFT
	var ry = (vec.y * ma) >> SHIFT
	
	return FixedVec2String.new(
		str(float(rx) / SCALE),
		str(float(ry) / SCALE)
	
	)

func vec_div(x: String ,y: String, r: String) -> FixedVec2String:
	var vec = load("res://fixed/FixedVec2.gd").from_string(x,y)
	var ma = from_string(r)
	var rx = (vec.x << SHIFT) / ma
	var ry = (vec.y << SHIFT) / ma
	
	return FixedVec2String.new(
		str(float(rx) / SCALE),
		str(float(ry) / SCALE)
	
	)

func round(value: String) -> float:
	var f = from_string(value)
	return round(to_float(f))

func abs(n: String) -> String:
	var fixed = from_string(n)
	if fixed < 0:
		fixed = -fixed
	return fixed_to_string(fixed)

func sign(a: String) -> int:
	return int(sign(from_string(a)))
