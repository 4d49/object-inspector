# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func create_bool_editor(setter: Callable, getter: Callable, property: Dictionary) -> CheckBox:
	var check_box := CheckBox.new()
	check_box.set_text("On")
	check_box.set_flat(true)
	check_box.set_pressed_no_signal(getter.call())

	if setter.is_valid():
		var callback: Callable = func(value: bool) -> void:
			setter.call(value)
			check_box.set_pressed_no_signal(getter.call())

		check_box.toggled.connect(callback)
	else:
		check_box.set_disabled(true)

	return check_box


static func can_handle(object: Object, property: Dictionary) -> bool:
	return property.type == TYPE_BOOL


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
	) -> Control:

	assert(can_handle(object, property), "Can't handle property!")

	var description := get_property_description(object, property.name)
	var bool_editor := create_bool_editor(setter, getter, property)
	var flow_container := create_flow_container(property.name, bool_editor)

	return create_property_panel(description, flow_container)
