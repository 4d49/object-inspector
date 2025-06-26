# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [annotation @GDScript.@export_category] property.
extends "../property_handler.gd"


var _container: VBoxContainer = null
var _title: Label = null


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)
	self.set_theme_type_variation(&"PropertyHandlerCategory")

	_container = VBoxContainer.new()
	self.set_meta(&"property_container", _container)

	_title = Label.new()
	_title.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
	_title.set_name("Title")
	_title.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	_title.set_text(get_property().capitalize())
	_container.add_child(_title, false, Node.INTERNAL_MODE_FRONT)

	self.add_child(_container)


func _enter_tree() -> void:
	_title.add_theme_stylebox_override(&"normal", get_theme_stylebox(&"header"))


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.usage == PROPERTY_USAGE_CATEGORY
