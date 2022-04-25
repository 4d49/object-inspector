# Copyright (c) 2021-2022 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@tool
class_name Inspector, "res://addons/object-inspector/icons/inspector_container.svg"
extends VBoxContainer

## Handle [bool] property.
class InspectorPropertyCheck extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property.type == TYPE_BOOL
	
	func get_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var name := StringName(property.name)
		var check := CheckBox.new()
		check.button_pressed = object.get(name)
		check.hint_tooltip = str(check.button_pressed)
		check.text = "On"
		check.disabled = not is_editable(object, property, readonly)
		check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var callback = func(value: bool) -> void:
			object.set(name, value)
			check.button_pressed = object.get(name)
			check.hint_tooltip = str(check.button_pressed)
		
		check.toggled.connect(callback)
		return get_combo_container(name, check)

## Handle [int] or [float] property.
class InspectorPropertySpin extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property.type == TYPE_INT or property.type == TYPE_FLOAT
	
	func get_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var spin := SpinBox.new()
		spin.min_value = -9223372036854775807 #- 1
		spin.max_value = 9223372036854775807
		spin.step = 0.001
		spin.editable = is_editable(object, property, readonly)
		spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if property.type == TYPE_INT:
#			spin.rounded = true
			spin.step = 1.0
		
		var split = property.hint_string.split(',', false)
		if split.size() >= 2:
			spin.min_value = split[0].to_float()
			spin.max_value = split[1].to_float()
			
			if split.size() >= 3:
				spin.step = split[2].to_float()
		
		var name := StringName(property.name)
		spin.value = object.get(name)
		spin.hint_tooltip = str(spin.value)
		
		var callback = func(value: float) -> void:
			object.set(name, value)
			spin.value = object.get(name)
			spin.hint_tooltip = str(spin.value)
		
		spin.value_changed.connect(callback)
		return get_combo_container(name, spin)

## Handle [int] or [float] property with [code]@export_range[/code] annotation.
class InspectorPropertySlider extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return (property.type == TYPE_INT or property.type == TYPE_FLOAT) and property.hint_string.split(',', false).size() >= 2
	
	func get_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var slider := HSlider.new()
		slider.min_value = -9223372036854775807 - 1
		slider.max_value = 9223372036854775807
		slider.step = 0.001
		slider.editable = is_editable(object, property, readonly)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if property.type == TYPE_INT:
			slider.rounded = true
			slider.step = 1.0
		
		var split = property.hint_string.split(',', false)
		if split.size() >= 2:
			slider.min_value = split[0].to_float()
			slider.max_value = split[1].to_float()
			
			if split.size() >= 3:
				slider.step = split[2].to_float()
		
		var name := StringName(property.name)
		slider.value = object.get(name)
		slider.hint_tooltip = str(slider.value)
		
		var callback = func(value: float) -> void:
			object.set(name, value)
			slider.value = object.get(name)
			slider.hint_tooltip = str(slider.value)
		
		slider.value_changed.connect(callback)
		return get_combo_container(name, slider)

## Handle [String] or [StringName] property.
class InspectorPropertyLine extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property.type == TYPE_STRING or property.type == TYPE_STRING_NAME
	
	func get_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var name := StringName(property.name)
		var line := LineEdit.new()
		line.text = object.get(name)
		line.hint_tooltip = line.text
		line.editable = is_editable(object, property, readonly)
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var callback = func(value: String) -> void:
			object.set(name, value)
			
			var caret = line.caret_column
			line.text = object.get(name)
			line.hint_tooltip = line.text
			line.caret_column = caret
		
		line.text_changed.connect(callback)
		return get_combo_container(name, line)

## Handle [String] or [StringName] property with [code]@export_multiline[/code] annotation.
class InspectorPropertyMultiline extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return (property.type == TYPE_STRING or property.type == TYPE_STRING_NAME) and property.hint == PROPERTY_HINT_MULTILINE_TEXT
	
	func get_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var hbox := HBoxContainer.new()
		var name := StringName(property.name)
		
		var text_edit := TextEdit.new()
		text_edit.text = object.get(name)
		text_edit.hint_tooltip = text_edit.text
		text_edit.editable = is_editable(object, property, readonly)
		text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		text_edit.minimum_size = Vector2(24.0, 96.0)
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
		window_edit.hint_tooltip = window_edit.text
		window.add_child(window_edit)
		# TextEdit don't emit changed text.
		var callback = func(edit: TextEdit) -> void:
			object.set(name, edit.text)
			
			var column := text_edit.get_caret_column()
			var line := text_edit.get_caret_line()
			
			text_edit.text = object.get(name)
			text_edit.hint_tooltip = text_edit.text
			text_edit.set_caret_column(column)
			text_edit.set_caret_line(line)
			
			column = window_edit.get_caret_column()
			line = window_edit.get_caret_line()
			
			window_edit.text = text_edit.text
			window_edit.hint_tooltip = window_edit.text
			window_edit.set_caret_column(column)
			window_edit.set_caret_line(line)
		
		maximize.pressed.connect(window.popup_centered)
		text_edit.text_changed.connect(callback.bind(text_edit))
		window.confirmed.connect(callback.bind(window_edit))
		
		return get_combo_container(name, hbox, true)

