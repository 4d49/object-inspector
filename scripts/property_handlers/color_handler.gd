# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func create_color_editor(
		setter: Callable,
		getter: Callable,
		property: Dictionary,
	) -> ColorPickerButton:

	var color_picker := ColorPickerButton.new()
	color_picker.set_pick_color(getter.call())

	if setter.is_valid():
		var callback: Callable = func(value: Color) -> void:
			setter.call(value)
			color_picker.set_pick_color(getter.call())
		color_picker.color_changed.connect(callback)
	else:
		color_picker.set_disabled(true)

	var picker: ColorPicker = color_picker.get_picker()
	picker.set_presets_visible(false)

	return color_picker


static func can_handle(object: Object, property: Dictionary) -> bool:
	return property.type == TYPE_COLOR


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
	) -> Control:

	assert(can_handle(object, property), "Can't handle property!")

	var description := get_property_description(object, property.name)
	var color_editor := create_color_editor(setter, getter, property)
	var flow_container := create_flow_container(property.name, color_editor)

	return create_property_panel(description, flow_container)
