# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func can_handle(object: Object, property: Dictionary, flags: int) -> bool:
	return property.hint == PROPERTY_HINT_TOOL_BUTTON and property.type == TYPE_CALLABLE


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle(object, property, flags), "Can't handle property!")

	# Callable is stored as a variable, so to get it, we must call getter.
	var button := create_button(property.name, getter.call())
	button.set_theme_type_variation(&"PropertyButton")

	var parsed_hint_string := parse_hint_string(property.hint_string)
	button.set_text(parsed_hint_string.text if parsed_hint_string.text else property.name)
	button.set_button_icon(parsed_hint_string.icon)

	return button


static func _parse_button_text(hint_split: PackedStringArray) -> String:
	var text: String = ""
	if not hint_split.is_empty() and not hint_split[0].is_empty():
		text = hint_split[0]

	return text

static func _parse_button_icon(hint_split: PackedStringArray) -> Texture2D:
	const TYPE_HINT: String = "Texture2D"

	var icon: Texture2D = null
	if hint_split.size() > 1 and ResourceLoader.exists(hint_split[1], TYPE_HINT):
		icon = ResourceLoader.load(hint_split[1], TYPE_HINT)

	return icon

static func parse_hint_string(hint_string: String) -> Dictionary[StringName, Variant]:
	var split: PackedStringArray = hint_string.split(",", false)

	return {
		&"text": _parse_button_text(split),
		&"icon": _parse_button_icon(split),
	}
