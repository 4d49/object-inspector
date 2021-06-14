# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _spin : SpinBox


func _init(object: Object, property: String, hint_string: String, editable: bool).(object, property, editable) -> void:
	if hint_string:
		var slider = get_property_control()
		
		var values = hint_string.split(",")
		slider.min_value = int(values[0])
		slider.max_value = int(values[1])
		
		if values.size() > 2:
			slider.step = int(values[2])
	
	self.set_property_control(get_value())
	return


func get_property_control() -> Control:
	if _spin:
		return _spin
	
	_spin = SpinBox.new()
	_spin.step = 1
	_spin.max_value = INF
	_spin.min_value = -INF
	_spin.editable = is_editable()
	# warning-ignore:return_value_discarded
	_spin.connect("value_changed", self, "set_value")
	
	return _spin


func set_property_control(value: int) -> void:
	var property_edit = get_property_control()
	property_edit.value = value
	
	return
