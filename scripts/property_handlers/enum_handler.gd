# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func parse_hint_string(hint_string: String) -> Dictionary[String, int]:
	var options: Dictionary[String, int] = {}

	var hint_split: PackedStringArray = hint_string.split(",", false)
	for i: int in hint_split.size():
		var split := hint_split[i].split(":", false)

		# if key-value pair.
		if split.size() > 1 and split[1].is_valid_int():
			options[split[0]] = split[1].to_int()
		else:
			options[split[0]] = i

	return options


static func create_enum_editor(
		setter: Callable,
		getter: Callable,
		property: Dictionary,
	) -> OptionButton:

	var option_button := OptionButton.new()
	option_button.set_clip_text(true)

	var parsed_hint_string := parse_hint_string(property.hint_string)
	for name: String in parsed_hint_string:
		option_button.add_item(name, parsed_hint_string[name])

	option_button.select(option_button.get_item_index(getter.call()))

	if setter.is_valid():
		var callback: Callable = func(id: int) -> void:
			setter.call(id)
			option_button.select(option_button.get_item_index(getter.call()))

		option_button.get_popup().id_pressed.connect(callback)
	else:
		option_button.set_disabled(true)

	return option_button


static func can_handle(object: Object, property: Dictionary) -> bool:
	return property.hint == PROPERTY_HINT_ENUM and property.type == TYPE_INT


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
	) -> Control:

	assert(can_handle(object, property), "Can't handle property!")

	var description := get_property_description(object, property.name)
	var enum_editor := create_enum_editor(setter, getter, property)
	var flow_container := create_flow_container(property.name, enum_editor)

	return create_property_panel(description, flow_container)
