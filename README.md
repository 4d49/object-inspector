# Object Inspector
In-game property inspector for Godot 4.4+

![](https://github.com/4d49/object-inspector/assets/8208165/1e57adc5-9941-43dd-9aeb-50df146f00c4)

# Support types:
- Bool
- Int
- Float
- String, StringName
- Color
- Vector2, Vector2i
- Vector3, Vector3i
- Enum
- Flags
- Typed/Untyped Arrays and PackedArrays
- Typed/Untyped Dictionaries
- Category, Group and Subgroup

# Installation:
1. `git clone` this repository to the `addons` folder or download the latest [release](https://github.com/4d49/object-inspector/releases/latest/download/object-inspector.zip).
2. Enabled `Object Inspector` in Plugins.

# Usage:
1. Add `ObjectInspector` node to the scene.
2. Apply the example theme to the `ObjectInspector` node.
3. Call `set_object` method.
4. Done!

# Code example:
```gdscript
# Some script.gd...

@onready var inspector: Inspector = $Inspector # Path to our inspector in a tree.

func _ready() -> void:
	# Some object that we get from some method.
	var object: Object = get_object()

	# Sets our object to our inspector.
	inspector.set_object(object)
```

## Custom property description:
```gdscript
class Item extends Object:
	@export var cost: int

	static func _static_init() -> void:
		Inspector.add_script_property_description(Item, "cost", "The item's value in in-game currency")
```

## Declare custom property:
```gdscript
# Validation method must return `true` if the property can be handled. Example:
static func can_handle(object: Object, property: Dictionary) -> bool:
	return property["type"] == TYPE_FLOAT

# Constructor method must return an object of class `Control`.
static func create_control(object: Object, property: Dictionary, setter: Callable, getter: Callable) -> Control:
	var spin_box := SpinBox.new()
	spin_box.set_value_no_signal(getter.call())

	if setter.is_valid():
		spin_box.value_changed.connect(setter)
	else:
		spin_box.set_editable(false)

	return spin_box

# Some script.gd...
# Declare custom property handler.
static func _static_init() -> void:
	InspectorProperty.declare_property(can_handle, create_control)
```

# License
Copyright (c) 2022-2025 Mansur Isaev and contributors

Unless otherwise specified, files in this repository are licensed under the
MIT license. See [LICENSE.md](LICENSE.md) for more information.
