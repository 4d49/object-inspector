# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [Vector2] or [Vector2i] property.
extends "../property_handler.gd"


const INT32_MIN: int = -2147483648
const INT32_MAX: int =  2147483647


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)

	var box: BoxContainer = null
	if property.type == TYPE_VECTOR2:
		box = create_vector2_control(setter, getter)
	else:
		box = create_vector2i_control(setter, getter)

	box.set_h_size_flags(Control.SIZE_EXPAND_FILL)

	var label: Label = create_flow_container(property.name, box).get_node(^"Label")
	label.set_v_size_flags(Control.SIZE_SHRINK_BEGIN)


static func _static_init() -> void:
	InspectorPropertyType.register_type(TYPE_VECTOR2, "Vector2", create_vector2_control)
	InspectorPropertyType.register_type(TYPE_VECTOR2I, "Vector2i", create_vector2i_control)


static func _create_vector2_control(setter: Callable, getter: Callable, is_vector2i: bool) -> BoxContainer:
	var box := BoxContainer.new()
	box.set_h_size_flags(Control.SIZE_EXPAND_FILL)

	var value: Vector2 = getter.call()

	var x_spin := SpinBox.new()
	x_spin.set_editable(setter.is_valid())
	x_spin.set_name("X")
	x_spin.set_prefix("x")
	x_spin.set_min(INT32_MIN)
	x_spin.set_max(INT32_MAX)
	x_spin.set_step(1.0 if is_vector2i else 0.001)
	x_spin.set_use_rounded_values(is_vector2i)
	x_spin.set_value_no_signal(value.x)
	x_spin.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	box.add_child(x_spin)

	var y_spin: SpinBox = x_spin.duplicate()
	y_spin.set_name("Y")
	y_spin.set_prefix("y")
	y_spin.set_value_no_signal(value.y)
	box.add_child(y_spin)

	var value_changed: Callable
	if is_vector2i:
		value_changed = func(_value) -> void:
			setter.call(Vector2i(x_spin.get_value(), y_spin.get_value()))
			var vector2i: Vector2i = getter.call()

			x_spin.set_value_no_signal(vector2i.x)
			y_spin.set_value_no_signal(vector2i.y)
	else:
		value_changed = func(_ve) -> void:
			setter.call(Vector2(x_spin.get_value(), y_spin.get_value()))
			var vector2: Vector2 = getter.call()

			x_spin.set_value_no_signal(value.x)
			y_spin.set_value_no_signal(value.y)

	x_spin.value_changed.connect(value_changed)
	y_spin.value_changed.connect(value_changed)

	return box


static func create_vector2_control(setter: Callable, getter: Callable) -> BoxContainer:
	return _create_vector2_control(setter, getter, false)


static func create_vector2i_control(setter: Callable, getter: Callable) -> BoxContainer:
	return _create_vector2_control(setter, getter, true)


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.type == TYPE_VECTOR2 or property.type == TYPE_VECTOR2I
