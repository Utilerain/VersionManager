extends Window


@onready var mainform := get_node("/root/MainForm")
@onready var path := $MarginContainer/VBoxContainer/PathContainer/Path
@onready var args := $MarginContainer/VBoxContainer/ArgsContainer/Args

func _on_close_requested():
	hide()


func _on_folder_pressed():
	$FileDialog.show()


func _on_file_dialog_file_selected(fpath):
	path.text = fpath
