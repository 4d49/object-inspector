# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func can_handle(object: Object, property: Dictionary, flags: int) -> bool:
	return property.type == TYPE_BOOL


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle(object, property, flags), "Can't handle property!")

	var check_box := CheckBox.new()
	check_box.set_text("On")
	check_box.set_flat(true)
	check_box.set_pressed_no_signal(getter.call())

	if setter.is_valid():
		var callback: Callable = func(value: bool) -> void:
			setter.call(value)
			check_box.set_pressed_no_signal(getter.call())

		check_box.toggled.connect(callback)
	else:
		check_box.set_disabled(true)

	return wrap_property_editor(flags, check_box, object, property)
