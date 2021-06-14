# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _enum : OptionButton

var _map : Dictionary


func _init(object: Object, property: String, hint_string: String, editable: bool).(object, property, editable) -> void:
	var hint = hint_string.split(",", false) # "name: value"
	
	var option_button : OptionButton = get_property_control()
	
	for i in hint.size():
		var item = hint[i].split(":", false) # [name, value]
		
		var name = item[0]
		var value = int(item[1])
		
		option_button.add_item(name)
		option_button.set_item_metadata(i, value)
		
		_map[value] = i
	
	self.set_property_control(get_value())
	return


func get_property_control() -> Control:
	if _enum:
		return _enum
	
	_enum = OptionButton.new()
	_enum.disabled = not is_editable()
	# warning-ignore:return_value_discarded
	_enum.connect("item_selected", self, "_on_item_selected")
	return _enum


func set_property_control(key: int) -> void:
	if _map.has(key):
		_enum.select(_map[key])
	
	return


func _on_item_selected(index: int) -> void:
	var value = _enum.get_item_metadata(index)
	set_value(value)
	
	return
