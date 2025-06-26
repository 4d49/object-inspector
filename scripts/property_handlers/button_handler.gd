# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [annotation @GDScript.@export_tool_button] property.
extends "../property_handler.gd"


var button: Button = null


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)

	button = Button.new()
	button.set_tooltip_text(get_property_description(object, property.name))
	button.set_theme_type_variation(&"PropertyHandlerButton")

	var hint_split: PackedStringArray = String(property.hint_string).split(',')
	button.set_text(get_button_text(property.name, hint_split))
	button.set_button_icon(get_button_icon(hint_split))

	# Callable is stored as a variable, so to get it, we must call getter.
	var callback: Callable = getter.call()
	if callback.is_valid():
		button.pressed.connect(callback)
	else:
		button.set_disabled(true)

	self.add_child(button)


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.hint == PROPERTY_HINT_TOOL_BUTTON and property.type == TYPE_CALLABLE


static func get_button_text(name: String, hint_split: PackedStringArray) -> String:
	return hint_split[0] if not hint_split.is_empty() and not hint_split[0].is_empty() else name


static func get_button_icon(hint_split: PackedStringArray) -> Texture2D:
	if hint_split.size() > 1 and ResourceLoader.exists(hint_split[1], "Texture2D"):
		return ResourceLoader.load(hint_split[1], "Texture2D")

	return null
