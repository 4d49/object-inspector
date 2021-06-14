# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _vbox : BoxContainer


func _init(object: Object, property: String, hint_string: String, editable: bool).(object, property, editable) -> void:
	var container = get_property_control()
	var value = get_value()
	
	var i = 0
	for name in hint_string.split(",", false):
		var flag = CheckBox.new()
		flag.text = name
		flag.pressed = value & i
		flag.disabled = not editable
		
		flag.connect("toggled", self, "_on_flag_toggled", [1 << i])
		container.add_child(flag)
		
		i += 1
	
	self.set_property_control(get_value())
	return


func get_property_control() -> Control:
	if _vbox:
		return _vbox
	
	_vbox = VBoxContainer.new()
	return _vbox


func set_property_control(value: int) -> void:
	var cont = get_property_control()
	
	for i in cont.get_child_count():
		var child = cont.get_child(i)
		
		if child is CheckBox:
			child.pressed = value & 1 << i
		else:
			assert(false, "Child is not a CheckBox.")
			return
	
	return


func _on_flag_toggled(pressed: bool, flag: int) -> void:
	var value = get_value()
	set_value(value | flag if pressed else value  & ~flag)
	return
