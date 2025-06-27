# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


const DEFAULT_MIN: int = -2147483648
const DEFAULT_MAX: int =  2147483647


@warning_ignore_start("untyped_declaration", "narrowing_conversion", "confusable_local_declaration")
static func create_vector3_editor(
		setter: Callable,
		getter: Callable,
		property: Dictionary,
	) -> BoxContainer:

	var box := BoxContainer.new()
	box.set_h_size_flags(Control.SIZE_EXPAND_FILL)

	var value: Vector3 = getter.call()

	var x_spin := SpinBox.new()
	x_spin.set_editable(setter.is_valid())
	x_spin.set_name("X")
	x_spin.set_prefix("x")
	x_spin.set_min(DEFAULT_MIN)
	x_spin.set_max(DEFAULT_MAX)
	x_spin.set_step(1.0 if property.type == TYPE_VECTOR3I else 0.001)
	x_spin.set_use_rounded_values(property.type == TYPE_VECTOR3I)
	x_spin.set_value_no_signal(value.x)
	x_spin.set_h_size_flags(Control.SIZE_EXPAND_FILL)
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

	return box


static func can_handle(object: Object, property: Dictionary) -> bool:
	const VALID_TYPES: PackedInt32Array = [
		TYPE_VECTOR3,
		TYPE_VECTOR3I,
	]

	return property.type in VALID_TYPES


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
	) -> Control:

	assert(can_handle(object, property), "Can't handle property!")

	var description := get_property_description(object, property.name)
	var vector3_editor := create_vector3_editor(setter, getter, property)
	var flow_container := create_flow_container(property.name, vector3_editor)

	return create_property_panel(description, flow_container)
