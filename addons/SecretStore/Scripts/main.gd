@tool
extends EditorPlugin

var secret_dock:Control = load(addon_path.path_join("Scenes/SecretDock.tscn")).instantiate()
var secrets_list:Panel = secret_dock.get_node(^"Background/SecretsList")
var password_panel:Panel = secret_dock.get_node(^"Background/PasswordPanel")
var export_file_dialog:FileDialog = secret_dock.get_node(^"Background/ExportFileDialog")
var file_path_input:LineEdit = password_panel.get_node(^"Box/FilePathInput")
var password_input:LineEdit = password_panel.get_node(^"Box/PasswordInput")
var submit_button:BaseButton = password_panel.get_node(^"Box/SubmitContainer/Submit")
var export_button:BaseButton = secrets_list.get_node(^"Box/Export")
var save_button:BaseButton = secrets_list.get_node(^"Box/Save")
var lock_button:BaseButton = secrets_list.get_node(^"Box/Lock")
var add_button:BaseButton = secrets_list.get_node(^"Box/Add")
var secret_template:Control = secrets_list.get_node(^"Scroll/Box/SecretTemplate")

const addon_path:String = "res://addons/SecretStore"

func get_entries(file_path:String, password:String):
	# Read encrypted entries
	var file := FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, password)
	if file == null:
		return null
	return JSON.parse_string(file.get_as_text())

func _enter_tree()->void:
	# Add dock
	add_control_to_bottom_panel(secret_dock, "Secrets")
	
	# Connect buttons
	submit_button.pressed.connect(_submit_password)
	export_button.pressed.connect(_export_entries)
	save_button.pressed.connect(_save_entries)
	lock_button.pressed.connect(_lock_entries)
	add_button.pressed.connect(func():
		_add_entry("", ""))
	export_file_dialog.file_selected.connect(func(path:String):
		_save_entries(path))
	
	# Show panels
	secrets_list.show()
	password_panel.show()

func _exit_tree()->void:
	# Remove dock
	remove_control_from_bottom_panel(secret_dock)

func _load_entries()->bool:
	# Read encrypted entries
	var entries := {}
	if FileAccess.file_exists(file_path_input.text):
		entries = get_entries(file_path_input.text, password_input.text)
		if entries == null:
			return false
	# Create new encrypted entries store
	else:
		_save_entries()
	
	# Show entries
	_add_entries(entries)
	return true

func _save_entries(export_path:String = "")->void:
	# Get entries from input boxes
	var entries := {}
	for child in secret_template.get_parent().get_children():
		if child == secret_template:
			continue
		var key_input:TextEdit = child.get_node(^"KeyInput")
		var value_input:TextEdit = child.get_node(^"ValueInput")
		entries[key_input.text] = value_input.text
	
	# Save as encrypted
	if export_path == "":
		var file := FileAccess.open_encrypted_with_pass(file_path_input.text, FileAccess.WRITE, password_input.text)
		file.store_string(JSON.stringify(entries))
	# Save as JSON
	else:
		var file := FileAccess.open(export_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(entries, "\t"))

func _submit_password()->void:
	# Try load entries with password
	if _load_entries() == false:
		return
	# Go to secrets list
	password_panel.hide()

func _add_entries(entries:Dictionary)->void:
	# Add each entry
	for entry in entries:
		_add_entry(str(entry), str(entries[entry]))

func _remove_entries()->void:
	# Remove each entry
	for secret in secret_template.get_parent().get_children():
		if secret == secret_template:
			continue
		secret.queue_free()

func _export_entries()->void:
	# Select export destination
	export_file_dialog.current_file = "Secrets"
	export_file_dialog.popup()

func _lock_entries()->void:
	# Save and lock entries
	_save_entries()
	_remove_entries()
	# Return to password input panel
	password_input.clear()
	password_panel.show()

func _add_entry(key:String, value:String)->void:
	# Create entry control
	var secret:Control = secret_template.duplicate()
	# Get entry components
	var key_input:TextEdit = secret.get_node(^"KeyInput")
	var value_input:TextEdit = secret.get_node(^"ValueInput")
	var move_up_button:BaseButton = secret.get_node(^"MoveUp")
	var remove_button:BaseButton = secret.get_node(^"Remove")
	# Fill input boxes
	key_input.text = key
	value_input.text = value
	# Connect buttons
	move_up_button.pressed.connect(func():
		if secret.get_index() <= 0:
			return
		secret.get_parent().move_child(secret, secret.get_index() - 1))
	remove_button.pressed.connect(func():
		secret.queue_free())
	# Add entry
	secret.show()
	secret_template.get_parent().add_child(secret)
