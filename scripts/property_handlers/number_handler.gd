# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func can_handle_int(object: Object, property: Dictionary, flags: int) -> bool:
	return property.type == TYPE_INT

static func can_handle_float(object: Object, property: Dictionary, flags: int) -> bool:
	return property.type == TYPE_FLOAT


static func create_int(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle_int(object, property, flags), "Can't handle property!")
	return _create(object, property, setter, getter, flags)

static func create_float(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle_float(object, property, flags), "Can't handle property!")
	return _create(object, property, setter, getter, flags)


static func parse_hint_string(hint_string: String) -> Dictionary[StringName, float]:
	const DEFAULT_MIN: int = -2147483648
	const DEFAULT_MAX: int =  2147483647
	const DEFAULT_STEP: float = 0.001

	var values: PackedFloat32Array = [DEFAULT_MIN, DEFAULT_MAX, DEFAULT_STEP]

	var split: PackedStringArray = hint_string.split(",")
	for i: int in mini(3, split.size()):
		if split[i].is_valid_float():
			values[i] = split[i].to_float()

	return {&"min": values[0], &"max": values[1], &"step": values[2]}

static func _create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	var params := parse_hint_string(property.hint_string)

	var spin_box := create_spin_box()
	spin_box.set_min(minf(params.min, params.max))
	spin_box.set_max(maxf(params.max, params.min))
	spin_box.set_use_rounded_values(property.type == TYPE_INT)

	if setter.is_valid():
		var callback: Callable
		if property.type == TYPE_INT:
			callback = func(value: int) -> void:
				setter.call(value)
				spin_box.set_value_no_signal(getter.call())
		else:
			callback = func(value: float) -> void:
				setter.call(value)
				spin_box.set_value_no_signal(getter.call())
		spin_box.value_changed.connect(callback)
	else:
		spin_box.set_editable(false)

	if property.type == TYPE_INT:
		params.step = maxf(roundf(params.step), 1.0)

	spin_box.set_step(params.step)
	spin_box.set_value_no_signal(getter.call())

	return wrap_property_editor(flags, spin_box, object, property)
