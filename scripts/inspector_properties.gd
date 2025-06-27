# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.


const PropertyHandler: GDScript = preload("property_handler.gd")
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
const PropertyHandlerVector2: GDScript = preload("property_handlers/vector2_handler.gd")
const PropertyHandlerVector3: GDScript = preload("property_handlers/vector3_handler.gd")


static func _static_init() -> void:
	PropertyHandler.declare_property(PropertyHandlerCategory.can_handle, PropertyHandlerCategory.create)
	PropertyHandler.declare_property(PropertyHandlerGroup.can_handle, PropertyHandlerGroup.create)
	PropertyHandler.declare_property(PropertyHandlerButton.can_handle, PropertyHandlerButton.create)
	PropertyHandler.declare_property(PropertyHandlerBool.can_handle, PropertyHandlerBool.create)
	PropertyHandler.declare_property(PropertyHandlerNumber.can_handle, PropertyHandlerNumber.create)
	PropertyHandler.declare_property(PropertyHandlerString.can_handle, PropertyHandlerString.create)
	PropertyHandler.declare_property(PropertyHandlerMultiline.can_handle, PropertyHandlerMultiline.create)
	PropertyHandler.declare_property(PropertyHandlerVector2.can_handle, PropertyHandlerVector2.create)
	PropertyHandler.declare_property(PropertyHandlerVector3.can_handle, PropertyHandlerVector3.create)
	PropertyHandler.declare_property(PropertyHandlerColor.can_handle, PropertyHandlerColor.create)
	PropertyHandler.declare_property(PropertyHandlerEnum.can_handle, PropertyHandlerEnum.create)
	PropertyHandler.declare_property(PropertyHandlerFlags.can_handle, PropertyHandlerFlags.create)
