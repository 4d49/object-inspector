# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _enum : OptionButton

var _map : Dictionary


func _init(object: Object, property: String, hint_string: String, editable: bool).(object, property, editable) -> void:
	var hint = hint_string.split(",", false)
	
	var option_button : OptionButton = get_property_control()
	
	for i in hint.size():
		var name = hint[i]
		
		option_button.add_item(tr(name))
		option_button.set_item_metadata(i, name)
		
		_map[name] = i
	
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


func set_property_control(value: String) -> void:
	if _map.has(value):
		_enum.select(_map[value])
	
	return


func _on_item_selected(index: int) -> void:
	var value = _enum.get_item_metadata(index)
	set_value(value)
	
	return
