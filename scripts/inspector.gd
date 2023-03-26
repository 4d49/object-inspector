# Copyright (c) 2022 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@tool
## A custom control used to edit properties of an object.
class_name Inspector
extends VBoxContainer

## Emitted when object changed.
signal object_changed(object: Object)

# Magic numbers, but otherwise the SpinBox does not work correctly.
const FLOAT_MIN = -999999999999.9
const FLOAT_MAX =  999999999999.9


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
	self.add_inspector_property(InspectorPropertyCheck.new())
	self.add_inspector_property(InspectorPropertySpin.new())
	self.add_inspector_property(InspectorPropertySlider.new())
	self.add_inspector_property(InspectorPropertyLine.new())
	self.add_inspector_property(InspectorPropertyMultiline.new())
	self.add_inspector_property(InspectorPropertyVector2.new())
	self.add_inspector_property(InspectorPropertyVector3.new())
	self.add_inspector_property(InspectorPropertyColor.new())
	self.add_inspector_property(InspectorPropertyEnum.new())
	self.add_inspector_property(InspectorPropertyFlags.new())

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

## Base InspectorProperty class.
## 
## For inherited classes, override [method can_handle] and [method create_control] methods.
class InspectorProperty extends RefCounted:
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

## Handle [int] or [float] property with [param @export_range] annotation.
class InspectorPropertySlider extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property["hint"] == PROPERTY_HINT_RANGE and (property["type"] == TYPE_INT or property["type"] == TYPE_FLOAT)

	func create_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var property_name := StringName(property["name"])

		var slider := HSlider.new()
		slider.mouse_filter = Control.MOUSE_FILTER_STOP
		slider.min_value = FLOAT_MIN
		slider.max_value = FLOAT_MAX
		slider.step = 1.0 if property["type"] == TYPE_INT else 0.001
		slider.value = object.get(property_name)
		slider.editable = is_editable(object, property, readonly)
		slider.tooltip_text = str(slider.value)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		slider.value_changed.connect(func(value: float) -> void:
			object.set(property_name, value)
			slider.set_value_no_signal(object.get(property_name))
			slider.set_tooltip_text(str(slider.value))
		)

		var split : PackedStringArray = String(property["hint_string"]).split(',', false)
		if split.size() >= 2:
			slider.min_value = split[0].to_float()
			slider.max_value = split[1].to_float()

			if split.size() >= 3:
				slider.step = split[2].to_float()

		return create_combo_container(property_name, slider)

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
		option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option_button.disabled = not is_editable(object, property, readonly)

		var popup : PopupMenu = option_button.get_popup()
		for s in String(property["hint_string"]).split(",", false):
			var split := s.split(":", false) # [name, value]
			popup.add_item(split[0], split[1].to_int())

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
