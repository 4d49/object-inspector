# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _color : ColorPickerButton


func _init(object: Object, property: String, alpha: bool, editable: bool).(object, property, editable) -> void:
	var color_button : ColorPickerButton = get_property_control()
	color_button.edit_alpha = !alpha
	
	self.set_property_control(get_value())
	return


func get_property_control() -> Control:
	if _color:
		return _color
	
	_color = ColorPickerButton.new()
	_color.disabled = not is_editable()
	# warning-ignore:return_value_discarded
	_color.connect("color_changed", self, "set_value")
	
	return _color


func set_property_control(value: Color) -> void:
	_color.color = value
	return
