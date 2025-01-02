# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

class_name PropertyHelper
extends RefCounted


signal property_changed(property: StringName, value: Variant)


var _setter_map: Dictionary[StringName, Callable] = {}
var _getter_map: Dictionary[StringName, Callable] = {}

var _property_list: Array[Dictionary] = []
var _property_description: Dictionary[StringName, String] = {}


func _set(property: StringName, value: Variant) -> bool:
	var setter: Callable = _setter_map.get(property, Callable())

	if setter.is_valid() and setter.call(value) != false:
		property_changed.emit(property, get(property))
		return true

	return false

func _get(property: StringName) -> Variant:
	var getter: Callable = _getter_map.get(property, Callable())

	if getter.is_valid():
		return getter.call()

	return null


func _get_property_list() -> Array[Dictionary]:
	return _property_list


static func create_property(
		name: String,
		type: Variant.Type,
		hint: PropertyHint,
		hint_string: String,
		usage: int,
	) -> Dictionary[String, Variant]:

	var property: Dictionary[String, Variant] = {
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string,
		"usage": usage,
	}
	property.make_read_only()

	return property


func _add_property(property: Dictionary, description: String) -> bool:
	if _property_description.has(property.name):
		return false

	_property_list.push_back(property)
	_property_description[property.name] = description

	property_list_changed.emit()

	return true

func add_category(name: String, description: String = "") -> void:
	_add_property(create_property(name, TYPE_NIL, PROPERTY_HINT_NONE, "", PROPERTY_USAGE_CATEGORY), description)


func add_group(name: String, description: String = "") -> void:
	_add_property(create_property(name, TYPE_NIL, PROPERTY_HINT_NONE, "", PROPERTY_USAGE_GROUP), description)


func add_subgroup(name: String, description: String = "") -> void:
	_add_property(create_property(name, TYPE_NIL, PROPERTY_HINT_NONE, "", PROPERTY_USAGE_SUBGROUP), description)


func add_property(
		name: StringName,
		type: Variant.Type,
		setter: Callable,
		getter: Callable,
		description: String = "",
		hint: PropertyHint = PROPERTY_HINT_NONE,
		hint_string: String = "",
		usage: int = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
	) -> bool:

	if name.is_empty() or _setter_map.has(name):
		return false

	_setter_map[name] = setter
	_getter_map[name] = getter

	return _add_property(create_property(name, type, hint, hint_string, usage), description)


func add_button(name: String, callable: Callable, icon_path: String = "", description: String = "") -> bool:
	# To avoid breaking compatibility with other code,
	# we create a pseudo setter and getter.
	var setter: Callable = Callable()
	var getter: Callable = func() -> Callable:
		return callable

	return add_property(name, TYPE_CALLABLE, setter, getter, description, PROPERTY_HINT_TOOL_BUTTON, name + "," + icon_path)


func get_property_description(property: StringName) -> String:
	return _property_description.get(property, "")

## Returns [Callable] to set the value of the object property.
static func object_setter(object: Object, property: StringName) -> Callable:
	if not is_instance_valid(object):
		return Callable()

	return func setter(value: Variant) -> void:
		object.set(property, value)
## Returns [Callable] to get the value of the object property.
static func object_getter(object: Object, property: StringName) -> Callable:
	if not is_instance_valid(object):
		return Callable()

	return func getter() -> Variant:
		return object.get(property)

## Returns [Callable] to set the array value.
static func array_setter(array: Array, index: int) -> Callable:
	if array.is_read_only():
		return Callable()

	return func setter(value: Variant) -> void:
		array[index] = value
## Returns [Callable] to get the array value.
static func array_getter(array: Array, index: int) -> Callable:
	return func getter() -> Variant:
		return array[index]

## Returns [Callable] to set the dictionary value.
static func dictionary_setter(dictionary: Dictionary, key: Variant) -> Callable:
	if dictionary.is_read_only():
		return Callable()

	return func setter(value: Variant) -> void:
		dictionary[key] = value
## Returns [Callable] to get the dictionary value.
static func dictionary_getter(dictionary: Dictionary, key: Variant) -> Callable:
	return func getter() -> Variant:
		return dictionary[key]


static func range_to_hint_string(min: float, max: float, step: float) -> String:
	return String.num(min) + "," + String.num(max) + "," + String.num(step)

static func enum_to_hint_string(enumeration: Dictionary) -> String:
	var hint_string: String = ""

	for key: String in enumeration:
		hint_string += key + ":" + String.num_int64(enumeration[key]) + ","

	return hint_string.left(-1)
