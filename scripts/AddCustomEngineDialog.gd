extends Window

const url = "https://downloads.tuxfamily.org/godotengine/" #url for searching godot versions

@onready var versionselect = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/VersionContainer/VersionSelect
@onready var typeselect = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TypeContainer/TypeSelect
@onready var icondialog = $IconDialog
@onready var filedialog = $FileDialog
@onready var customname = $MarginContainer/VBoxContainer/MainInfoContainer/NameContainer/Name
@onready var customicon = $MarginContainer/VBoxContainer/MainInfoContainer/icon
@onready var monosupport = $MarginContainer/VBoxContainer/HBoxContainer/MonoSupport

var typelist
var versionlist
var selected_type = "stable"
var selected_version
var current_url

func _ready():
	$Req.connect("request_completed", self._on_request_completed)
	$Req.request(url)
	

func _on_close_requested():
	hide()


func _on_request_completed(_result, _response_code, _headers, body):
	versionlist = VersionScanner.scan_version(body)
	for i in versionlist:
		versionselect.add_item(i)
	
	$Req.connect("request_completed", self._on_verrequest_completed)
	$Req.disconnect("request_completed", self._on_request_completed)

#gets type of version: stable, alpha, beta, rc, dev
func _on_verrequest_completed(_result, _response_code, _headers, body):
	monosupport.disabled = VersionScanner.check_mono(body)
	monosupport.toggle_mode = not monosupport.disabled
	
	typeselect.clear()
	
	typelist = VersionScanner.scan_type(body)
	
	for i in typelist:
		typeselect.add_item(i)
	
	if len(typelist) < 1:
		push_error("Can't find any types of version")
		OS.alert("Can't find any types for this version. Select other")
		return
	selected_type = typelist[typeselect.selected]

func _on_version_select_item_selected(index):
	current_url = url + versionlist[index]
	selected_version = versionlist[index]
	$Req.request(current_url)


func _on_type_select_item_selected(index):
	selected_type = typelist[index]


