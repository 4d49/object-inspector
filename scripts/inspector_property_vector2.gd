# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _box : BoxContainer

var _x : SpinBox
var _y : SpinBox


func _init(object: Object, property: String, editable: bool).(object, property, editable) -> void:
	self.set_property_control(get_value())
	return


func set_property_control(value: Vector2) -> void:
	_x.value = value.x
	_y.value = value.y
	
	return


func get_property_control() -> Control:
	if _box:
		return _box
	
	_box = VBoxContainer.new()
	
	_x = _create_spin("x")
	_box.add_child(_x)
	
	_y = _create_spin("y")
	_box.add_child(_y)
	
	return _box


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
	
	set_value(Vector2(x, y))
	return
