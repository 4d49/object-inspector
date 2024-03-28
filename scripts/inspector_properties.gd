# Copyright (c) 2022-2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

# Magic numbers, but otherwise the SpinBox does not work correctly.
const INT32_MIN = -2147483648
const INT32_MAX =  2147483647

## Handle [annotation @GDScript.@export_category] property.
class InspectorPropertyCategory extends InspectorProperty:
	var _container: VBoxContainer = null
	var _title: Label = null

	func _enter_tree() -> void:
		_container = VBoxContainer.new()
		_container.set_name("Container")

		_title = Label.new()
		_title.set_name("Title")
		_title.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		_title.set_text(get_property().capitalize())
		_container.add_child(_title, false, Node.INTERNAL_MODE_FRONT)

		self.add_child(_container)

	static func can_handle(_object: Object, property: Dictionary) -> bool:
		return property["usage"] == PROPERTY_USAGE_CATEGORY

## Handle [bool] property.
class InspectorPropertyBool extends InspectorProperty:
	var _check_box: CheckBox = null

	func _enter_tree() -> void:
		_check_box = CheckBox.new()
		_check_box.set_text("On")
		_check_box.set_pressed_no_signal(get_value())
		_check_box.toggled.connect(_on_check_box_toggled)

		create_combo_container(get_property(), _check_box)

	func _on_check_box_toggled(toggled: bool) -> void:
		_check_box.set_pressed_no_signal(set_and_return_value(toggled))

	static func can_handle(_object: Object, property: Dictionary) -> bool:
		return property["type"] == TYPE_BOOL

## Handle [int] or [float] property.
class InspectorPropertyNumber extends InspectorProperty:
	var _spin_box: SpinBox = null

	func _enter_tree() -> void:
		_spin_box = SpinBox.new()

		if get_hint() == PROPERTY_HINT_RANGE:
			var split: PackedStringArray = get_hint_string().split(',', false)

			_spin_box.set_min(split[0].to_float() if split.size() >= 1 and split[0].is_valid_float() else INT32_MIN)
			_spin_box.set_max(split[1].to_float() if split.size() >= 2 and split[1].is_valid_float() else INT32_MAX)
			_spin_box.set_step(split[2].to_float() if split.size() >= 3 and split[2].is_valid_float() else 1.0 if get_type() == TYPE_INT else 0.001)
		else:
			_spin_box.set_min(INT32_MIN)
			_spin_box.set_max(INT32_MAX)
			_spin_box.set_step(1.0 if get_type() == TYPE_INT else 0.001)

		_spin_box.set_use_rounded_values(get_type() == TYPE_INT)
		_spin_box.set_value_no_signal(get_value())
		_spin_box.value_changed.connect(_on_spin_box_value_changed)

		create_combo_container(get_property(), _spin_box)

	func _on_spin_box_value_changed(value: float) -> void:
		_spin_box.set_value_no_signal(set_and_return_value(value))

	static func can_handle(_object: Object, property: Dictionary) -> bool:
		return property["type"] == TYPE_INT or property["type"] == TYPE_FLOAT

## Handle [String] or [StringName] property.
class InspectorPropertyString extends InspectorProperty:
	var _line_edit: LineEdit = null

	func _enter_tree() -> void:
		_line_edit = LineEdit.new()
		_line_edit.set_text(get_value())
		_line_edit.text_changed.connect(_on_line_edit_text_changed)

		create_combo_container(get_property(), _line_edit)

	func _on_line_edit_text_changed(text: String) -> void:
		var caret := _line_edit.get_caret_column()
		_line_edit.set_text(set_and_return_value(text))
		_line_edit.set_caret_column(caret)

	static func can_handle(_object: Object, property: Dictionary) -> bool:
		return property["type"] == TYPE_STRING or property["type"] == TYPE_STRING_NAME

