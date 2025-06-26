# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [String] or [StringName] property.
extends "../property_handler.gd"


var line_edit: LineEdit = null
var choose_file: Button = null


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)

	if property.type == TYPE_STRING:
		line_edit = create_string_control(setter, getter)
	else:
		line_edit = create_string_name_control(setter, getter)

	var hint: PropertyHint = property.hint
	if not is_hint_file_or_dir(hint):
		create_flow_container(property.name, line_edit)
		return

	line_edit.set_h_size_flags(Control.SIZE_EXPAND_FILL)

	var hbox := HBoxContainer.new()
	hbox.add_child(line_edit)
	hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)

	var hint_string: String = property.hint_string

	setter = func(text: String) -> void:
		line_edit.set_text(set_and_return_value(text))

	choose_file = Button.new()
	choose_file.pressed.connect(func() -> void:
		var file_dialog := FileDialog.new()

		if is_hint_dir(hint):
			file_dialog.set_access(FileDialog.ACCESS_RESOURCES if hint == PROPERTY_HINT_DIR else FileDialog.ACCESS_FILESYSTEM)
			file_dialog.set_current_dir(get_value())
			file_dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_DIR)
			file_dialog.dir_selected.connect(setter)
		else:
			file_dialog.set_access(FileDialog.ACCESS_RESOURCES if hint == PROPERTY_HINT_FILE else FileDialog.ACCESS_FILESYSTEM)
			file_dialog.set_current_path(get_value())

			if is_hint_file_save(hint):
				file_dialog.set_file_mode(FileDialog.FILE_MODE_SAVE_FILE)
			else:
				file_dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)

			file_dialog.file_selected.connect(setter)

		file_dialog.add_filter(hint_string)
		# Free after hide.
		file_dialog.visibility_changed.connect(func() -> void:
			if not file_dialog.is_visible():
				file_dialog.queue_free()
		)
		self.add_child(file_dialog)

		file_dialog.popup_centered_ratio(0.5)
	)
	hbox.add_child(choose_file)
	create_flow_container(property.name, hbox)


func _enter_tree() -> void:
	if is_instance_valid(choose_file):
		choose_file.set_button_icon(get_theme_icon(&"file", &"Inspector"))


static func _static_init() -> void:
	InspectorPropertyType.register_type(TYPE_STRING, "String", create_string_control)
	InspectorPropertyType.register_type(TYPE_STRING_NAME, "StringName", create_string_name_control)


static func _create_line_edit(setter: Callable, getter: Callable, string_name: bool) -> LineEdit:
	var line_edit := LineEdit.new()
	line_edit.set_editable(setter.is_valid())
	line_edit.set_text(getter.call())

	if string_name:
		line_edit.set_placeholder("StringName")
		if setter.is_valid():
			line_edit.text_changed.connect(func(value: StringName) -> void:
				var caret: int = line_edit.get_caret_column()

				setter.call(value)
				line_edit.set_text(getter.call())
				line_edit.set_caret_column(caret)
			)
	elif setter.is_valid():
		line_edit.text_changed.connect(func(value: String) -> void:
			var caret: int = line_edit.get_caret_column()

			setter.call(value)
			line_edit.set_text(getter.call())
			line_edit.set_caret_column(caret)
		)

	return line_edit


static func create_string_control(setter: Callable, getter: Callable) -> LineEdit:
	return _create_line_edit(setter, getter, false)


static func create_string_name_control(setter: Callable, getter: Callable) -> LineEdit:
	return _create_line_edit(setter, getter, true)


static func is_hint_dir(hint: PropertyHint) -> bool:
	return hint == PROPERTY_HINT_DIR or hint == PROPERTY_HINT_GLOBAL_DIR


static func is_hint_file_save(hint: PropertyHint) -> bool:
	return hint == PROPERTY_HINT_SAVE_FILE or PROPERTY_HINT_GLOBAL_SAVE_FILE


static func is_hint_file_or_dir(hint: PropertyHint) -> bool:
	const FILE_OR_DIR_HINTS: PackedInt32Array = [
			PROPERTY_HINT_FILE,
			PROPERTY_HINT_DIR,
			PROPERTY_HINT_GLOBAL_FILE,
			PROPERTY_HINT_GLOBAL_DIR,
			PROPERTY_HINT_SAVE_FILE,
			PROPERTY_HINT_GLOBAL_SAVE_FILE
		]

	return hint in FILE_OR_DIR_HINTS


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.type == TYPE_STRING or property.type == TYPE_STRING_NAME
