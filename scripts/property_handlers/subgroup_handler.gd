# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Handle [annotation @GDScript.@export_subgroup] property.
extends "group_handler.gd"


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)
	self.set_theme_type_variation(&"PropertyHandlerSubGroup")


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.usage == PROPERTY_USAGE_SUBGROUP
