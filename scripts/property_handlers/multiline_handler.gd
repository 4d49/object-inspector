# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [String] or [StringName] property with [param @export_multiline] annotation.
extends "../property_handler.gd"


var text_edit: TextEdit = null
var maximize: Button = null

var window: AcceptDialog = null
var window_text_edit: TextEdit = null


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)

	var container := VBoxContainer.new()
	container.set_name("Container")

	var label := Label.new()
	label.set_name("Label")
	label.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	label.set_text(property.name.capitalize())
	label.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	label.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
	label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	label.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	label.set_stretch_ratio(0.75)
	container.add_child(label)

	var hbox := HBoxContainer.new()
	hbox.set_name("Property")
	hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	hbox.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	container.add_child(hbox)

	text_edit = TextEdit.new()
	text_edit.set_name("TextEdit")
	text_edit.set_text(get_value())
	text_edit.set_tooltip_text(text_edit.get_text())
	text_edit.set_line_wrapping_mode(TextEdit.LINE_WRAPPING_BOUNDARY)
	text_edit.set_custom_minimum_size(Vector2(0.0, 96.0))
	text_edit.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	text_edit.set_v_size_flags(Control.SIZE_EXPAND_FILL)

	if setter.is_valid():
		text_edit.text_changed.connect(_on_text_edit_text_changed)
	else:
		text_edit.set_editable(false)

	hbox.add_child(text_edit)

	maximize = Button.new()
	maximize.set_name("Maximize")
	maximize.set_flat(true)
	maximize.set_v_size_flags(Control.SIZE_SHRINK_CENTER)
	maximize.pressed.connect(_on_maximize_pressed)
	hbox.add_child(maximize)

	self.add_child(container)


func _enter_tree() -> void:
	maximize.set_button_icon(get_theme_icon(&"maximize", &"Inspector"))


func _on_text_edit_text_changed() -> void:
	var column: int = text_edit.get_caret_column()
	var line: int = text_edit.get_caret_line()

	text_edit.set_text(set_and_return_value(text_edit.get_text()))
	text_edit.set_caret_column(column)
	text_edit.set_caret_line(line)


func _on_window_confirmed() -> void:
	var column: int = window_text_edit.get_caret_column()
	var line: int = window_text_edit.get_caret_line()

	window_text_edit.set_text(set_and_return_value(window_text_edit.get_text()))
	window_text_edit.set_caret_column(column)
	window_text_edit.set_caret_line(line)
	text_edit.set_text(window_text_edit.get_text())


func _on_maximize_pressed() -> void:
	if not is_instance_valid(window):
		window = AcceptDialog.new()
		window.set_name("EditTextDialog")
		window.set_title("Text edit")
		window.set_min_size(Vector2(375, 225))
		window.add_cancel_button("Cancel")
		window.set_ok_button_text("Save")
		window.confirmed.connect(_on_window_confirmed)

		window_text_edit = TextEdit.new()
#			window_text_edit.set_editable(is_editable())
		window_text_edit.set_name("TextEdit")
		window_text_edit.set_text(get_value())
		window.add_child(window_text_edit)

		self.add_child(window)

	window_text_edit.set_text(get_value())
	window.popup_centered_clamped(Vector2(500, 300))


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.hint == PROPERTY_HINT_MULTILINE_TEXT and (property.type == TYPE_STRING or property.type == TYPE_STRING_NAME)