## Handle [String] or [StringName] property with [param @export_multiline] annotation.
class InspectorPropertyMultiline extends InspectorProperty:
	var _text_edit: TextEdit = null
	var _maximize: Button = null

	var _window: AcceptDialog = null
	var _window_text_edit: TextEdit = null

	func _enter_tree() -> void:
		_text_edit = TextEdit.new()
		_text_edit.set_name("TextEdit")
		_text_edit.set_text(get_value())
		_text_edit.set_tooltip_text(_text_edit.get_text())
		_text_edit.set_line_wrapping_mode(TextEdit.LINE_WRAPPING_BOUNDARY)
		_text_edit.set_custom_minimum_size(Vector2(24.0, 96.0))
		_text_edit.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		_text_edit.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		_text_edit.text_changed.connect(_on_text_edit_text_changed)

		var hbox := HBoxContainer.new()
		hbox.add_child(_text_edit)

		_maximize = Button.new()
		_maximize.set_name("Maximize")
		_maximize.set_button_icon(preload("res://addons/object-inspector/icons/maximize.svg"))
		_maximize.set_flat(true)
		_maximize.set_v_size_flags(Control.SIZE_SHRINK_CENTER)
		_maximize.pressed.connect(_on_maximize_pressed)
		hbox.add_child(_maximize)

		create_combo_container(get_property(), hbox, true)

	func _on_text_edit_text_changed() -> void:
		var column: int = _text_edit.get_caret_column()
		var line: int = _text_edit.get_caret_line()

		_text_edit.set_text(set_and_return_value(_text_edit.get_text()))
		_text_edit.set_caret_column(column)
		_text_edit.set_caret_line(line)

	func _on_window_confirmed() -> void:
		var column: int = _window_text_edit.get_caret_column()
		var line: int = _window_text_edit.get_caret_line()

		_window_text_edit.set_text(set_and_return_value(_window_text_edit.get_text()))
		_window_text_edit.set_caret_column(column)
		_window_text_edit.set_caret_line(line)
		_text_edit.set_text(_window_text_edit.get_text())

	func _on_maximize_pressed() -> void:
		if not is_instance_valid(_window):
			_window = AcceptDialog.new()
			_window.set_name("EditTextDialog")
			_window.set_title("Text edit")
			_window.set_min_size(Vector2(640, 480))
			_window.add_cancel_button("Cancel")
			_window.set_ok_button_text("Save")
			_window.confirmed.connect(_on_window_confirmed)
			self.add_child(_window)

			_window_text_edit = TextEdit.new()
			_window_text_edit.set_name("TextEdit")
			_window_text_edit.set_text(get_value())
			_window.add_child(_window_text_edit)

		_window_text_edit.set_text(get_value())
		_window.popup_centered_clamped(Vector2(640, 480))

	static func can_handle(_object: Object, property: Dictionary) -> bool:
		return property["hint"] == PROPERTY_HINT_MULTILINE_TEXT and (property["type"] == TYPE_STRING or property["type"] == TYPE_STRING_NAME)

## Handle [Vector2] or [Vector2i] property.
class InspectorPropertyVector2 extends InspectorProperty:
	var _x_spin: SpinBox = null
	var _y_spin: SpinBox = null

	func _enter_tree() -> void:
		var vbox = VBoxContainer.new()
		vbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)

		var value: Vector2 = get_value()

		_x_spin = SpinBox.new()
		_x_spin.set_name("x")
		_x_spin.set_prefix("x")
		_x_spin.set_min(INT32_MIN)
		_x_spin.set_max(INT32_MAX)
		_x_spin.set_step(1.0 if get_type() == TYPE_VECTOR2I else 0.001)
		_x_spin.set_use_rounded_values(get_type() == TYPE_VECTOR2I)
		_x_spin.set_value_no_signal(value.x)
		_x_spin.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		_x_spin.value_changed.connect(_on_value_changed)
		vbox.add_child(_x_spin)

		_y_spin = _x_spin.duplicate()
		_y_spin.set_name("y")
		_y_spin.set_prefix("y")
		_y_spin.set_value_no_signal(value.y)
		_y_spin.value_changed.connect(_on_value_changed)
		vbox.add_child(_y_spin)

		var label: Label = create_combo_container(get_property(), vbox).get_node(^"Label")
		label.set_v_size_flags(Control.SIZE_SHRINK_BEGIN)

	func _on_value_changed(_value: float) -> void:
		var value: Vector2 = set_and_return_value(Vector2(_x_spin.get_value(), _y_spin.get_value()))
		_x_spin.set_value_no_signal(value.x)
		_y_spin.set_value_no_signal(value.y)

	static func can_handle(object: Object, property: Dictionary) -> bool:
		return property["type"] == TYPE_VECTOR2 or property["type"] == TYPE_VECTOR2I

## Handle [Vector3] or [Vector3i] property.
class InspectorPropertyVector3 extends InspectorProperty:
	var _x_spin: SpinBox = null
	var _y_spin: SpinBox = null
	var _z_spin: SpinBox = null

	func _enter_tree() -> void:
		var hbox := HBoxContainer.new()

		var value: Vector3 = get_value()

		_x_spin = SpinBox.new()
		_x_spin.set_name("x")
		_x_spin.set_prefix("x")
		_x_spin.set_min(INT32_MIN)
		_x_spin.set_max(INT32_MAX)
		_x_spin.set_step(1.0 if get_type() == TYPE_VECTOR3I else 0.001)
		_x_spin.set_use_rounded_values(get_type() == TYPE_VECTOR3I)
		_x_spin.set_value_no_signal(value.x)
		_x_spin.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		_x_spin.value_changed.connect(_on_value_changed)
		hbox.add_child(_x_spin)

		_y_spin = _x_spin.duplicate()
		_y_spin.set_name("y")
		_y_spin.set_prefix("y")
		_y_spin.set_value_no_signal(value.y)
		_y_spin.value_changed.connect(_on_value_changed)
		hbox.add_child(_y_spin)

		_z_spin = _x_spin.duplicate()
		_z_spin.set_name("z")
		_z_spin.set_prefix("z")
		_z_spin.set_value_no_signal(value.z)
		_z_spin.value_changed.connect(_on_value_changed)
		hbox.add_child(_z_spin)

		create_combo_container(get_property(), hbox, true)

	func _on_value_changed(_value: float) -> void:
		var value: Vector3 = set_and_return_value(Vector3(_x_spin.get_value(), _y_spin.get_value(), _z_spin.get_value()))
		_x_spin.set_value_no_signal(value.x)
		_y_spin.set_value_no_signal(value.y)
		_z_spin.set_value_no_signal(value.z)

	static func can_handle(_object: Object, property: Dictionary) -> bool:
		return property["type"] == TYPE_VECTOR3 or property["type"] == TYPE_VECTOR3I

