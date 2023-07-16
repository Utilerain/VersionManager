extends Control

class_name VersionItem

signal button_pressed(sender: VersionItem)

@export var Name: String = "Godot Engine"
@export var Version: String = "0.0.0"
@export var Icon: ImageTexture
@export var Path: String = "PATH"
@export var Args: String

@onready var icon := $MarginContainer/HBoxContainer/icon
@onready var engine_name := $MarginContainer/HBoxContainer/VBoxContainer/EngineVerName
@onready var current_version := $MarginContainer/HBoxContainer/VBoxContainer/CurrentVersion

var default_icon: ImageTexture


func _ready():
	default_icon = ImageTexture.create_from_image(load("res://resources/logo_engines/default.png").get_image())
	
#sets parameters for version item
func _process(_delta):
	engine_name.text = Name
	current_version.text = "Version: %s" % Version
	if Icon:
		icon.texture = Icon
	else:
		icon.texture = default_icon
		Icon = default_icon

#sends itself as sender
func _on_pressed():
	button_pressed.emit(self)

#gets JSON (dictionary) for settings.json
func get_json():
	return {
		"name":Name,
		"icon":ImageLoader.save_img($MarginContainer/HBoxContainer/icon.texture.get_image(), str("%s%s%s%s" % [Name, Version, Icon.get_width(), Icon.get_height()]).sha256_text() + ".png"),
		"path":Path,
		"version":Version,
		"args":Args
	}
