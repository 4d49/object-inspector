# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func can_handle_vector2(object: Object, property: Dictionary, flags: int) -> bool:
	return property.type == TYPE_VECTOR2

static func can_handle_vector2i(object: Object, property: Dictionary, flags: int) -> bool:
	return property.type == TYPE_VECTOR2I


static func create_vector2(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle_vector2(object, property, flags), "Can't handle property!")
	return _create(object, property, setter, getter, flags)

static func create_vector2i(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle_vector2i(object, property, flags), "Can't handle property!")
	return _create(object, property, setter, getter, flags)


static func _create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:


	const DEFAULT_MIN: int = -2147483648
	const DEFAULT_MAX: int =  2147483647

	var box := BoxContainer.new()
	box.set_h_size_flags(Control.SIZE_EXPAND_FILL)

	var value: Vector2 = getter.call()

	var x_spin := SpinBox.new()
	x_spin.set_editable(setter.is_valid())
	x_spin.set_name("X")
	x_spin.set_prefix("x")
	x_spin.set_min(DEFAULT_MIN)
	x_spin.set_max(DEFAULT_MAX)
	x_spin.set_step(1.0 if property.type == TYPE_VECTOR2I else 0.001)
	x_spin.set_use_rounded_values(property.type == TYPE_VECTOR2I)
	x_spin.set_value_no_signal(value.x)
	x_spin.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	box.add_child(x_spin)

	var y_spin: SpinBox = x_spin.duplicate()
	y_spin.set_name("Y")
	y_spin.set_prefix("y")
	y_spin.set_value_no_signal(value.y)
	box.add_child(y_spin)

	var callback: Callable
	if property.type == TYPE_VECTOR2I:
		callback = func(_value) -> void:
			setter.call(Vector2i(x_spin.get_value(), y_spin.get_value()))

			var current: Vector2i = getter.call()
			x_spin.set_value_no_signal(current.x)
			y_spin.set_value_no_signal(current.y)
	else:
		callback = func(_value) -> void:
			setter.call(Vector2(x_spin.get_value(), y_spin.get_value()))

			var current: Vector2 = getter.call()
			x_spin.set_value_no_signal(current.x)
			y_spin.set_value_no_signal(current.y)
	x_spin.value_changed.connect(callback)
	y_spin.value_changed.connect(callback)

	return wrap_property_editor(flags, box, object, property)
