# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _hbox : BoxContainer

var _x : SpinBox
var _y : SpinBox
var _w : SpinBox
var _h : SpinBox


func _init(object: Object, property: String, editable: bool).(object, property, editable) -> void:
	self.set_property_control(get_value())
	return


func is_vertical() -> bool:
	return true


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

func get_property_control() -> Control:
	if _hbox:
		return _hbox
	
	_hbox = HBoxContainer.new()
	
	_x = _create_spin("x")
	_hbox.add_child(_x)
	
	_y = _create_spin("y")
	_hbox.add_child(_y)
	
	_w = _create_spin("w")
	_hbox.add_child(_w)
	
	_h = _create_spin("h")
	_hbox.add_child(_h)
	
	return _hbox


func set_property_control(value: Rect2) -> void:
	var position = value.position
	
	_x.value = position.x
	_y.value = position.y
	
	var size = value.size
	
	_w.value = size.x
	_h.value = size.y
	
	return


func _on_changed(_value) -> void:
	var x = _x.value
	var y = _y.value
	var w = _w.value
	var h = _h.value
	
	set_value(Rect2(x, y, w, h))
	return
