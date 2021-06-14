# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "inspector_property.gd"


var _hbox : HBoxContainer

var _text_edit : TextEdit
var _maximize : Button

var _window : AcceptDialog
var _window_edit : TextEdit


func _init(object: Object, property: String, editable: bool).(object, property, editable) -> void:
	self.set_property_control(get_value())
	return


func is_vertical() -> bool:
	return true


func get_control_dialog() -> AcceptDialog:
	if _window:
		return _window
	
	_window = AcceptDialog.new()
	_window.window_title = "Text edit"
	_window.resizable = true
	_window.rect_min_size = Vector2(720, 480)
	self.add_child(_window)
	
	_window_edit = TextEdit.new()
	_window_edit.readonly = not is_editable()
	_window_edit.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	# warning-ignore:return_value_discarded
	_window_edit.connect("text_changed", self, "_text_edit_changed", [_window_edit])
	_window.add_child(_window_edit)
	
	return _window


func get_property_control() -> Control:
	if _hbox:
		return _hbox
	
	_hbox = HBoxContainer.new()
	
	_text_edit = TextEdit.new()
	_text_edit.wrap_enabled = true
	_text_edit.rect_min_size = Vector2(32.0, 128.0)
	_text_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	_text_edit.readonly = not is_editable()
	# warning-ignore:return_value_discarded
	_text_edit.connect("text_changed", self, "_text_edit_changed", [_text_edit])
	_hbox.add_child(_text_edit)
	
	_maximize = Button.new()
	_maximize.icon = load("addons/object-inspector/icons/maximize.svg")
	_maximize.align = Button.ALIGN_CENTER
	_maximize.size_flags_vertical = SIZE_EXPAND_FILL
	# warning-ignore:return_value_discarded
	_maximize.connect("pressed", get_control_dialog(), "popup_centered")
	_hbox.add_child(_maximize)
	
	return _hbox


func _text_edit_changed(text_edit: TextEdit):
	set_value(text_edit.text)
	return


func set_property_control(value: String) -> void:
	var line = _text_edit.cursor_get_line()
	var column = _text_edit.cursor_get_column()
	
	_text_edit.text = value
	_text_edit.cursor_set_line(line)
	_text_edit.cursor_set_column(column)
	
	column = _window_edit.cursor_get_column()
	line = _window_edit.cursor_get_line()
	
	_window_edit.text = value
	_window_edit.cursor_set_line(line)
	_window_edit.cursor_set_column(column)
	
	return
