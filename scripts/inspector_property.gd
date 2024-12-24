# Copyright (c) 2022-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Base InspectorProperty class.
class_name InspectorProperty
extends PanelContainer


static var _constructors: Array[Callable] = []

## Declares a supported type for properties. Declaration example:
## [codeblock]
## static func create_custom_control(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> Control:
##     if property.type == TYPE_FLOAT: # If valid type.
##         var spin_box := SpinBox.new()
##         spin_box.set_value_no_signal(getter.call())
##
##         if setter.is_valid():
##             spin_box.value_changed.connect(setter)
##         else:
##             spin_box.set_editable(false)
##
##         return spin_box
##     else:
##         return null # Return null if is invalid type.
## [/codeblock]
static func declare_property(constructor: Callable) -> void:
	assert(constructor.is_valid(), "Invalid constructor Callable.")
	if constructor.is_valid():
		_constructors.push_front(constructor)

## Create and returns a [Control] node for a property. If property is not supported returns [param null].
static func create_property(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> Control:
	assert(is_instance_valid(object), "Invalid Object!")
	if not is_instance_valid(object):
		return null

	for constructor: Callable in _constructors:
		if not constructor.is_valid():
			continue

		var control: Control = constructor.call(object, property, setter, getter)
		if is_instance_valid(control):
			control.set_name(property.name)
			control.set_tooltip_text(Inspector.get_object_property_description(object, property.name))

			return control

	return null


var _object: Object = null

var _property: StringName = &""
var _class_name: StringName = &""
var _type: Variant.Type = TYPE_NIL
var _hint: PropertyHint = PROPERTY_HINT_NONE
var _hint_string: String = ""
var _usage: int = PROPERTY_USAGE_NONE

var _setter: Callable
var _getter: Callable


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	self.set_theme_type_variation(&"InspectorProperty")

	_object = object

	_property = property["name"]
	_class_name = property["class_name"]
	_type = property["type"]
	_hint = property["hint"]
	_hint_string = property["hint_string"]
	_usage = property["usage"]

	_setter = setter
	_getter = getter


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


func get_setter() -> Callable:
	return _setter

func get_getter() -> Callable:
	return _getter


func set_value(new_value: Variant) -> void:
	_setter.call(new_value)

func get_value() -> Variant:
	return _getter.call()

func set_and_return_value(new_value: Variant) -> Variant:
	set_value(new_value)
	return get_value()

## Returns created child [FlowContainer] node with [Label] and custom [Control] as children.
func create_flow_container(title: String, control: Control, parent: Control = self) -> FlowContainer:
	const MINIMUM_SIZE = Vector2(96.0, 16.0)

	var container := FlowContainer.new()
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
		label.set_custom_minimum_size(MINIMUM_SIZE)
		container.add_child(label)

	if is_instance_valid(control):
		control.set_name("Property")
		control.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		control.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		control.set_custom_minimum_size(MINIMUM_SIZE)
		container.add_child(control)

	parent.add_child(container)
	return container
