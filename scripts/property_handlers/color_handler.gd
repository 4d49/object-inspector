# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func can_handle(object: Object, property: Dictionary, flags: int) -> bool:
	return property.type == TYPE_COLOR


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle(object, property, flags), "Can't handle property!")

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

	return wrap_property_editor(flags, color_picker, object, property)
