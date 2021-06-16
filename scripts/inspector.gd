# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
class_name Inspector, "res://addons/object-inspector/icons/inspector_container.svg"
extends VBoxContainer


const PropertyControl = preload("inspector_property.gd")
const PropertyBool = preload("inspector_property_bool.gd")
const PropertyColor = preload("inspector_property_color.gd")
const PropertyEnum = preload("inspector_property_enum.gd")
const PropertyFlags = preload("inspector_property_flags.gd")
const PropertyFloat = preload("inspector_property_float.gd")
const PropertyInt = preload("inspector_property_int.gd")
const PropertyMultiline = preload("inspector_property_multiline.gd")
const PropertyRect2 = preload("inspector_property_rect2.gd")
const PropertyString = preload("inspector_property_string.gd")
const PropertyStringEnum = preload("inspector_property_string_enum.gd")
const PropertyVector2 = preload("inspector_property_vector2.gd")
const PropertyVector3 = preload("inspector_property_vector3.gd")


export(bool) var _readonly := false setget set_readonly, is_readonly
export(bool) var _search_enabled := true setget set_search_enabled, is_search_enabled


var _object : Object

var _search : LineEdit

var _scroll_container : ScrollContainer
var _container : VBoxContainer


func _init() -> void:
	_search = LineEdit.new()
	_search.placeholder_text = tr("Filter properties")
	_search.size_flags_horizontal = SIZE_EXPAND_FILL
	_search.clear_button_enabled = true
	_search.right_icon = load("addons/object-inspector/icons/search.svg")
	_search.visible = _search_enabled
	# warning-ignore:return_value_discarded
	_search.connect("text_changed", self, "update_inspector")
	self.add_child(_search)
	
	update_inspector()
	
	return


func set_readonly(value: bool) -> void:
	if _readonly != value:
		_readonly = value
		update_inspector()
	
	return


func is_readonly() -> bool:
	return _readonly


func set_search_enabled(value: bool) -> void:
	_search_enabled = value
	_search.visible = value
	return


func is_search_enabled() -> bool:
	return _search_enabled


func is_object_null(object: Object) -> bool:
	return object == null

# Override if a special type of object is required.
func is_valid_object(object: Object) -> bool:
	return object is Object


func _set_object(object: Object) -> void:
	if _object != object: # Update the inspector only if an objects are not equal.
		_object = object
		update_inspector()
	
	return

func set_object(object: Object) -> void:
	if is_object_null(object):
		_set_object(null) # Replace object with null.
	elif is_valid_object(object):
		_set_object(object)
	else:
		assert(false, "Invalid Object.")
	
	return


func get_object() -> Object:
	return _object


func get_scroll_container() -> ScrollContainer:
	if _scroll_container:
		return _scroll_container
	
	_scroll_container = ScrollContainer.new()
	_scroll_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_scroll_container.size_flags_vertical = SIZE_EXPAND_FILL
	self.add_child(_scroll_container)
	
	return _scroll_container


func get_container() -> VBoxContainer:
	if _container:
		return _container
	
	_container = VBoxContainer.new()
	_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_container.size_flags_vertical = SIZE_EXPAND_FILL
	
	var scroll_container = get_scroll_container()
	scroll_container.add_child(_container)
	
	return _container


func get_placeholder() -> Control:
	var placeholder = Label.new()
	placeholder.align = Label.ALIGN_CENTER
	placeholder.valign = Label.VALIGN_CENTER
	placeholder.text = tr("Object not selected.")
	placeholder.size_flags_horizontal = SIZE_EXPAND_FILL
	placeholder.size_flags_vertical = SIZE_EXPAND_FILL
	
	return placeholder


func clear() -> void:
	if _container:
		_container.queue_free()
		_container = null
	
	return


func is_valid_type(type: int) -> bool:
	match type:
		TYPE_BOOL, TYPE_INT, TYPE_REAL,\
		TYPE_STRING, TYPE_VECTOR2, TYPE_VECTOR3,\
		TYPE_COLOR, TYPE_RECT2:
			return true
		_:
			return false


func is_valid_property(property: Dictionary) -> bool:
	if property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_DEFAULT:
		return is_valid_type(property.type)
	
	return false

# warning-ignore:unused_argument
func is_editable_property(property: Dictionary) -> bool:
	if is_readonly():
		return false
	
	return true


func get_property_control(object: Object, property: Dictionary) -> PropertyControl:
	var name : String = property.name
	var hint : int = property.hint
	var hint_string : String = property.hint_string
	
	var editable = false if is_readonly() else is_editable_property(property)
	
	match property.type:
		TYPE_BOOL:
			return PropertyBool.new(object, name, editable)
		TYPE_INT:
			match hint:
				PROPERTY_HINT_ENUM:
					return PropertyEnum.new(object, name, hint_string, editable)
				PROPERTY_HINT_FLAGS:
					return PropertyFlags.new(object, name, hint_string, editable)
				_:
					return PropertyInt.new(object, name, hint_string, editable)
		TYPE_REAL:
			return PropertyFloat.new(object, name, hint_string, editable)
		TYPE_STRING:
			match hint:
				PROPERTY_HINT_ENUM:
					return PropertyStringEnum.new(object, name, hint_string, editable)
				PROPERTY_HINT_MULTILINE_TEXT:
					return PropertyMultiline.new(object, name, editable)
				_:
					return PropertyString.new(object, name, editable)
		TYPE_VECTOR2:
			return PropertyVector2.new(object, name, editable)
		TYPE_RECT2:
			return PropertyRect2.new(object, name, editable)
		TYPE_VECTOR3:
			return PropertyVector3.new(object, name, editable)
		TYPE_COLOR:
			return PropertyColor.new(object, name, hint == PROPERTY_HINT_COLOR_NO_ALPHA, editable)
		_:
			return null


func update_inspector(filter: String = _search.text) -> void:
	var object = get_object()
	clear()
	
	var container = get_container()
	if object:
		if is_search_enabled():
			_search.visible = true
		
		for property in object.get_property_list():
			if is_valid_property(property) and filter.is_subsequence_of(property.name):
				var property_control = get_property_control(object, property)
				if property_control:
					container.add_child(property_control)
				else:
					assert(false, "Invalid property control.")
	else: # If object is null add placeholder.
		_search.visible = false
		
		var placeholder = get_placeholder()
		container.add_child(placeholder)
	
	return
