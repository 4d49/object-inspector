# Copyright (c) 2022-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@tool
## A custom control used to edit properties of an object.
class_name Inspector
extends VBoxContainer

## Emitted when object changed.
signal object_changed(object: Object)


@export
var _readonly := false:
	set = set_readonly,
	get = is_readonly

@export
var _search_enabled := true:
	set = set_search_enabled,
	get = is_search_enabled


var _properties : Array[InspectorProperty]
var _object : Object

var _search : LineEdit

var _scroll_container : ScrollContainer
var _container : VBoxContainer


func _init() -> void:
	_search = LineEdit.new()
	_search.placeholder_text = tr("Filter properties")
	_search.editable = false
	_search.clear_button_enabled = true
	_search.right_icon = load("addons/object-inspector/icons/search.svg")
	_search.visible = _search_enabled
	_search.size_flags_horizontal = SIZE_EXPAND_FILL
	_search.text_changed.connect(update_inspector)
	self.add_child(_search)

	_scroll_container = ScrollContainer.new()
	_scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_scroll_container.size_flags_vertical = SIZE_EXPAND_FILL
	self.add_child(_scroll_container)

	_init_properties()

## Override for add([method add_inspector_property]) custom [Inspector.InspectorProperty].
func _init_properties() -> void:
	self.add_inspector_property(InspectorProperty.InspectorPropertyCheck.new())
	self.add_inspector_property(InspectorProperty.InspectorPropertySpin.new())
	self.add_inspector_property(InspectorProperty.InspectorPropertyLine.new())
	self.add_inspector_property(InspectorProperty.InspectorPropertyMultiline.new())
	self.add_inspector_property(InspectorProperty.InspectorPropertyVector2.new())
	self.add_inspector_property(InspectorProperty.InspectorPropertyVector3.new())
	self.add_inspector_property(InspectorProperty.InspectorPropertyColor.new())
	self.add_inspector_property(InspectorProperty.InspectorPropertyEnum.new())
	self.add_inspector_property(InspectorProperty.InspectorPropertyFlags.new())

## Add a custom [Inspector.InspectorProperty].
func add_inspector_property(property: InspectorProperty) -> void:
	assert(is_instance_valid(property), "Invalid InspectorProperty.")
	if is_instance_valid(property):
		_properties.push_front(property)

## Set Inspector readonly.
func set_readonly(value: bool) -> void:
	if _readonly != value:
		_readonly = value
		self.update_inspector()

## Return [param true] if Inspector is readonly.
func is_readonly() -> bool:
	return _readonly

## Set search line visible.
func set_search_enabled(value: bool) -> void:
	_search_enabled = value
	_search.visible = value

## Return [param true] if search line is enabled.
func is_search_enabled() -> bool:
	return _search_enabled

## Set edited object.
func set_object(object: Object) -> void:
	if is_same(_object, object):
		return

	_object = object
	object_changed.emit(object)

	update_inspector()

## Return edited object.
func get_object() -> Object:
	return _object

## Clear edited object.
func clear() -> void:
	self.set_object(null)

## Return [param true] if property is valid.
## Override for custom available properties.
func is_valid_property(property: Dictionary) -> bool:
	if property["hint"] == PROPERTY_HINT_ENUM:
		return property["usage"] == PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_DEFAULT + PROPERTY_USAGE_CLASS_IS_ENUM

	return property["usage"] == PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_DEFAULT

## Return [Control] for property.
func create_property_control(object: Object, property: Dictionary) -> Control:
	for p in _properties:
		if p.can_handle(object, property, is_readonly()):
			return p.create_control(object, property, is_readonly())

	return null

## Update Inspector properties.
func update_inspector(filter: String = _search.text) -> void:
	if is_instance_valid(_container):
		_container.queue_free()

	_search.editable = is_instance_valid(_object)
	if not _search.editable:
		return

	_container = VBoxContainer.new()
	_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_container.size_flags_vertical = SIZE_EXPAND_FILL

	for property in _object.get_property_list():
		if filter.is_subsequence_ofn(property["name"]) and is_valid_property(property):
			var property_control = create_property_control(_object, property)
			if is_instance_valid(property_control):
				_container.add_child(property_control)

	_scroll_container.add_child(_container)
