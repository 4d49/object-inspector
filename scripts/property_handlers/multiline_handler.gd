# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func create_window(setter: Callable, getter: Callable) -> AcceptDialog:
	var window := AcceptDialog.new()
	window.set_name("EditWindow")
	window.set_title("Text edit")
	window.set_min_size(Vector2(375, 225))
	window.add_cancel_button("Cancel")
	window.set_ok_button_text("Apply")
	window.close_requested.connect(window.queue_free)

	var text_edit := TextEdit.new()
	text_edit.set_name("TextEdit")
	text_edit.set_text(getter.call())
	window.add_child(text_edit)

	if setter.is_valid():
		var callback: Callable = func() -> void:
			setter.call(text_edit.get_text())
		window.confirmed.connect(callback)
	else:
		text_edit.set_editable(false)

	return window


static func can_handle(object: Object, property: Dictionary, flags: int) -> bool:
	const VALID_TYPES: PackedInt32Array = [
		TYPE_STRING,
		TYPE_STRING_NAME,
	]

	return property.hint == PROPERTY_HINT_MULTILINE_TEXT and property.type in VALID_TYPES


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle(object, property, flags), "Can't handle property!")

	var container := VBoxContainer.new()
	container.set_name("Container")

	var label := create_label(property.name)
	container.add_child(label)

	var hbox := HBoxContainer.new()
	hbox.set_name("Property")
	hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	hbox.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	container.add_child(hbox)

	var text_edit := TextEdit.new()
	text_edit.set_name("TextEdit")
	text_edit.set_text(getter.call())
	text_edit.set_tooltip_text(text_edit.get_text())
	text_edit.set_line_wrapping_mode(TextEdit.LINE_WRAPPING_BOUNDARY)
	text_edit.set_custom_minimum_size(Vector2(0.0, 96.0))
	text_edit.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	text_edit.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	hbox.add_child(text_edit)

	if setter.is_valid():
		var callback: Callable = func() -> void:
			var column: int = text_edit.get_caret_column()
			var line: int = text_edit.get_caret_line()

			setter.call(text_edit.get_text())
			text_edit.set_text(getter.call())
			text_edit.set_caret_column(column)
			text_edit.set_caret_line(line)
		text_edit.text_changed.connect(callback)
	else:
		text_edit.set_editable(false)

	var maximize := Button.new()
	maximize.set_name("Maximize")
	maximize.set_flat(true)
	maximize.set_v_size_flags(Control.SIZE_EXPAND_FILL)

	var on_theme_changed: Callable = func() -> void:
		maximize.set_button_icon(maximize.get_theme_icon(&"maximize", &"Inspector"))
	maximize.theme_changed.connect(on_theme_changed, CONNECT_ONE_SHOT)

	var on_maximize_pressed: Callable = func() -> void:
		var window := maximize.get_node_or_null("EditWindow")
		if is_instance_valid(window):
			window.queue_free()

		var callback := Callable()
		if setter.is_valid():
			callback = func(text: String) -> void:
				text_edit.set_text(text)
				text_edit.text_changed.emit()
		window = create_window(callback, getter)
		maximize.add_child(window)

		window.popup_centered_clamped(Vector2(500, 300))
	maximize.pressed.connect(on_maximize_pressed)
	hbox.add_child(maximize)

	return wrap_property_editor(flags | FLAG_NO_LABEL, container, object, property)
