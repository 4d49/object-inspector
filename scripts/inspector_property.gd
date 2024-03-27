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

## Handle [bool] property.
class InspectorPropertyCheck extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property["type"] == TYPE_BOOL

	func create_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var property_name := StringName(property["name"])

		var check := CheckBox.new()
		check.button_pressed = object.get(property_name)
		check.text = tr("On")
		check.tooltip_text = str(check.button_pressed)
		check.disabled = not is_editable(object, property, readonly)
		check.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		check.toggled.connect(func(value: bool) -> void:
			object.set(property_name, value)
			check.button_pressed = object.get(property_name)
			check.tooltip_text = str(check.button_pressed)
		)

		return create_combo_container(property_name, check)

## Handle [int] or [float] property.
class InspectorPropertySpin extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property["type"] == TYPE_INT or property["type"] == TYPE_FLOAT

	func create_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var property_name := StringName(property["name"])

		var spin := SpinBox.new()
		spin.min_value = FLOAT_MIN
		spin.max_value = FLOAT_MAX
		spin.step = 1.0 if property["type"] == TYPE_INT else 0.001
		spin.rounded = property["type"] == TYPE_INT
		spin.value = object.get(property_name)
		spin.editable = is_editable(object, property, readonly)
		spin.tooltip_text = str(spin.value)
		spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		spin.value_changed.connect(func(value: float) -> void:
			object.set(property_name, value)
			spin.set_value_no_signal(object.get(property_name))
			spin.set_tooltip_text(str(spin.value))
		)

		var split : PackedStringArray = String(property["hint_string"]).split(',', false)
		if split.size() >= 2:
			spin.min_value = split[0].to_float()
			spin.max_value = split[1].to_float()

			if split.size() >= 3:
				spin.step = split[2].to_float()

		return create_combo_container(property_name, spin)

## Handle [String] or [StringName] property.
class InspectorPropertyLine extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property["type"] == TYPE_STRING or property["type"] == TYPE_STRING_NAME

	func create_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var property_name := StringName(property["name"])

		var line := LineEdit.new()
		line.text = object.get(property_name)
		line.tooltip_text = line.text
		line.editable = is_editable(object, property, readonly)
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		line.text_changed.connect(func(value: String) -> void:
			object.set(property_name, value)

			var caret := line.caret_column
			line.text = object.get(property_name)
			line.tooltip_text = line.text
			line.caret_column = caret
		)

		return create_combo_container(property_name, line)

## Handle [String] or [StringName] property with [param @export_multiline] annotation.
class InspectorPropertyMultiline extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property["hint"] == PROPERTY_HINT_MULTILINE_TEXT and (property["type"] == TYPE_STRING or property["type"] == TYPE_STRING_NAME)

	func create_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var property_name := StringName(property["name"])
		var hbox := HBoxContainer.new()

		var text_edit := TextEdit.new()
		text_edit.text = object.get(property_name)
		text_edit.tooltip_text = text_edit.text
		text_edit.editable = is_editable(object, property, readonly)
		text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		text_edit.custom_minimum_size = Vector2(24.0, 96.0)
		text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(text_edit)

		var maximize := Button.new()
		maximize.icon = load("addons/object-inspector/icons/maximize.svg")
		maximize.disabled = not text_edit.editable
		maximize.size_flags_vertical = Control.SIZE_EXPAND_FILL
		hbox.add_child(maximize)

		var window := AcceptDialog.new()
		window.title = "Text edit"
		window.min_size = Vector2(640, 480)
		hbox.add_child(window)

		var window_edit := TextEdit.new()
		window_edit.text = text_edit.text
		window_edit.tooltip_text = window_edit.text
		window.add_child(window_edit)
		# TextEdit don't emit changed text.
		var callable = func(edit: TextEdit) -> void:
			object.set(property_name, edit.text)

			var column := text_edit.get_caret_column()
			var line := text_edit.get_caret_line()

			text_edit.text = object.get(property_name)
			text_edit.tooltip_text = text_edit.text
			text_edit.set_caret_column(column)
			text_edit.set_caret_line(line)

			column = window_edit.get_caret_column()
			line = window_edit.get_caret_line()

			window_edit.text = text_edit.text
			window_edit.tooltip_text = window_edit.text
			window_edit.set_caret_column(column)
			window_edit.set_caret_line(line)

		maximize.pressed.connect(window.popup_centered)
		text_edit.text_changed.connect(callable.bind(text_edit))
		window.confirmed.connect(callable.bind(window_edit))

		return create_combo_container(property_name, hbox, true)

