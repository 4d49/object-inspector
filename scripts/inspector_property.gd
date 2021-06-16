# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends MarginContainer


var _object : Object
var _property : String

var _container : Container # Container for property label and control.

var _label : Label # Property label.
var _editable : bool # If property avaible for editing.


func _init(object: Object, property: String, editable: bool) -> void:
	self._set_object(object)
	self._set_property(property)
	self._editable = editable
	
	if OS.is_debug_build(): # Debug-only tooltip.
		self.hint_tooltip = "Property: " + property
	
	var container = get_container()
	container.size_flags_horizontal = SIZE_EXPAND_FILL
	container.size_flags_vertical = SIZE_EXPAND_FILL
	self.add_child(container)
	
	_label = Label.new()
	_label.text = tr(property).capitalize()
	_label.size_flags_vertical = SIZE_EXPAND_FILL
	_label.size_flags_horizontal = SIZE_EXPAND
	_label.size_flags_stretch_ratio = 0.5
	_label.rect_min_size.x = 8.0
	container.add_child(_label)
	
	var property_control = get_property_control()
	property_control.size_flags_horizontal = SIZE_EXPAND_FILL
	property_control.rect_min_size.x = 16.0
	container.add_child(property_control)
	
	self.size_flags_horizontal = SIZE_EXPAND_FILL
	self.name = _label.text
	
	return


func is_editable() -> bool:
	return _editable

# Override if vertical alignment is required.
func is_vertical() -> bool:
	return false


func get_container() -> Container:
	if _container:
		return _container
	
	if is_vertical():
		_container = VBoxContainer.new()
	else:
		_container = HBoxContainer.new()
	
	return _container


func get_object() -> Object:
	return _object


func get_property() -> String:
	return _property


func get_value(): # -> Variant:
	var object = get_object()
	var property = get_property()
	
	return object.get(property)


func set_value(value) -> void:
	var object = get_object()
	var property = get_property()
	
	object.set(property, value)
	
	set_property_control(object.get(property))
	return


func get_property_control() -> Control:
	assert(false, "Method must be overridden.")
	return null


# warning-ignore:unused_argument
func set_property_control(value) -> void:
	assert(false, "Method must be overridden.")
	return


func _set_object(object: Object) -> void:
	if object:
		_object = object
	else:
		assert(false, "Invalid Object.")
	
	return


func _set_property(property: String) -> void:
	if property:
		_property = property
	else:
		assert(false, "Invalid Property.")
	
	return
