extends Node

class_name ImageLoader

#get path of image and globalize this
static func _get_path(path) -> String:
	return ProjectSettings.globalize_path(path)

#reads images for importing
static func _read_img(direction : String) -> Image:
	var path := _get_path(direction)
	var file_exists := FileAccess.file_exists(path)
	
	if not file_exists:
		push_error("Error loading image at -> " + path + " <- Please check that the image exists and the name is correct")
		return null

	var img  = Image.new()
	img.load(path)
	return img

#loads image. uses _read_img() for reading an image
static func load(path:String) -> ImageTexture:
	var img = _read_img(path)
	return ImageTexture.create_from_image(img)

#saves image. you can set custom name
static func save_img(img: Image, name: String = "image"):
	DirAccess.make_dir_absolute("user://cache")
	var path = "user://cache/" + name
	
	if not FileAccess.file_exists(path):
		print("Saving image at: %s" % path)
		img.save_png(path)
		
	return path
