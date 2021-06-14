# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _line_edit : LineEdit


func _init(object: Object, property: String, editable: bool).(object, property, editable) -> void:
	self.set_property_control(get_value())
	return


func set_property_control(text: String) -> void:
	var pos = _line_edit.caret_position
	
	_line_edit.text = text
	_line_edit.caret_position = pos
	
	return


func get_property_control() -> Control:
	if _line_edit:
		return _line_edit
	
	_line_edit = LineEdit.new()
	_line_edit.context_menu_enabled = false
	_line_edit.editable = is_editable()
	# warning-ignore:return_value_discarded
	_line_edit.connect("text_changed", self, "set_value")
	
	return _line_edit