## Handle [Color] property.
class InspectorPropertyColor extends InspectorProperty:
	var _color_picker: ColorPickerButton = null

	func _enter_tree() -> void:
		_color_picker = ColorPickerButton.new()
		_color_picker.set_pick_color(get_value())
		_color_picker.set_edit_alpha(get_hint() == PROPERTY_HINT_COLOR_NO_ALPHA)
		_color_picker.color_changed.connect(_on_picker_color_changed)

		var picker: ColorPicker = _color_picker.get_picker()
		picker.set_presets_visible(false)

		create_combo_container(get_property(), _color_picker)

	func _on_picker_color_changed(color: Color) -> void:
		_color_picker.set_pick_color(set_and_return_value(color))

	static func can_handle(_object: Object, property: Dictionary) -> bool:
		return property["type"] == TYPE_COLOR

## Handle [param enum] property.
class InspectorPropertyEnum extends InspectorProperty:
	var _option_button: OptionButton = null

	func _enter_tree() -> void:
		_option_button = OptionButton.new()
		_option_button.set_clip_text(true)

		var hint_split: PackedStringArray = get_hint_string().split(",", false)

		for i: int in hint_split.size():
			var split := hint_split[i].split(":", false)

			# If key-value pair.
			if split.size() > 1 and split[1].is_valid_int():
				_option_button.add_item(split[0], split[1].to_int())
			else:
				_option_button.add_item(split[0], i)

		_option_button.select(_option_button.get_item_index(get_value()))
		_option_button.get_popup().id_pressed.connect(_on_id_pressed)

		create_combo_container(get_property(), _option_button)

	func _on_id_pressed(id: int) -> void:
		_option_button.select(_option_button.get_item_index(set_and_return_value(id)))

	static func can_handle(_object: Object, property: Dictionary) -> bool:
		return property["hint"] == PROPERTY_HINT_ENUM and property["type"] == TYPE_INT

## Handle [int] property with [param @export_flags] annotation.
class InspectorPropertyFlags extends InspectorProperty:
	func _enter_tree() -> void:
		var vbox = VBoxContainer.new()

		var value: int = get_value()

		var split : PackedStringArray = get_hint_string().split(",", false)
		for i in split.size():
			var check_box := CheckBox.new()
			check_box.set_text(split[i])
			check_box.set_pressed(value & (1 << i))

			check_box.toggled.connect(func(pressed: bool) -> void:
				if pressed:
					set_value(get_value() | (1 << i))
				else:
					set_value(get_value() & ~(1 << i))

				check_box.set_pressed(get_value() & 1 << i)
			)

			vbox.add_child(check_box)

		var label: Label = create_combo_container(get_property(), vbox).get_node(^"Label")
		label.set_v_size_flags(Control.SIZE_SHRINK_BEGIN)

	static func can_handle(_object: Object, property: Dictionary) -> bool:
		return property["hint"] == PROPERTY_HINT_FLAGS and property["type"] == TYPE_INT


static func _static_init() -> void:
	InspectorProperty.declare_property(InspectorPropertyCategory.can_handle, InspectorPropertyCategory.new)
	InspectorProperty.declare_property(InspectorPropertyBool.can_handle, InspectorPropertyBool.new)
	InspectorProperty.declare_property(InspectorPropertyNumber.can_handle, InspectorPropertyNumber.new)
	InspectorProperty.declare_property(InspectorPropertyString.can_handle, InspectorPropertyString.new)
	InspectorProperty.declare_property(InspectorPropertyMultiline.can_handle, InspectorPropertyMultiline.new)
	InspectorProperty.declare_property(InspectorPropertyVector2.can_handle, InspectorPropertyVector2.new)
	InspectorProperty.declare_property(InspectorPropertyVector3.can_handle, InspectorPropertyVector3.new)
	InspectorProperty.declare_property(InspectorPropertyColor.can_handle, InspectorPropertyColor.new)
	InspectorProperty.declare_property(InspectorPropertyEnum.can_handle, InspectorPropertyEnum.new)
	InspectorProperty.declare_property(InspectorPropertyFlags.can_handle, InspectorPropertyFlags.new)
