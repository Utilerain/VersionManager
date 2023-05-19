extends Window

@onready var linever := $MarginContainer/VBoxContainer/FolderContainer/FolderLine
@onready var mainform := get_node("/root/MainForm")
@onready var verdb := VersionDatabase.new()
@onready var buttoncache := $MarginContainer/VBoxContainer/ClearCacheContainer/ClearCache

func _ready():	
	linever.text = verdb.load_default_path()


func _process(_delta):
	buttoncache.text = "clear cache (%s)" % get_cache()


func _on_close_requested():
	hide()


func _on_folder_pressed():
	$FileDialog.show()


func _on_save_pressed():
	
	if DirAccess.dir_exists_absolute(linever.text):
		mainform.default_version_path = linever.text
	else:
		Logger.error("folder doesn't exist: %s" % [linever.text])
		OS.alert("This folder doesn't exist. Did you make mistake?", "Warning!")
	hide()


func _on_file_dialog_dir_selected(dir):
	linever.text = dir


func get_cache():
	var sizes = [
		"B",
		"KB",
		"MB",
		"GB",
		"TB"
	]
	var total_size: float = 0
	var count_division = 0
	var dir = DirAccess.open("user://cache")
	if not dir:
		return "0B"
		
	for i in dir.get_files():
		var file = FileAccess.open("user://cache/" + i,FileAccess.READ)
		total_size += file.get_length()
	
	while total_size > 1024:
		count_division += 1
		total_size /= 1024
	
	return "%0.2f%s" % [total_size, sizes[count_division]]

#clears cache
func _on_clear_cache_pressed():
	var path = "user://cache"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var file_path = path + "/" + file_name
			dir.remove(file_path)
			file_name = dir.get_next()
		dir = null
