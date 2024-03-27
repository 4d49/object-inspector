# Copyright (c) 2022-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Base InspectorProperty class.
class_name InspectorProperty
extends PanelContainer


static var _declarations: Array[Dictionary] = []

## Declares a supported type for properties.
## [param Validation] must take two arguments [Object] and [Dictionary] and return [param true] if the property can be handled.
## [codeblock] func can_handle(object: Object, property: Dictionary) -> bool:
##     return property["type"] == TYPE_BOOL
## [/codeblock]
## [br][param Constructor] must take two arguments [Object] and [Dictionary] and return [Control].
## [codeblock] func create_control(object: Object, property: Dictionary) -> Control:
##     var label := Label.new()
##     label.set_text(property["name"])
##
##     return label
## [/codeblock]
static func declare_property(validation: Callable, constructor: Callable) -> void:
	assert(validation.is_valid(), "Invalid validation Callable.")
	assert(constructor.is_valid(), "Invalid constructor Callable.")

	if validation.is_valid() and constructor.is_valid():
		_declarations.push_front({"validation": validation, "constructor": constructor})

## Create and returns a [Control] node for a property. If property is not supported returns [param null].
static func create_property(object: Object, property: Dictionary) -> Control:
	assert(is_instance_valid(object), "Invalid Object!")
	if not is_instance_valid(object):
		return null

	for decl: Dictionary in _declarations:
		var validation: Callable = decl["validation"]
		if not validation.is_valid() or not validation.call(object, property):
			continue

		var constructor: Callable = decl["constructor"]
		if not constructor.is_valid():
			continue

		var control: Control = constructor.call(object, property)
		if is_instance_valid(control):
			control.set_name(property["name"])
			return control

	return null


var _object: Object = null

var _property: StringName = &""
var _class_name: StringName = &""
var _type: Variant.Type = TYPE_NIL
var _hint: PropertyHint = PROPERTY_HINT_NONE
var _hint_string: String = ""
var _usage: int = PROPERTY_USAGE_NONE


func _init(object: Object, property: Dictionary) -> void:
	_object = object

	_property = property["name"]
	_class_name = property["class_name"]
	_type = property["type"]
	_hint = property["hint"]
	_hint_string = property["hint_string"]
	_usage = property["usage"]


func get_object() -> Object:
	return _object

func get_property() -> StringName:
	return _property

func get_class_name() -> StringName:
	return _class_name

func get_type() -> Variant.Type:
	return _type

func is_compatible_type(type: Variant.Type) -> bool:
	return get_type() == type

func get_hint() -> PropertyHint:
	return _hint

func get_hint_string() -> String:
	return _hint_string

func get_usage() -> PropertyUsageFlags:
	return _usage


func set_value(new_value: Variant) -> void:
	get_object().set(get_property(), new_value)

func get_value() -> Variant:
	return get_object().get(get_property())

func set_and_return_value(new_value: Variant) -> Variant:
	set_value(new_value)
	return get_value()

## Returns created child [BoxContainer] node with [Label] and custom [Control] as children.
func create_combo_container(title: String, control: Control, vertical := false) -> BoxContainer:
	var container := BoxContainer.new()
	container.set_vertical(vertical)
	container.set_name("Container")

	if title:
		var label := Label.new()
		label.set_name("Label")
		label.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
		label.set_text(title.capitalize())
		label.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		label.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		label.set_stretch_ratio(0.75)
		label.set_custom_minimum_size(Vector2(192/2, 16.0))
		container.add_child(label)

	if is_instance_valid(control):
		control.set_name("Property")
		control.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		control.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		container.add_child(control)

	self.add_child(container)

	return container

## Return [param true] if [InspectorProperty] can handle the object and property.
static func can_handle(object: Object, property: Dictionary) -> bool:
	return false
