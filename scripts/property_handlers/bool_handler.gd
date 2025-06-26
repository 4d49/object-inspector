# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [bool] property.
extends "../property_handler.gd"


var check_box: CheckBox = null


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)

	check_box = create_bool_control(setter, getter)
	create_flow_container(property.name, check_box)


static func _static_init() -> void:
	InspectorPropertyType.register_type(TYPE_BOOL, "bool", create_bool_control)


static func create_bool_control(setter: Callable, getter: Callable) -> CheckBox:
	var check_box := CheckBox.new()
	check_box.set_text("On")
	check_box.set_flat(true)
	check_box.set_pressed_no_signal(getter.call())

	if setter.is_valid():
		check_box.toggled.connect(func(value: bool) -> void:
			setter.call(value)
			check_box.set_pressed_no_signal(getter.call())
		)
	else:
		check_box.set_disabled(true)

	return check_box


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.type == TYPE_BOOL
