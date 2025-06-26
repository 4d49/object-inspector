# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [int] or [float] property.
extends "../property_handler.gd"


# Magic numbers, but otherwise the SpinBox does not work correctly.
const INT32_MIN: int = -2147483648
const INT32_MAX: int =  2147483647


var spin_box: SpinBox = null


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)

	if property.type == TYPE_INT:
		spin_box = create_int_control(setter, getter)
	else:
		spin_box = create_float_control(setter, getter)

	if property.hint == PROPERTY_HINT_RANGE:
		var split: PackedStringArray = get_hint_string().split(',', false)

		spin_box.set_min(split[0].to_float() if split.size() >= 1 and split[0].is_valid_float() else float(INT32_MIN))
		spin_box.set_max(split[1].to_float() if split.size() >= 2 and split[1].is_valid_float() else float(INT32_MIN))
		spin_box.set_step(split[2].to_float() if split.size() >= 3 and split[2].is_valid_float() else 1.0 if property.type == TYPE_INT else 0.001)

	create_flow_container(property.name, spin_box)


static func _static_init() -> void:
	InspectorPropertyType.register_type(TYPE_INT, "int", create_int_control)
	InspectorPropertyType.register_type(TYPE_FLOAT, "float", create_float_control)


static func create_int_control(setter: Callable, getter: Callable) -> SpinBox:
	var spin_box := SpinBox.new()
	spin_box.set_min(INT32_MIN)
	spin_box.set_max(INT32_MAX)
	spin_box.set_step(1.0)
	spin_box.set_use_rounded_values(true)
	spin_box.set_value_no_signal(getter.call())

	if setter.is_valid():
		spin_box.value_changed.connect(func(value: int) -> void:
			setter.call(value)
			spin_box.set_value_no_signal(getter.call())
		)
	else:
		spin_box.set_editable(false)

	return spin_box


static func create_float_control(setter: Callable, getter: Callable) -> SpinBox:
	var spin_box := SpinBox.new()
	spin_box.set_min(INT32_MIN)
	spin_box.set_max(INT32_MAX)
	spin_box.set_step(0.001)
	spin_box.set_value_no_signal(getter.call())

	if setter.is_valid():
		spin_box.value_changed.connect(func(value: float) -> void:
			setter.call(value)
			spin_box.set_value_no_signal(getter.call())
		)
	else:
		spin_box.set_editable(false)

	return spin_box


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.type == TYPE_INT or property.type == TYPE_FLOAT