## Handle [Vector2] or [Vector2i] property.
class InspectorPropertyVector2 extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property.type == TYPE_VECTOR2 or property.type == TYPE_VECTOR2I
	
	func get_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var name := StringName(property.name)
		var value : Vector2 = object.get(name)
		
		var x_spin := SpinBox.new()
		x_spin.editable = is_editable(object, property, readonly)
		x_spin.prefix = "x"
		x_spin.min_value = -9223372036854775807 - 1
		x_spin.max_value = 9223372036854775807
		x_spin.step = 1.0 if property.type == TYPE_VECTOR2I else 0.001
		x_spin.value = value.x
		x_spin.hint_tooltip = str(value.x)
		x_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(x_spin)
		
		var y_spin := SpinBox.new()
		y_spin.editable = x_spin.editable
		y_spin.prefix = "y"
		y_spin.min_value = x_spin.min_value
		y_spin.max_value = x_spin.max_value
		y_spin.step = x_spin.step
		y_spin.value = value.y
		y_spin.hint_tooltip = str(value.y)
		y_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(y_spin)
		
		var callback = func(_v) -> void:
			object.set(name, Vector2(x_spin.value, y_spin.value))
			value = object.get(name)
			
			x_spin.value = value.x
			x_spin.hint_tooltip = str(x_spin.value)
			
			y_spin.value = value.y
			y_spin.hint_tooltip = str(y_spin.value)
		
		x_spin.value_changed.connect(callback)
		y_spin.value_changed.connect(callback)
		
		return get_combo_container(name, vbox)

## Handle [Vector3] or [Vector3i] property.
class InspectorPropertyVector3 extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property.type == TYPE_VECTOR3 or property.type == TYPE_VECTOR3I
	
	func get_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var name := StringName(property.name)
		var value : Vector3 = object.get(name)
		
		var hbox := HBoxContainer.new()
		
		var x_spin := SpinBox.new()
		x_spin.editable = is_editable(object, property, readonly)
		x_spin.prefix = "x"
		x_spin.min_value = -9223372036854775807 - 1
		x_spin.max_value = 9223372036854775807
		x_spin.step = 1.0 if property.type == TYPE_VECTOR3I else 0.001
		x_spin.value = value.x
		x_spin.hint_tooltip = str(x_spin.value)
		x_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(x_spin)
		
		var y_spin := SpinBox.new()
		y_spin.editable = x_spin.editable
		y_spin.prefix = "y"
		y_spin.min_value = x_spin.min_value
		y_spin.max_value = x_spin.max_value
		y_spin.step = x_spin.step
		y_spin.value = value.y
		y_spin.hint_tooltip = str(y_spin.value)
		y_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(y_spin)
		
		var z_spin := SpinBox.new()
		z_spin.editable = x_spin.editable
		z_spin.prefix = "z"
		z_spin.min_value = x_spin.min_value
		z_spin.max_value = x_spin.max_value
		z_spin.step = x_spin.step
		z_spin.value = value.z
		z_spin.hint_tooltip = str(z_spin.value)
		z_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(z_spin)
		
		var callback = func(_v) -> void:
			object.set(name, Vector3(x_spin.value, y_spin.value, z_spin.value))
			value = object.get(name)
			
			x_spin.value = value.x
			x_spin.hint_tooltip = str(x_spin.value)
			
			y_spin.value = value.y
			y_spin.hint_tooltip = str(y_spin.value)
			
			z_spin.value = value.z
			z_spin.hint_tooltip = str(z_spin.value)
		
		x_spin.value_changed.connect(callback)
		y_spin.value_changed.connect(callback)
		z_spin.value_changed.connect(callback)
		
		return get_combo_container(name, hbox, true)

## Handle [Color] property.
class InspectorPropertyColor extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property.type == TYPE_COLOR
	
	func get_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var name := StringName(property.name)
		var picker := ColorPickerButton.new()
		picker.color = object.get(name)
		picker.hint_tooltip = str(picker.color)
		picker.disabled = not is_editable(object, property, readonly)
		picker.edit_alpha = not property.hint == PROPERTY_HINT_COLOR_NO_ALPHA
		picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var callback = func(value: Color) -> void:
			object.set(name, value)
			picker.color = object.get(name)
			picker.hint_tooltip = str(picker.color)
		
		picker.color_changed.connect(callback)
		return get_combo_container(name, picker)

