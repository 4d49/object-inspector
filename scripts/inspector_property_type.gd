# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

class_name InspectorPropertyType


static var _declarations: Dictionary[Variant.Type, Dictionary] = {}


static func register_type(type: Variant.Type, name: StringName, constructor: Callable) -> void:
	assert(constructor.is_valid(), "Invalid constructor Callable.")

	if constructor.is_valid():
		var declaration: Dictionary[StringName, Variant] = {
			&"type": type,
			&"name": name,
			&"constructor": constructor
		}
		_declarations[type] = declaration

static func unregister_type(type: Variant.Type) -> bool:
	return _declarations.erase(type)


static func get_type_list() -> Array[Dictionary]:
	var type_list: Array[Dictionary] = []

	for type: Variant.Type in _declarations:
		var declaration: Dictionary[StringName, Variant] = {
			&"type": type,
			&"name": _declarations[type][&"name"],
		}
		type_list.push_back(declaration)

	return type_list


static func is_valid_type(type: Variant.Type) -> bool:
	return _declarations.has(type)

static func create_control(type: Variant.Type, setter: Callable, getter: Callable) -> Control:
	const NULL: Dictionary = {}

	var value: Variant = getter.call()

	if value == null:
		value = type_convert(null, type)
	elif type == TYPE_NIL:
		type = typeof(value)

	var declaration: Dictionary = _declarations.get(type, NULL)
	if declaration.is_empty():
		return null

	var constructor: Callable = declaration[&"constructor"]
	if not constructor.is_valid():
		return null

	return constructor.call(setter, getter)
