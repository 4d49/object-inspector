# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.


enum {
	FLAG_NONE         = 0,
	FLAG_COMPACT      = 1 << 0,
	FLAG_VERTICAL     = 1 << 1,
	FLAG_SUB_PROPERTY = 1 << 2,
	FLAG_NO_LABEL     = 1 << 3,
}


const MINIMUM_SIZE: Vector2 = Vector2(128.0, 24.0)


static var _registry: Dictionary[Variant.Type, Array] = {}

# Registers default property handlers for Inspector types.
# Override this method to modify or extend the registered handlers.
static func _static_init() -> void:
	const PropertyHandler:          GDScript = preload("property_handler.gd")
	const PropertyHandlerBool:      GDScript = preload("property_handlers/bool_handler.gd")
	const PropertyHandlerButton:    GDScript = preload("property_handlers/button_handler.gd")
	const PropertyHandlerCategory:  GDScript = preload("property_handlers/category_handler.gd")
	const PropertyHandlerColor:     GDScript = preload("property_handlers/color_handler.gd")
	const PropertyHandlerEnum:      GDScript = preload("property_handlers/enum_handler.gd")
	const PropertyHandlerFlags:     GDScript = preload("property_handlers/flags_handler.gd")
	const PropertyHandlerGroup:     GDScript = preload("property_handlers/group_handler.gd")
	const PropertyHandlerMultiline: GDScript = preload("property_handlers/multiline_handler.gd")
	const PropertyHandlerNumber:    GDScript = preload("property_handlers/number_handler.gd")
	const PropertyHandlerString:    GDScript = preload("property_handlers/string_handler.gd")
	const PropertyHandlerVector2:   GDScript = preload("property_handlers/vector2_handler.gd")
	const PropertyHandlerVector3:   GDScript = preload("property_handlers/vector3_handler.gd")

	PropertyHandler.declare_property(TYPE_NIL,         PropertyHandlerCategory.can_handle,              PropertyHandlerCategory.create)
	PropertyHandler.declare_property(TYPE_NIL,         PropertyHandlerGroup.can_handle_group,           PropertyHandlerGroup.create_group)
	PropertyHandler.declare_property(TYPE_NIL,         PropertyHandlerGroup.can_handle_subgroup,        PropertyHandlerGroup.create_subgroup)
	PropertyHandler.declare_property(TYPE_NIL,         PropertyHandlerButton.can_handle,                PropertyHandlerButton.create)
	PropertyHandler.declare_property(TYPE_BOOL,        PropertyHandlerBool.can_handle,                  PropertyHandlerBool.create)
	PropertyHandler.declare_property(TYPE_INT,         PropertyHandlerNumber.can_handle_int,            PropertyHandlerNumber.create_int)
	PropertyHandler.declare_property(TYPE_INT,         PropertyHandlerEnum.can_handle,                  PropertyHandlerEnum.create)
	PropertyHandler.declare_property(TYPE_INT,         PropertyHandlerFlags.can_handle,                 PropertyHandlerFlags.create)
	PropertyHandler.declare_property(TYPE_FLOAT,       PropertyHandlerNumber.can_handle_float,          PropertyHandlerNumber.create_float)
	PropertyHandler.declare_property(TYPE_STRING,      PropertyHandlerString.can_handle_string,         PropertyHandlerString.create_string)
	PropertyHandler.declare_property(TYPE_STRING,      PropertyHandlerMultiline.can_handle_string,      PropertyHandlerMultiline.create_string)
	PropertyHandler.declare_property(TYPE_VECTOR2,     PropertyHandlerVector2.can_handle_vector2,       PropertyHandlerVector2.create_vector2)
	PropertyHandler.declare_property(TYPE_VECTOR2I,    PropertyHandlerVector2.can_handle_vector2i,      PropertyHandlerVector2.create_vector2i)
	PropertyHandler.declare_property(TYPE_VECTOR3,     PropertyHandlerVector3.can_handle_vector3,       PropertyHandlerVector3.create_vector3)
	PropertyHandler.declare_property(TYPE_VECTOR3I,    PropertyHandlerVector3.can_handle_vector3i,      PropertyHandlerVector3.create_vector3i)
	PropertyHandler.declare_property(TYPE_COLOR,       PropertyHandlerColor.can_handle,                 PropertyHandlerColor.create)
	PropertyHandler.declare_property(TYPE_STRING_NAME, PropertyHandlerString.can_handle_string_name,    PropertyHandlerString.create_string_name)
	PropertyHandler.declare_property(TYPE_STRING_NAME, PropertyHandlerMultiline.can_handle_string_name, PropertyHandlerMultiline.create_string_name)