## Handle [Vector2] or [Vector2i] property.
class InspectorPropertyVector2 extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property["type"] == TYPE_VECTOR2 or property["type"] == TYPE_VECTOR2I

	func create_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var property_name := StringName(property["name"])
		var value : Vector2 = object.get(property_name)

		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var x_spin := SpinBox.new()
		x_spin.editable = is_editable(object, property, readonly)
		x_spin.prefix = "x"
		x_spin.min_value = FLOAT_MIN
		x_spin.max_value = FLOAT_MAX
		x_spin.step = 1.0 if property["type"] == TYPE_VECTOR2I else 0.001
		x_spin.value = value.x
		x_spin.tooltip_text = str(value.x)
		x_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(x_spin)

		var y_spin := x_spin.duplicate() as SpinBox
		y_spin.prefix = "y"
		y_spin.value = value.y
		y_spin.tooltip_text = str(value.y)
		vbox.add_child(y_spin)

		var callable = func(_value) -> void:
			object.set(property_name, Vector2(x_spin.value, y_spin.value))
			value = object.get(property_name)

			x_spin.set_value_no_signal(value.x)
			x_spin.set_tooltip_text(str(value.x))

			y_spin.set_value_no_signal(value.y)
			y_spin.set_tooltip_text(str(value.y))

		x_spin.value_changed.connect(callable)
		y_spin.value_changed.connect(callable)

		return create_combo_container(property_name, vbox)

## Handle [Vector3] or [Vector3i] property.
class InspectorPropertyVector3 extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property["type"] == TYPE_VECTOR3 or property["type"] == TYPE_VECTOR3I

	func create_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var property_name := StringName(property["name"])
		var value : Vector3 = object.get(property_name)

		var hbox := HBoxContainer.new()

		var x_spin := SpinBox.new()
		x_spin.editable = is_editable(object, property, readonly)
		x_spin.prefix = "x"
		x_spin.min_value = FLOAT_MIN
		x_spin.max_value = FLOAT_MAX
		x_spin.step = 1.0 if property["type"] == TYPE_VECTOR3I else 0.001
		x_spin.value = value.x
		x_spin.tooltip_text = str(x_spin.value)
		x_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(x_spin)

		var y_spin := x_spin.duplicate() as SpinBox
		y_spin.prefix = "y"
		y_spin.value = value.y
		y_spin.tooltip_text = str(y_spin.value)
		hbox.add_child(y_spin)

		var z_spin := x_spin.duplicate() as SpinBox
		z_spin.prefix = "z"
		z_spin.value = value.z
		z_spin.tooltip_text = str(z_spin.value)
		hbox.add_child(z_spin)

		var callable = func(_value) -> void:
			object.set(property_name, Vector3(x_spin.value, y_spin.value, z_spin.value))
			value = object.get(property_name)

			x_spin.set_value_no_signal(value.x)
			x_spin.set_tooltip_text(str(value.x))

			y_spin.set_value_no_signal(value.y)
			y_spin.set_tooltip_text(str(value.y))

			z_spin.set_value_no_signal(value.z)
			z_spin.set_tooltip_text(str(value.z))

		x_spin.value_changed.connect(callable)
		y_spin.value_changed.connect(callable)
		z_spin.value_changed.connect(callable)

		return create_combo_container(property_name, hbox, true)

## Handle [Color] property.
class InspectorPropertyColor extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property["type"] == TYPE_COLOR

	func create_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var property_name := StringName(property["name"])

		var picker := ColorPickerButton.new()
		picker.color = object.get(property_name)
		picker.tooltip_text = str(picker.color)
		picker.disabled = not is_editable(object, property, readonly)
		picker.edit_alpha = not property["hint"] == PROPERTY_HINT_COLOR_NO_ALPHA
		picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		picker.color_changed.connect(func(value: Color) -> void:
			object.set(property_name, value)
			picker.color = object.get(property_name)
			picker.tooltip_text = str(picker.color)
		)

		return create_combo_container(property_name, picker)

## Handle [param enum] property.
class InspectorPropertyEnum extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property["hint"] == PROPERTY_HINT_ENUM and property["type"] == TYPE_INT

	func create_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var option_button := OptionButton.new()
		option_button.clip_text = true
		option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option_button.disabled = not is_editable(object, property, readonly)

		var popup : PopupMenu = option_button.get_popup()
		var hint_split: PackedStringArray = String(property["hint_string"]).split(",", false)

		for i: int in hint_split.size():
			var split := hint_split[i].split(":", false)

			# If key-value pair.
			if split.size() > 1 and split[1].is_valid_int():
				popup.add_item(split[0], split[1].to_int())
			else:
				popup.add_item(split[0], i)

		var property_name := StringName(property["name"])
		option_button.selected = popup.get_item_index(object.get(property_name))

		popup.id_pressed.connect(func(value: int) -> void:
			object.set(property_name, value)
			option_button.selected = popup.get_item_index(object.get(property_name))
		)

		return create_combo_container(property_name, option_button)

## Handle [int] property with [param @export_flags] annotation.
class InspectorPropertyFlags extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property["hint"] == PROPERTY_HINT_FLAGS and property["type"] == TYPE_INT

	func create_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var property_name := StringName(property["name"])
		var value : int = object.get(property_name)

		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var split : PackedStringArray = String(property["hint_string"]).split(",", false)
		for i in split.size():
			var check := CheckBox.new()
			check.text = split[i]
			check.button_pressed = value & (1 << i)
			check.disabled = not is_editable(object, property, readonly)

			check.toggled.connect(func(pressed: bool) -> void:
				if pressed:
					object.set(property_name, object.get(property_name) | (1 << i))
				else:
					object.set(property_name, object.get(property_name) & ~(1 << i))

				check.button_pressed = object.get(property_name) & 1 << i
			)

			vbox.add_child(check)

		return create_combo_container(property_name, vbox)
