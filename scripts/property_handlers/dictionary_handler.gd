# Copyright (c) 2022-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## [PropertyHandler] class for [Dictionary].
extends "../property_handler.gd"


const Paginator = preload("res://addons/object-inspector/scripts/inspector_property_paginator.gd")


var _container: VBoxContainer = null
var _dictionary_control: InspectorPropertyTypeDictionary = null


func _init(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> void:
	super(object, property, setter, getter)
	self.set_theme_type_variation(&"PropertyHandlerDictionary")

	_container = VBoxContainer.new()
	_container.set_name("Container")

	var hbox := HBoxContainer.new()
	_container.add_child(hbox)

	var label := Label.new()
	label.set_name("Label")
	label.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	label.set_text(String(property.name).capitalize())
	label.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	label.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
	label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	label.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	label.set_stretch_ratio(0.75)
	hbox.add_child(label)

	_dictionary_control = create_dictionary_control(setter, getter)
	_dictionary_control.set_name("Property")
	_dictionary_control.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	_dictionary_control.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	hbox.add_child(_dictionary_control)

	self.add_child(_container)


static func can_handle(_obj: Object, property: Dictionary) -> bool:
	return property.type == TYPE_DICTIONARY


static func _static_init() -> void:
	InspectorPropertyType.register_type(TYPE_DICTIONARY, "Dictionary", create_dictionary_control)


class InspectorPropertyTypeDictionary extends Button:
	var _dict: Dictionary = {}
	var _dict_keys: Array = []
	var _is_readonly: bool = false

	var _vbox: VBoxContainer = null

	var _paginator: Paginator = null

	var _key_type: Variant.Type = TYPE_NIL
	var _key_value: Variant = null

	var _value_type: Variant.Type = TYPE_NIL
	var _value: Variant = null

	var _key_container: BoxContainer = null
	var _key_label: Label = null
	var _key_control: Control = null
	var _key_edit: MenuButton = null

	var _value_container: BoxContainer = null
	var _value_label: Label = null
	var _value_control: Control = null
	var _value_edit: MenuButton = null

	var _add_button: Button = null

	func _init(dictionary: Dictionary, readonly: bool) -> void:
		self.set_theme_type_variation(&"PropertyHandlerDictionary")

		_dict = dictionary
		_dict_keys = dictionary.keys()
		_is_readonly = readonly or dictionary.is_read_only()

		self.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
		self.set_text(dictionary_to_text(dictionary))
		self.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		self.set_toggle_mode(true)
		self.toggled.connect(_on_button_pressed)
		self.tree_exiting.connect(func() -> void:
			if is_instance_valid(_vbox):
				_vbox.queue_free()
		)

	func update_paginator() -> void:
		_paginator.set_element_count(_dict.size(), true)

	func create_label(key: Variant) -> Label:
		var label := Label.new()
		label.set_modulate(Color(Color.WHITE, 0.5))
		label.set_name("Label")
		label.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
		label.set_text(str(key))
		label.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		label.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		label.set_stretch_ratio(0.75)

		return label

	func init_type_popup(popup: PopupMenu, callable: Callable) -> void:
		var type_list: Array[Dictionary] = InspectorPropertyType.get_type_list()

		popup.set_item_count(type_list.size())
		for i: int in type_list.size():
			popup.set_item_text(i, type_list[i]["name"])
			popup.set_item_id(i, type_list[i]["type"])

		popup.id_pressed.connect(callable)

	func create_delete_button(key: Variant) -> Button:
		var delete := Button.new()
		delete.set_name("Delete")
		delete.set_button_icon(get_theme_icon(&"delete"))
		delete.pressed.connect(func() -> void:
			erase_value(key)
		)

		return delete

	func create_edit_button(key: Variant) -> MenuButton:
		const DELETE: int = 0x100

		var edit := MenuButton.new()
		edit.set_flat(false)
		edit.set_name("Edit")
		edit.set_button_icon(get_theme_icon(&"edit"))

		var popup: PopupMenu = edit.get_popup()
		var callable: Callable = func(id: int) -> void:
			if id == DELETE:
				erase_value(key)
			else:
				add_value(key, type_convert(null, id))

		init_type_popup(popup, callable)

		popup.add_separator()
		popup.add_item("Delete", DELETE)
		popup.set_item_icon(-1, get_theme_icon(&"delete"))

		return edit

	func create_control(type: Variant.Type, setter: Callable, getter: Callable) -> BoxContainer:
		return InspectorPropertyType.create_control(type, setter, getter)

	func create_element(index: int) -> Container:
		var key: Variant = _dict_keys[index]

		var setter: Callable = Callable() if _is_readonly else func(value: Variant) -> void:
			_dict[key] = value
		var getter: Callable = func() -> Variant:
			return _dict[key]

		var control: Control = null
		if _dict.is_typed_value():
			control = create_control(_dict.get_typed_value_builtin(), setter, getter)
		else:
			control = create_control(typeof(_dict[key]), setter, getter)

		if not is_instance_valid(control):
			return null

		control.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		control.set_v_size_flags(Control.SIZE_EXPAND_FILL)

		var hbox := HBoxContainer.new()

		var container := VBoxContainer.new()
		container.set_name("Container")
		container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		hbox.add_child(container)

		var header := BoxContainer.new()
		header.add_child(create_label(key))
		header.add_child(control)
		header.set_vertical(control.is_in_group(&"vertical"))
		container.add_child(header)

		if not _is_readonly:
			if _dict.is_typed_value():
				hbox.add_child(create_delete_button(key))
			else:
				hbox.add_child(create_edit_button(key))

		return hbox

	func set_key_value(key_value: Variant) -> void:
		_key_value = key_value
	func get_key_value() -> Variant:
		return _key_value

	func set_key_type(type: Variant.Type) -> void:
#		if _key_type == type:
#			return

		_key_value = type_convert(null, type)

		if is_instance_valid(_key_control):
			_key_control.queue_free()

		_key_control = create_control(type, set_key_value, get_key_value)
		if is_instance_valid(_key_control):
			_key_control.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			_key_control.set_v_size_flags(Control.SIZE_EXPAND_FILL)

			_key_container.set_vertical(_key_control.is_in_group(&"vertical"))
			_key_container.add_child(_key_control)

		_key_type = type
	func get_key_type() -> Variant.Type:
		return _key_type

	func set_value(value: Variant) -> void:
		_value = value
	func get_value() -> Variant:
		return _value

	func update_title() -> void:
		self.set_text(dictionary_to_text(_dict))

	func add_value(key: Variant, value: Variant) -> void:
		if _dict.set(key, value):
			_dict_keys = _dict.keys()

			update_title()
			update_paginator()
	func erase_value(key: Variant) -> void:
		if _dict.erase(key):
			_dict_keys = _dict.keys()

			update_title()
			update_paginator()

	func set_value_type(type: Variant.Type) -> void:
#		if _value_type == type:
#			return

		_value = type_convert(null, type)

		if is_instance_valid(_value_control):
			_value_control.queue_free()

		_value_control = create_control(type, set_value, get_value)
		if is_instance_valid(_value_control):
			_value_control.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			_value_control.set_v_size_flags(Control.SIZE_EXPAND_FILL)

			_value_container.set_vertical(_value_control.is_in_group(&"vertical"))
			_value_container.add_child(_value_control)

		_value_type = type
	func get_value_type() -> Variant.Type:
		return _value_type

	func create_null_control() -> Control:
		var label := Label.new()
		label.set_text(str(null))
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)

		return label

	func _on_add_pressed() -> void:
		add_value(_key_value, _value)

	func _on_button_pressed(expanded: bool) -> void:
		if not expanded:
			if is_instance_valid(_vbox):
				_vbox.queue_free()

			return

		_vbox = VBoxContainer.new()

		var paginator_panel := PanelContainer.new()
		paginator_panel.set_theme_type_variation(&"InspectorSubProperty")
		_vbox.add_child(paginator_panel)

		_paginator = Paginator.new(create_element)
		_paginator.set_name("Paginator")
		paginator_panel.add_child(_paginator)

		if not _is_readonly:
			var add_panel := PanelContainer.new()
			add_panel.set_theme_type_variation(&"InspectorSubProperty")
			_vbox.add_child(add_panel)

			var add_vbox := VBoxContainer.new()
			add_panel.add_child(add_vbox)

			#region New Key
			var key_hbox := HBoxContainer.new()
			add_vbox.add_child(key_hbox)

			var key_vbox := VBoxContainer.new()
			key_vbox.set_name("Container")
			key_vbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			key_vbox.set_v_size_flags(Control.SIZE_EXPAND_FILL)
			key_hbox.add_child(key_vbox)

			_key_container = BoxContainer.new()
			_key_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			_key_container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
			key_vbox.add_child(_key_container)

			_key_label = Label.new()
			_key_label.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
			_key_label.set_text("New Key:")
			_key_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			_key_container.add_child(_key_label)

			if _dict.is_typed_key():
				set_key_type(_dict.get_typed_key_builtin())
			else:
				_key_control = create_null_control()
				_key_container.add_child(_key_control)

				_key_edit = MenuButton.new()
				_key_edit.set_flat(false)
				_key_edit.set_button_icon(get_theme_icon(&"edit"))
				init_type_popup(_key_edit.get_popup(), set_key_type)
				key_hbox.add_child(_key_edit)
			#endregion

			#region New Value
			var value_hbox := HBoxContainer.new()
			add_vbox.add_child(value_hbox)

			var value_vbox := VBoxContainer.new()
			value_vbox.set_name("Container")
			value_vbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			value_vbox.set_v_size_flags(Control.SIZE_EXPAND_FILL)
			value_hbox.add_child(value_vbox)

			_value_container = BoxContainer.new()
			_value_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			_value_container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
			value_vbox.add_child(_value_container)

			_value_label = Label.new()
			_value_label.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_ELLIPSIS)
			_value_label.set_text("New Value:")
			_value_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			_value_container.add_child(_value_label)

			if _dict.is_typed_value():
				set_value_type(_dict.get_typed_value_builtin())
			else:
				_value_control = create_null_control()
				_value_container.add_child(_value_control)

				_value_edit = MenuButton.new()
				_value_edit.set_flat(false)
				_value_edit.set_name("KeyEdit")
				_value_edit.set_button_icon(get_theme_icon(&"edit"))
				init_type_popup(_value_edit.get_popup(), set_value_type)
				value_hbox.add_child(_value_edit)
			#endregion

			add_vbox.add_child(HSeparator.new())

			_add_button = Button.new()
			_add_button.set_text("Add Key/Value Pair")
			_add_button.pressed.connect(_on_add_pressed)
			add_vbox.add_child(_add_button, false, Node.INTERNAL_MODE_BACK)

		update_paginator()
		find_parent("Container").add_child(_vbox)

	static func dictionary_to_text(dict: Dictionary) -> String:
		var string: String = "Dictionary"
		if dict.is_typed():
			string += "[" + type_string(dict.get_typed_key_builtin()) + ", " + type_string(dict.get_typed_value_builtin()) + "]"

		return string + " (size " + str(dict.size()) + ")"


static func create_dictionary_control(setter: Callable, getter: Callable) -> InspectorPropertyTypeDictionary:
	var dictionary: Dictionary = getter.call()
	var dictionary_control := InspectorPropertyTypeDictionary.new(dictionary, not setter.is_valid())

	return dictionary_control
