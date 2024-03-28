# Copyright (c) 2022-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@tool
## A custom control used to edit properties of an object.
class_name Inspector
extends VBoxContainer

## Emitted when object changed.
signal object_changed(object: Object)

# INFO: Required for static initialization.
const InspectorProperties = preload("res://addons/object-inspector/scripts/inspector_properties.gd")


@export
var _readonly := false:
	set = set_readonly,
	get = is_readonly

@export
var _search_enabled := true:
	set = set_search_enabled,
	get = is_search_enabled

@export
var _category_enadled: bool = true:
	set = set_category_enabled,
	get = is_category_enabled


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

## Set category handling enabled.
func set_category_enabled(enabled: bool) -> void:
	if _category_enadled == enabled:
		return

	_category_enadled = enabled
	update_inspector()

## Returns [param true] if category handling is enabled.
func is_category_enabled() -> bool:
	return _category_enadled

## Return edited object.
func get_object() -> Object:
	return _object

## Clear edited object.
func clear() -> void:
	self.set_object(null)

## Return [param true] if property is valid.
## Override for custom available properties.
func is_valid_property(property: Dictionary) -> bool:
	if property["usage"] == PROPERTY_USAGE_CATEGORY:
		return is_category_enabled()

	elif property["hint"] == PROPERTY_HINT_ENUM:
		return property["usage"] == PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_DEFAULT + PROPERTY_USAGE_CLASS_IS_ENUM

	return property["usage"] == PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_DEFAULT

## Return [Control] for property.
func create_property_control(object: Object, property: Dictionary) -> Control:
	return InspectorProperty.create_property(object, property)

## Update Inspector properties.
func update_inspector(filter: String = _search.text) -> void:
	if is_instance_valid(_container):
		_container.queue_free()

	_search.editable = is_instance_valid(_object)
	if not _search.editable:
		return

	_container = VBoxContainer.new()
	_container.set_name("Container")
	_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	_container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	_scroll_container.add_child(_container)

	var parent: Control = _container
	var category: Control = null

	for property in _object.get_property_list():
		if not filter.is_subsequence_ofn(property["name"]) or not is_valid_property(property):
			continue

		var control: Control = create_property_control(_object, property)
		if not is_instance_valid(control):
			continue

		# TODO: Do something. I really don't like all the code below...
		if is_category_enabled() and property["usage"] == PROPERTY_USAGE_CATEGORY:
			_container.add_child(control)

			assert(control.has_node(^"Container"), "Category property does not have a `Category` node!")
			if not control.has_node(^"Container"):
				continue

			# INFO: Delete an empty category.
			# TODO: Get rid of this code. Empty categories should not exist in principle.
			if is_instance_valid(category) and parent.get_child_count() < 1:
				category.queue_free()

			parent = control.get_node(^"Container")
			category = control

		else:
			parent.add_child(control)
