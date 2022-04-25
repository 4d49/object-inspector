# Copyright (c) 2021-2022 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Base InspectorProperty class.
## @desc: For inherited classes, override [method can_handle] and [method get_control] methods.
class_name InspectorProperty
extends RefCounted

## Return [code]true[/code] if this [InspectorProperty] can handle this object and property.
func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
	return false

## Return [code]true[/code] if [InspectorProperty] is editable.
## By default [code]true[/code] if [code]NOT[/code] [method Inspector.is_readonly].
func is_editable(object: Object, property: Dictionary, readonly: bool) -> bool:
	return not readonly

## Return [Control] for edit object property.
func get_control(object: Object, property: Dictionary, readonly: bool) -> Control:
	return null

## Return [BoxContainer] with [Label] and custom [Control] as children.
func get_combo_container(name: String, control: Control, vertical: bool = false) -> BoxContainer:
	var container : BoxContainer = VBoxContainer.new() if vertical else HBoxContainer.new()
	container.hint_tooltip = name
	
	var label = Label.new()
	label.text = name.capitalize()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.size_flags_stretch_ratio = 0.5
	container.add_child(label)
	
	assert(is_instance_valid(control), "Invalid Control.")
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(control)
	
	return container
