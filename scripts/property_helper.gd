# Copyright (c) 2022-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

class_name PropertyHelper
extends RefCounted


signal property_changed(property: StringName, value: Variant)


var _setter_map: Dictionary[StringName, Callable] = {}
var _getter_map: Dictionary[StringName, Callable] = {}

var _property_list: Array[Dictionary] = []


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


func add_category(name: String) -> void:
	_property_list.push_back(create_property(name, TYPE_NIL, PROPERTY_HINT_NONE, "", PROPERTY_USAGE_CATEGORY))
	property_list_changed.emit()


func add_group(name: String) -> void:
	_property_list.push_back(create_property(name, TYPE_NIL, PROPERTY_HINT_NONE, "", PROPERTY_USAGE_GROUP))
	property_list_changed.emit()


func add_property(
		name: StringName,
		type: Variant.Type,
		setter: Callable,
		getter: Callable,
		hint: PropertyHint = PROPERTY_HINT_NONE,
		hint_string: String = "",
		usage: int = PROPERTY_USAGE_DEFAULT + PROPERTY_USAGE_SCRIPT_VARIABLE,
	) -> bool:

	if _setter_map.has(name):
		return false

	_setter_map[name] = setter
	_getter_map[name] = getter

	_property_list.push_back(create_property(name, type, hint, hint_string, usage))
	property_list_changed.emit()

	return true

## Returns [Callable] to set the value of the object property.
static func object_setter(object: Object, property: StringName) -> Callable:
	if is_instance_valid(object):
		return func setter(value: Variant) -> void:
			object.set(property, value)
	else:
		return Callable()
## Returns [Callable] to get the value of the object property.
static func object_getter(object: Object, property: StringName) -> Callable:
	if is_instance_valid(object):
		return func getter() -> Variant:
			return object.get(property)
	else:
		return Callable()

## Returns [Callable] to set the array value.
static func array_setter(array: Array, index: int) -> Callable:
	return func setter(value: Variant) -> void:
		array[index] = value
## Returns [Callable] to get the array value.
static func array_getter(array: Array, index: int) -> Callable:
	return func getter() -> Variant:
		return array[index]

## Returns [Callable] to set the dictionary value.
static func dictionary_setter(dictionary: Dictionary, key: Variant) -> Callable:
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
