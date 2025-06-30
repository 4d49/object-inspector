# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func can_handle(object: Object, property: Dictionary, flags: int) -> bool:
	return property.usage == PROPERTY_USAGE_CATEGORY


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle(object, property, flags), "Can't handle property!")

	var container := PanelContainer.new()
	container.set_theme_type_variation(&"PropertyCategory")

	var vbox := VBoxContainer.new()
	container.add_child(vbox)
	container.set_meta(&"property_container", vbox)

	var title := Label.new()
	title.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
	title.set_name("Title")
	title.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	title.set_text(property.name)
	vbox.add_child(title, false, Node.INTERNAL_MODE_FRONT)

	var on_theme_changed: Callable = func() -> void:
		var header := title.get_theme_stylebox(&"header", &"PropertyCategory")
		title.add_theme_stylebox_override(&"normal", header)
	title.theme_changed.connect(on_theme_changed, CONNECT_ONE_SHOT)

	return container
