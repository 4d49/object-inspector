# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func can_handle_string(object: Object, property: Dictionary, flags: int) -> bool:
	return property.type == TYPE_STRING

static func can_handle_string_name(object: Object, property: Dictionary, flags: int) -> bool:
	return property.type == TYPE_STRING_NAME


static func create_string(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle_string(object, property, flags), "Can't handle property!")
	return _create(object, property, setter, getter, flags)

static func create_string_name(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle_string_name(object, property, flags), "Can't handle property!")
	return _create(object, property, setter, getter, flags)


static func _create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:


	var line_edit := LineEdit.new()
	line_edit.set_text(getter.call())

	if property.type == TYPE_STRING_NAME:
		line_edit.set_placeholder("StringName")

	if setter.is_valid():
		var callback: Callable
		if property.type == TYPE_STRING_NAME:
			callback = func(value: StringName) -> void:
				setter.call(value)

				var caret := line_edit.get_caret_column()
				line_edit.set_text(getter.call())
				line_edit.set_caret_column(caret)
		else:
			callback = func(value: String) -> void:
				setter.call(value)

				var caret := line_edit.get_caret_column()
				line_edit.set_text(getter.call())
				line_edit.set_caret_column(caret)
		line_edit.text_changed.connect(callback)
	else:
		line_edit.set_editable(false)

	return wrap_property_editor(flags, line_edit, object, property)
