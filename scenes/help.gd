class_name HelpMenu
extends Control

@onready var exit_button=$MarginContainer/VBoxContainer/Button as Button

signal exit_help_menu

func _ready():
	exit_button.button_down.connect(on_exit_pressed)
	set_process(false)

func on_exit_pressed() -> void:
	exit_help_menu.emit()
	set_process(false)
