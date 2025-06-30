# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "../property_handler.gd"


static func can_handle(object: Object, property: Dictionary, flags: int) -> bool:
	const VALID_USAGE: PackedInt32Array = [
		PROPERTY_USAGE_GROUP,
		PROPERTY_USAGE_SUBGROUP,
	]

	return property.usage in VALID_USAGE


static func create(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int,
	) -> Control:

	assert(can_handle(object, property, flags), "Can't handle property!")

	var theme_variation: StringName = &"PropertyGroup"
	if property.usage == PROPERTY_USAGE_SUBGROUP:
		theme_variation = &"PropertySubGroup"

	var container := PanelContainer.new()
	container.set_theme_type_variation(theme_variation)
	container.add_user_signal("toggled", [{"name": "expanded", "type": TYPE_BOOL}])

	var vbox := VBoxContainer.new()
	container.add_child(vbox)

	var property_container := VBoxContainer.new()
	property_container.hide()

	container.set_meta(&"property_container", property_container)
	container.connect(&"toggled", property_container.set_visible)
	vbox.add_child(property_container)

	var button := Button.new()
	button.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
	button.set_name("Button")
	button.set_toggle_mode(true)
	button.set_pressed(false)
	button.set_flat(true)
	button.set_text_alignment(HORIZONTAL_ALIGNMENT_LEFT)
	button.set_text(property.name)
	vbox.add_child(button, false, Node.INTERNAL_MODE_FRONT)

	var on_theme_changed: Callable = func() -> void:
		var icon: Texture2D = container.get_theme_icon(&"collapsed", theme_variation)
		button.set_button_icon(icon)
	button.theme_changed.connect(on_theme_changed, Node.INTERNAL_MODE_FRONT)

	var on_button_toggled: Callable = func	(expanded: bool) -> void:
		var icon_type: StringName = &"expanded" if expanded else &"collapsed"
		var icon: Texture2D = container.get_theme_icon(icon_type)
		button.set_button_icon(icon)

		container.emit_signal(&"toggled", expanded)
	button.toggled.connect(on_button_toggled)

	return container
