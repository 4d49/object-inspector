# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [annotation @GDScript.@export_group] property.
extends "../property_handler.gd"


signal toggled(expanded: bool)


var _container: VBoxContainer = null
var _button: Button = null


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)
	self.set_theme_type_variation(&"PropertyHandlerGroup")

	var vbox := VBoxContainer.new()

	_container = VBoxContainer.new()
	_container.hide() # By default group is collapsed.
	vbox.add_child(_container)
	self.set_meta(&"property_container", _container)

	_button = Button.new()
	_button.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
	_button.set_name("Button")
	_button.set_toggle_mode(true)
	_button.set_flat(true)
	_button.set_text_alignment(HORIZONTAL_ALIGNMENT_LEFT)
	_button.set_text(get_property().capitalize())
	_button.toggled.connect(_on_button_toggled)
	vbox.add_child(_button, false, Node.INTERNAL_MODE_FRONT)

	self.add_child(vbox)


func _enter_tree() -> void:
	_button.set_button_icon(get_theme_icon(&"collapsed"))


func _on_button_toggled(expanded: bool) -> void:
	_button.set_button_icon(get_theme_icon(&"expanded") if expanded else get_theme_icon(&"collapsed"))
	_container.set_visible(expanded)

	toggled.emit(expanded)


func set_toggled(value: bool) -> void:
	_button.set_pressed(value)


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.usage == PROPERTY_USAGE_GROUP
