# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _check : CheckBox


func _init(object: Object, property: String, editable: bool).(object, property, editable) -> void:
	self.set_property_control(get_value())
	return


func get_property_control() -> Control:
	if _check:
		return _check
	
	_check = CheckBox.new()
	_check.text = "On"
	_check.disabled = not is_editable()
	# warning-ignore:return_value_discarded
	_check.connect("toggled", self, "set_value")
	
	return _check


func set_property_control(value: bool) -> void:
	_check.pressed = value
	return
