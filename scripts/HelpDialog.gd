extends Window


func _on_close_requested():
	hide()


func _on_about_meta_clicked(meta):
	OS.shell_open(meta)
