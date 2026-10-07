class_name MemeRng
extends RefCounted

const MASK: int = 0xFFFFFFFF
const ZERO_REMAP: int = 0x6D2B79F5
const UINT32_RANGE: int = 4294967296

var state: int = ZERO_REMAP
var rng_index: int = 0

func _init(seed: int = 1) -> void:
	reset(seed)

func reset(seed: int) -> void:
	state = seed & MASK
	if state == 0:
		state = ZERO_REMAP
	rng_index = 0

func next_u32() -> int:
	var x: int = state
	x = x ^ ((x << 13) & MASK)
	x = x ^ (x >> 17)
	x = x ^ ((x << 5) & MASK)
	state = x & MASK
	rng_index += 1
	return state

func bounded(n: int) -> int:
	assert(n > 0)
	var limit: int = UINT32_RANGE - (UINT32_RANGE % n)
	while true:
		var value: int = next_u32()
		if value < limit:
			return value % n
	return 0

func shuffle_array(values: Array) -> Array:
	var result: Array = values.duplicate(true)
	for i in range(result.size() - 1, 0, -1):
		var j: int = bounded(i + 1)
		var tmp = result[i]
		result[i] = result[j]
		result[j] = tmp
	return result

func snapshot() -> Dictionary:
	return {"rng_version": "xorshift32-v1", "rng_state": state, "rng_index": rng_index}
