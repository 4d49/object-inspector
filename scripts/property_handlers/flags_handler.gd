# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [int] property with [param @export_flags] annotation.
extends "../property_handler.gd"


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)

	var vbox := VBoxContainer.new()
	var value: int = get_value()

	var split : PackedStringArray = String(property.hint_string).split(",", false)
	for i in split.size():
		var check_box := CheckBox.new()
		check_box.set_text(split[i])
		check_box.set_pressed(value & (1 << i))

		if setter.is_valid():
			check_box.toggled.connect(func(pressed: bool) -> void:
				if pressed:
					set_value(get_value() | (1 << i))
				else:
					set_value(get_value() & ~(1 << i))

				check_box.set_pressed(get_value() & 1 << i)
			)
		else:
			check_box.set_disabled(true)

		vbox.add_child(check_box)

	var label: Label = create_flow_container(property.name, vbox).get_node(^"Label")
	label.set_v_size_flags(Control.SIZE_SHRINK_BEGIN)


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.hint == PROPERTY_HINT_FLAGS and property.type == TYPE_INT
