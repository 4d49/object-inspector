# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _spin : SpinBox


func _init(object: Object, property: String, hint_string: String, editable: bool).(object, property, editable) -> void:
	if hint_string:
		var spin : SpinBox = get_property_control()
		
		var values = hint_string.split(",")
		spin.min_value = float(values[0])
		spin.max_value = float(values[1])
		
		if values.size() > 2:
			spin.step = float(values[2])
	
	self.set_property_control(get_value())


func get_property_control() -> Control:
	if _spin:
		return _spin
	
	_spin = SpinBox.new()
	_spin.step = 0.001
	_spin.max_value = INF
	_spin.min_value = -INF
	_spin.editable = is_editable()
	# warning-ignore:return_value_discarded
	_spin.connect("value_changed", self, "set_value")
	return _spin


func set_property_control(value: float) -> void:
	var property_edit = get_property_control()
	property_edit.value = value
	
	return
