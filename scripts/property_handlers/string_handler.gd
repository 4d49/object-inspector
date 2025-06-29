# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"



static func create_text_editor(
		setter: Callable,
		getter: Callable,
		property: Dictionary,
	) -> LineEdit:

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

	return line_edit


static func can_handle(object: Object, property: Dictionary) -> bool:
	const VALID_TYPES: PackedInt32Array = [
		TYPE_STRING,
		TYPE_STRING_NAME,
	]

	return property.type in VALID_TYPES


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
	) -> Control:

	assert(can_handle(object, property), "Can't handle property!")

	var description := get_property_description(object, property.name)
	var text_editor := create_text_editor(setter, getter, property)
	var flow_container := create_flow_container(property.name, text_editor)

	return create_property_panel(description, flow_container)
