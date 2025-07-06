# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func can_handle_vector3(object: Object, property: Dictionary, flags: int) -> bool:
	return property.type == TYPE_VECTOR3

static func can_handle_vector3i(object: Object, property: Dictionary, flags: int) -> bool:
	return property.type == TYPE_VECTOR3I


static func create_vector3(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle_vector3(object, property, flags), "Can't handle property!")
	return _create(object, property, setter, getter, flags)

static func create_vector3i(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle_vector3i(object, property, flags), "Can't handle property!")
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

	var value: Vector3 = getter.call()

	var x_spin := create_spin_box()
	x_spin.set_editable(setter.is_valid())
	x_spin.set_name("X")
	x_spin.set_prefix("x")
	x_spin.set_min(DEFAULT_MIN)
	x_spin.set_max(DEFAULT_MAX)
	x_spin.set_step(1.0 if property.type == TYPE_VECTOR3I else 0.001)
	x_spin.set_use_rounded_values(property.type == TYPE_VECTOR3I)
	x_spin.set_value_no_signal(value.x)
	box.add_child(x_spin)

	var y_spin: SpinBox = x_spin.duplicate()
	y_spin.set_name("Y")
	y_spin.set_prefix("y")
	y_spin.set_value_no_signal(value.y)
	box.add_child(y_spin)

	var z_spin: SpinBox = x_spin.duplicate()
	z_spin.set_name("Z")
	z_spin.set_prefix("z")
	z_spin.set_value_no_signal(value.z)
	box.add_child(z_spin)

	var callback: Callable
	if property.type == TYPE_VECTOR3I:
		callback = func(_value) -> void:
			setter.call(Vector3i(
					x_spin.get_value(),
					y_spin.get_value(),
					z_spin.get_value(),
				)
			)

			var current: Vector3i = getter.call()
			x_spin.set_value_no_signal(current.x)
			y_spin.set_value_no_signal(current.y)
			z_spin.set_value_no_signal(current.z)
	else:
		callback = func(_value) -> void:
			setter.call(Vector3(
					x_spin.get_value(),
					y_spin.get_value(),
					z_spin.get_value(),
				)
			)

			var current: Vector3 = getter.call()
			x_spin.set_value_no_signal(current.x)
			y_spin.set_value_no_signal(current.y)
			z_spin.set_value_no_signal(current.z)
	x_spin.value_changed.connect(callback)
	y_spin.value_changed.connect(callback)
	z_spin.value_changed.connect(callback)

	return wrap_property_editor(flags | FLAG_VERTICAL, box, object, property)