## Declares a supported type for properties. Declaration example:
## [codeblock]
## # Some script.gd...
## static func _static_init() -> void:
##   PropertyHandler.declare_property(can_handle, create_control)
## [/codeblock]
## [param Validator] must receive three arguments [Object] and [Dictionary]. And it must return [param true] if the property can be handled. Example:
## [codeblock]static func can_handle(object: Object, property: Dictionary) -> bool:
##    return property.type == TYPE_FLOAT
## [/codeblock]
## [br][param Constructor] must return a [Control] node. Example:
## [codeblock]static func create_control(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> Control:
##    var spin_box := SpinBox.new()
##    spin_box.set_editable(setter.is_valid())
##    spin_box.set_value_no_signal(getter.call())
##    spin_box.value_changed.connect(setter)
##
##    return spin_box
## [/codeblock]
static func declare_property(
		type: Variant.Type,
		validator: Callable,
		constructor: Callable,
	) -> void:

	assert(validator.is_valid(), "Invalid validator Callable.")
	assert(constructor.is_valid(), "Invalid constructor Callable.")

	var declaration: Dictionary[StringName, Variant] = {
		&"type": type,
		&"validator": validator,
		&"constructor": constructor,
	}
	declaration.make_read_only()

	if not _registry.has(type):
		_registry[type] = Array([], TYPE_DICTIONARY, &"", null)

	_registry[type].push_front(declaration)

## Returns [param true] that the property can be handled.
static func can_handle_property(object: Object, property: Dictionary, flags: int = FLAG_NONE) -> bool:
	if not _registry.has(property.type):
		return false

	for declaration: Dictionary in _registry[property.type]:
		var validator: Callable = declaration.validator
		if validator.is_valid() and validator.call(object, property, flags):
			return true

	return false


static func get_property_description(object: Object, property: StringName) -> String:
	const METHOD_NAME: StringName = &"get_property_description"

	if is_instance_valid(object) and object.has_method(METHOD_NAME):
		return object.call(METHOD_NAME, property)

	return Inspector.get_object_property_description(object, property)

## Create and returns a [Control] node for a property. If property is not supported returns [param null].
static func create_property(
		object: Object,
		property: Dictionary,
		setter: Callable,
		getter: Callable,
		flags: int = FLAG_NONE,
	) -> Control:

	if not _registry.has(property.type):
		return null

	for declaration: Dictionary in _registry[property.type]:
		var validator: Callable = declaration.validator
		if not validator.is_valid() or not validator.call(object, property, flags):
			continue

		var constructor: Callable = declaration.constructor
		if not constructor.is_valid():
			continue

		var control: Control = constructor.call(object, property, setter, getter, flags)
		if is_instance_valid(control):
			control.set_name(property.name)
			control.set_tooltip_text(get_property_description(object, property.name))

			return control

	return null

## Returns an array of supported types, excluding TYPE_NIL if exclude_nil is true.
static func get_supported_types(exclude_nil: bool = true) -> PackedByteArray:
	var supported_type := _registry.keys()
	if exclude_nil:
		supported_type.erase(TYPE_NIL)

	return supported_type




static func create_label(text: String) -> Label:
	var label := Label.new()
	label.set_name("Label")
	label.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	label.set_text(text.capitalize())
	label.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	label.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
	label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	label.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	label.set_stretch_ratio(0.75)
	label.set_custom_minimum_size(MINIMUM_SIZE)

	return label


static func create_spin_box() -> SpinBox:
	var spin_box := SpinBox.new()
	spin_box.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	spin_box.set_v_size_flags(Control.SIZE_EXPAND_FILL)

	return spin_box


static func create_button(text: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.set_text(text)
	button.set_name("Button")
	button.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)

	if on_pressed.is_valid():
		button.pressed.connect(on_pressed)
	else:
		button.set_disabled(true)

	return button


static func configure_property_container(container: Container, title: String, control: Control) -> void:
	if title:
		container.add_child(create_label(title))

	if is_instance_valid(control):
		control.set_name("Property")
		control.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		control.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		control.set_custom_minimum_size(MINIMUM_SIZE)
		container.add_child(control)

static func create_box_container(title: String, control: Control) -> BoxContainer:
	var box_container := BoxContainer.new()
	box_container.set_name("BoxContainer")
	configure_property_container(box_container, title, control)

	return box_container

static func create_flow_container(title: String, control: Control) -> FlowContainer:
	var flow_container := FlowContainer.new()
	flow_container.set_name("FlowContainer")
	configure_property_container(flow_container, title, control)

	return flow_container


static func create_property_panel(description: String, control: Control) -> PanelContainer:
	var container := PanelContainer.new()
	container.set_name("PropertyPanel")
	container.set_theme_type_variation("PropertyPanel")
	container.set_tooltip_text(description)

	if is_instance_valid(control):
		container.add_child(control)

	return container

static func create_sub_property_panel(description: String, control: Control) -> PanelContainer:
	var property_panel := create_property_panel(description, control)
	property_panel.set_name("SubPropertyPanel")
	property_panel.set_theme_type_variation("SubPropertyPanel")

	return property_panel


static func wrap_property_editor(
		flags: int,
		editor: Control,
		object: Object,
		property: Dictionary,
	) -> Control:

	editor.set_meta(&"vertical", flags & FLAG_VERTICAL)
	if flags & FLAG_COMPACT:
		return editor

	var title: String = ""
	if not (flags & FLAG_NO_LABEL):
		title = property.name

	var container := create_box_container(title, editor)
	container.set_vertical(flags & FLAG_VERTICAL)

	var description: String = get_property_description(object, property.name)
	if flags & FLAG_SUB_PROPERTY:
		return create_sub_property_panel(description, container)

	return create_property_panel(description, container)
