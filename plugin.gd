# Copyright © 2021 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

tool
extends EditorPlugin


const INSPECTOR_CONTAINER_NAME   = "ObjectInspector"
const INSPECTOR_CONTAINER_SCRIPT = "res://addons/object-inspector/scripts/inspector.gd"
const INSPECTOR_CONTAINER_ICON   = "res://addons/object-inspector/icons/inspector_container.svg"


func _enter_tree() -> void:
	add_custom_type(INSPECTOR_CONTAINER_NAME, "VBoxContainer", load(INSPECTOR_CONTAINER_SCRIPT), load(INSPECTOR_CONTAINER_ICON))
	return


func _exit_tree() -> void:
	remove_custom_type(INSPECTOR_CONTAINER_NAME)
	return
