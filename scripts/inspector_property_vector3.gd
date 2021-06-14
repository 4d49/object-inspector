# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _hbox : BoxContainer

var _x : SpinBox
var _y : SpinBox
var _z : SpinBox


func _init(object: Object, property: String, editable: bool).(object, property, editable) -> void:
	self.set_property_control(get_value())
	return


func is_vertical() -> bool:
	return true


func set_property_control(value: Vector3) -> void:
	_x.value = value.x
	_y.value = value.y
	_z.value = value.z
	
	return


func get_property_control() -> Control:
	if _hbox:
		return _hbox
	
	_hbox = HBoxContainer.new()
	
	_x = _create_spin("x")
	_hbox.add_child(_x)
	
	_y = _create_spin("y")
	_hbox.add_child(_y)
	
	_z = _create_spin("z")
	_hbox.add_child(_z)
	
	return _hbox


func _create_spin(prefix: String) -> SpinBox:
	var spin = SpinBox.new()
	spin.prefix = prefix
	spin.min_value = -INF
	spin.max_value = INF
	spin.step = 0.001
	spin.editable = is_editable()
	spin.size_flags_horizontal = SIZE_EXPAND_FILL
	spin.connect("value_changed", self, "_on_changed")
	
	return spin


func _on_changed(_value) -> void:
	var x = _x.value
	var y = _y.value
	var z = _z.value
	
	set_value(Vector3(x, y, z))
	return