## Handle [code]enum[/code] property.
class InspectorPropertyEnum extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property.type == TYPE_INT and property.hint == PROPERTY_HINT_ENUM
	
	func get_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var option_button := OptionButton.new()
		option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option_button.disabled = not is_editable(object, property, readonly)
		
		var popup : PopupMenu = option_button.get_popup()
		for s in property.hint_string.split(",", false):
			var split = s.split(":", false) # [name, value]
			popup.add_item(split[0], split[1].to_int())
		
		var name := StringName(property.name)
		option_button.selected = popup.get_item_index(object.get(name))
		
		var callback = func(value: int) -> void:
			object.set(name, value)
			option_button.selected = popup.get_item_index(object.get(name))
		
		popup.id_pressed.connect(callback)
		return get_combo_container(name, option_button)

## Handle [int] property with [code]@export_flags[/code] annotation.
class InspectorPropertyFlags extends InspectorProperty:
	func can_handle(object: Object, property: Dictionary, readonly: bool) -> bool:
		return property.type == TYPE_INT and property.hint == PROPERTY_HINT_FLAGS
	
	func get_control(object: Object, property: Dictionary, readonly: bool) -> Control:
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var name := StringName(property.name)
		var value : int = object.get(name)
		
		var split : PackedStringArray = property.hint_string.split(",", false)
		for i in split.size():
			var flag := CheckBox.new()
			flag.text = split[i]
			flag.button_pressed = value & i
			flag.disabled = not is_editable(object, property, readonly)
			
			var callback = func(pressed: bool) -> void:
				if pressed:
					object.set(name, object.get(name) | (1 << i))
				else:
					object.set(name, object.get(name) & ~(1 << i))
				
				flag.button_pressed = object.get(name) & 1 << i
			
			flag.toggled.connect(callback)
			vbox.add_child(flag)
		
		return get_combo_container(name, vbox)

## Emitted when object changed.
signal object_changed(object: Object)


@export var _readonly := false: set = set_readonly, get = is_readonly
@export var _search_enabled := true: set = set_search_enabled, get = is_search_enabled


var _properties : Array[InspectorProperty]
var _object : Object

var _search : LineEdit

var _scroll_container : ScrollContainer
var _container : VBoxContainer


func _init() -> void:
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
	
	_search = LineEdit.new()
	_search.placeholder_text = tr("Filter properties")
	_search.size_flags_horizontal = SIZE_EXPAND_FILL
	_search.clear_button_enabled = true
	_search.right_icon = load("addons/object-inspector/icons/search.svg")
	_search.visible = _search_enabled
	_search.text_changed.connect(update_inspector)
	self.add_child(_search)
	
	_scroll_container = ScrollContainer.new()
	_scroll_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_scroll_container.size_flags_vertical = SIZE_EXPAND_FILL
	self.add_child(_scroll_container)

## Add a custom [InspectorProperty].
func add_inspector_property(property: InspectorProperty) -> void:
	assert(is_instance_valid(property), "Invalid InspectorProperty.")
	if is_instance_valid(property):
		_properties.push_front(property)

## Set Inspector readonly.
func set_readonly(value: bool) -> void:
	if _readonly != value:
		_readonly = value
		self.update_inspector()

## Return [code]true[/code] if Inspector is readonly.
func is_readonly() -> bool:
	return _readonly

## Set search line visible.
func set_search_enabled(value: bool) -> void:
	_search_enabled = value
	_search.visible = value

## Return [code]true[/code] if search line is enabled.
func is_search_enabled() -> bool:
	return _search_enabled

## Set edited object.
func set_object(object: Object) -> void:
	_object = object
	object_changed.emit(_object)
	
	self.update_inspector()

## Clear edited object.
func clear() -> void:
	self.set_object(null)

## Return edited object.
func get_object() -> Object:
	return _object

## Return [code]true[/code] if property is valid.
func is_valid_property(property: Dictionary) -> bool:
	return property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_DEFAULT

## Return [Control] for property.
func get_property_control(object: Object, property: Dictionary) -> Control:
	for p in _properties:
		if p.can_handle(object, property, is_readonly()):
			return p.get_control(object, property, is_readonly())
	
	return null

## Update Inspector properties.
func update_inspector(filter: String = _search.text) -> void:
	if is_instance_valid(_container):
		_container.queue_free()
	
	_container = VBoxContainer.new()
	_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_container.size_flags_vertical = SIZE_EXPAND_FILL
	_scroll_container.add_child(_container)
	
	if is_instance_valid(_object):
		for property in _object.get_property_list():
			if is_valid_property(property) and filter.is_subsequence_of(property.name):
				var property_control = get_property_control(_object, property)
				if is_instance_valid(property_control):
					_container.add_child(property_control)
	
	_search.editable = is_instance_valid(_object)
