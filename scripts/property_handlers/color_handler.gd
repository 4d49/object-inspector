# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [Color] property.
extends "../property_handler.gd"


var color_picker: ColorPickerButton = null


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)

	color_picker = create_color_control(setter, getter)
	color_picker.set_edit_alpha(property.hint != PROPERTY_HINT_COLOR_NO_ALPHA)

	create_flow_container(property.name, color_picker)


static func _static_init() -> void:
	InspectorPropertyType.register_type(TYPE_COLOR, "Color", create_color_control)


static func create_color_control(setter: Callable, getter: Callable) -> ColorPickerButton:
	var color_picker := ColorPickerButton.new()
	color_picker.set_pick_color(getter.call())

	if setter.is_valid():
		color_picker.color_changed.connect(func(value: Color) -> void:
			setter.call(value)
			color_picker.set_pick_color(getter.call())
		)
	else:
		color_picker.set_disabled(true)

	var picker: ColorPicker = color_picker.get_picker()
	picker.set_presets_visible(false)

	return color_picker


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.type == TYPE_COLOR
