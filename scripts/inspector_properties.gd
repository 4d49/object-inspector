# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.


const PropertyArrayHandler: GDScript = preload("property_handlers/array_handler.gd")
const PropertyDictionaryHandler: GDScript = preload("property_handlers/dictionary_handler.gd")
const PropertyHandlerBool: GDScript = preload("property_handlers/bool_handler.gd")
const PropertyHandlerButton: GDScript = preload("property_handlers/button_handler.gd")
const PropertyHandlerCategory: GDScript = preload("property_handlers/category_handler.gd")
const PropertyHandlerColor: GDScript = preload("property_handlers/color_handler.gd")
const PropertyHandlerEnum: GDScript = preload("property_handlers/enum_handler.gd")
const PropertyHandlerFlags: GDScript = preload("property_handlers/flags_handler.gd")
const PropertyHandlerGroup: GDScript = preload("property_handlers/group_handler.gd")
const PropertyHandlerMultiline: GDScript = preload("property_handlers/multiline_handler.gd")
const PropertyHandlerNumber: GDScript = preload("property_handlers/number_handler.gd")
const PropertyHandlerString: GDScript = preload("property_handlers/string_handler.gd")
const PropertyHandlerSubgroup: GDScript = preload("property_handlers/subgroup_handler.gd")
const PropertyHandlerVector2: GDScript = preload("property_handlers/vector2_handler.gd")
const PropertyHandlerVector3: GDScript = preload("property_handlers/vector3_handler.gd")


static func _static_init() -> void:
	PropertyHandler.declare_property(PropertyHandlerCategory.can_handle, PropertyHandlerCategory.new)
	PropertyHandler.declare_property(PropertyHandlerGroup.can_handle, PropertyHandlerGroup.new)
	PropertyHandler.declare_property(PropertyHandlerSubgroup.can_handle, PropertyHandlerSubgroup.new)
	PropertyHandler.declare_property(PropertyHandlerButton.can_handle, PropertyHandlerButton.new)
	PropertyHandler.declare_property(PropertyHandlerBool.can_handle, PropertyHandlerBool.new)
	PropertyHandler.declare_property(PropertyHandlerNumber.can_handle, PropertyHandlerNumber.new)
	PropertyHandler.declare_property(PropertyHandlerString.can_handle, PropertyHandlerString.new)
	PropertyHandler.declare_property(PropertyHandlerMultiline.can_handle, PropertyHandlerMultiline.new)
	PropertyHandler.declare_property(PropertyHandlerVector2.can_handle, PropertyHandlerVector2.new)
	PropertyHandler.declare_property(PropertyHandlerVector3.can_handle, PropertyHandlerVector3.new)
	PropertyHandler.declare_property(PropertyHandlerColor.can_handle, PropertyHandlerColor.new)
	PropertyHandler.declare_property(PropertyHandlerEnum.can_handle, PropertyHandlerEnum.new)
	PropertyHandler.declare_property(PropertyHandlerFlags.can_handle, PropertyHandlerFlags.new)
	PropertyHandler.declare_property(PropertyArrayHandler.can_handle, PropertyArrayHandler.new)
	PropertyHandler.declare_property(PropertyDictionaryHandler.can_handle, PropertyDictionaryHandler.new)
