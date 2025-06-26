# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [Vector3] or [Vector3i] property.
extends "../property_handler.gd"


const INT32_MIN: int = -2147483648
const INT32_MAX: int =  2147483647


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)

	var box: BoxContainer = null
	if property.type == TYPE_VECTOR3I:
		box = create_vector3i_control(setter, getter)
	else:
		box = create_vector3_control(setter, getter)

	create_flow_container(property.name, box).add_to_group(&"vertical")


static func _static_init() -> void:
	InspectorPropertyType.register_type(TYPE_VECTOR3, "Vector3", create_vector3_control)
	InspectorPropertyType.register_type(TYPE_VECTOR3I, "Vector3i", create_vector3i_control)


static func _create_vector3_control(setter: Callable, getter: Callable, is_vector3i: bool) -> BoxContainer:
	var box := BoxContainer.new()
	box.add_to_group(&"vertical")

	var value: Vector3 = getter.call()

	var x_spin := SpinBox.new()
	x_spin.set_editable(setter.is_valid())
	x_spin.set_name("X")
	x_spin.set_prefix("x")
	x_spin.set_min(INT32_MIN)
	x_spin.set_max(INT32_MAX)
	x_spin.set_step(1.0 if is_vector3i else 0.001)
	x_spin.set_use_rounded_values(is_vector3i)
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

	var on_value_changed: Callable
	if is_vector3i:
		on_value_changed = func(_value) -> void:
			setter.call(Vector3i(x_spin.get_value(), y_spin.get_value(), z_spin.get_value()))
			var vector3i: Vector3i = getter.call()

			x_spin.set_value_no_signal(vector3i.x)
			y_spin.set_value_no_signal(vector3i.y)
			z_spin.set_value_no_signal(vector3i.z)
	else:
		on_value_changed = func(_value) -> void:
			setter.call(Vector3(x_spin.get_value(), y_spin.get_value(), z_spin.get_value()))
			var vector3: Vector3 = getter.call()

			x_spin.set_value_no_signal(value.x)
			y_spin.set_value_no_signal(value.y)
			z_spin.set_value_no_signal(value.z)

	x_spin.value_changed.connect(on_value_changed)
	y_spin.value_changed.connect(on_value_changed)
	z_spin.value_changed.connect(on_value_changed)

	return box


static func create_vector3_control(setter: Callable, getter: Callable) -> BoxContainer:
	return _create_vector3_control(setter, getter, false)


static func create_vector3i_control(setter: Callable, getter: Callable) -> BoxContainer:
	return _create_vector3_control(setter, getter, true)


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.type == TYPE_VECTOR3 or property.type == TYPE_VECTOR3I
