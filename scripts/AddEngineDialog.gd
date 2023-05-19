extends Window

const platforms = { 
	"linux": {
		"suffixes": "(_linux|_x11)(\\.|_)(x86_)?(64|32)\\.zip"
	},
	"macos": {
		"suffixes": "_(osx|macos)(32|64)?(\\.universal|\\.fat)\\.zip"
	},
	"windows": {
		"suffixes": "_win(32|64)(\\.exe)?\\.zip"
	}
}

@onready var regex = RegEx.new()
@onready var versionlist = []
@onready var typelist = []
@onready var versionselect := $MarginContainer/VBoxContainer/VerContainer/VersionSelect
@onready var typeselect := $MarginContainer/VBoxContainer/VersionTypeContainer/TypeSelect
@onready var monosupport := $MarginContainer/VBoxContainer/CustomIconandCSSupportContainer/MonoSupport
@onready var customname := $MarginContainer/VBoxContainer/CustomNameContainer/LineEdit
@onready var customicon := $MarginContainer/VBoxContainer/CustomIconandCSSupportContainer/IconButton
@onready var thrd := Thread.new()

var current_platform
var selected_type = "stable"
var selected_version
var current_url


func _ready():
	$Req.request_completed.connect(self._on_request_completed)
	$Req.request(V_utils.base_url)
	
	if OS.has_feature("windows"):
		current_platform = "windows"
	elif OS.has_feature("macos"):
		current_platform = "macos"
	elif OS.has_feature("linux"):
		current_platform = "linux"


func _on_request_completed(_result, _response_code, _headers, body):
	versionlist = V_utils.scan_version(body)
	for i in versionlist:
		versionselect.add_item(i)
	
	$Req.request_completed.connect(self._on_verrequest_completed)
	$Req.request_completed.disconnect(self._on_request_completed)

#gets type of version: stable, alpha, beta, rc, dev
func _on_verrequest_completed(_result, _response_code, _headers, body):
	monosupport.disabled = V_utils.check_mono(body)
	monosupport.toggle_mode = not monosupport.disabled
	
	typeselect.clear()
	
	typelist = V_utils.scan_type(body)
	
	for i in typelist:
		typeselect.add_item(i)
	
	if len(typelist) < 1:
		Logger.error("can't find any types of version: %s" % selected_version)
		OS.alert("Can't find any types for this version. Select other")
		return
	selected_type = typelist[typeselect.selected]


func _on_version_select_item_selected(index):
	current_url = V_utils.base_url + versionlist[index]
	selected_version = versionlist[index]
	$Req.request(current_url)


func _on_type_select_item_selected(index):
	selected_type = typelist[index]


func _on_mono_support_toggled(button_pressed):
	if button_pressed and not monosupport.disabled:
		current_url = V_utils.base_url + versionlist[versionselect.selected] + "/mono"
	else:
		current_url = V_utils.base_url + versionlist[versionselect.selected]

#starts download process
func _on_download_button_pressed():
	var err = V_utils.check_version(selected_version)
	if err == ERR_INVALID_DATA:
		return
	
	var mainform = get_node("/root/MainForm")
	thrd.start(mainform.start_download_progress.bind(selected_version, selected_type, platforms[current_platform]["suffixes"], customname.text, customicon.icon, monosupport.button_pressed))
	hide()
	thrd.wait_to_finish()

#changes icon
func _on_icon_button_pressed():
	$FileDialog.show()


func _on_close_requested():
	hide()


func _on_file_dialog_file_selected(path):
	customicon.icon = ImageLoader.load(path)
