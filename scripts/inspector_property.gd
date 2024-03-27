# Copyright (c) 2022-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Base InspectorProperty class.
##
## For inherited classes, override [method can_handle] and [method create_control] methods.
class_name InspectorProperty
extends RefCounted

# Magic numbers, but otherwise the SpinBox does not work correctly.
const FLOAT_MIN = -999999999999.9
const FLOAT_MAX =  999999999999.9

## Return [param true] if [InspectorProperty] can handle the object and property.
func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
	return false

## Return [param true] if [InspectorProperty] is editable.
## By default [param true] if [param NOT] [method Inspector.is_readonly].
func is_editable(object: Object, property: Dictionary, readonly: bool) -> bool:
	return not readonly

## Factory method. Should be overridden.
## Return [Control] for edit property value.
func create_control(object: Object, property: Dictionary, readonly: bool) -> Control:
	return null

## Return [BoxContainer] with [Label] and custom [Control] as children.
func create_combo_container(name: StringName, control: Control, vertical: bool = false) -> BoxContainer:
	assert(is_instance_valid(control), "Invalid Control.")
	if not is_instance_valid(control):
		return null

	var container := BoxContainer.new()
	container.vertical = vertical

	var label = Label.new()
	label.text = tr(name).capitalize()
	label.tooltip_text = label.text
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(label)

	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(control)

	return container
