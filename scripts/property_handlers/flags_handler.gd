# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func parse_hint_string(hint_string: String) -> Dictionary[String, int]:
	var option: Dictionary[String, int] = {}

	var split: PackedStringArray = hint_string.split(",", false)
	for i: int in split.size():
		option[split[i]] = 1 << i

	return option


static func create_flags_editor(
		setter: Callable,
		getter: Callable,
		property: Dictionary,
	) -> VBoxContainer:

	var value: int = getter.call()
	var vbox := VBoxContainer.new()

	var parsed_hint_string := parse_hint_string(property.hint_string)
	for name: String in parsed_hint_string:
		var index: int = parsed_hint_string[name]

		var check_box := CheckBox.new()
		check_box.set_name(name)
		check_box.set_text(name)
		check_box.set_pressed(value & index)
		check_box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		if setter.is_valid():
			var callback: Callable = func(pressed: bool) -> void:
				value = getter.call()

				if pressed:
					setter.call(value | index)
				else:
					setter.call(value & ~index)

				check_box.set_pressed((getter.call() & index) == index)

			check_box.toggled.connect(callback)
		else:
			check_box.set_disabled(true)

		vbox.add_child(check_box)

	return vbox


static func can_handle(object: Object, property: Dictionary, flags: int) -> bool:
	return property.hint == PROPERTY_HINT_FLAGS and property.type == TYPE_INT


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle(object, property, flags), "Can't handle property!")

	var flags_editor := create_flags_editor(setter, getter, property)
	return wrap_property_editor(flags, flags_editor, object, property)
