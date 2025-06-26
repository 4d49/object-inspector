# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [param enum] property.
extends "../property_handler.gd"


var option_button: OptionButton = null


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)

	option_button = OptionButton.new()
	option_button.set_clip_text(true)

	var hint_split: PackedStringArray = String(property.hint_string).split(",", false)

	for i: int in hint_split.size():
		var split := hint_split[i].split(":", false)

		# If key-value pair.
		if split.size() > 1 and split[1].is_valid_int():
			option_button.add_item(split[0], split[1].to_int())
		else:
			option_button.add_item(split[0], i)

	option_button.select(option_button.get_item_index(get_value()))

	if setter.is_valid():
		option_button.get_popup().id_pressed.connect(_on_id_pressed)
	else:
		option_button.set_disabled(true)

	create_flow_container(property.name, option_button)


func _on_id_pressed(id: int) -> void:
	option_button.select(option_button.get_item_index(set_and_return_value(id)))


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.hint == PROPERTY_HINT_ENUM and property.type == TYPE_INT
