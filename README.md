# Secret Store
 
An encrypted key-value store for Godot.

This may be useful for dedicated-server scenarios.

## Screenshots

<img src="https://github.com/Joy-less/SecretStore/blob/main/Assets/Screenshot%201.png?raw=true" width=1000 />
<img src="https://github.com/Joy-less/SecretStore/blob/main/Assets/Screenshot%202.png?raw=true" width=1000 />

## Usage

- Enable the plugin and open the secrets dock.
- Enter a password to encrypt your secrets and press submit.
- Press "+" to add a new secret.
- Press "🔒" to encrypt, save and lock your secrets.
- Press "💾" to encrypt and save your secrets.
- Press "📂" to export your secrets to a JSON file.
- Press "-" to remove a secret.
- Press "^" to rearrange a secret.

Retrieve your secrets at runtime with the code:
```gd
var secrets_script:GDScript = load("res://addons/SecretStore/Scripts/secrets.gd")
var secrets = secrets_script.get_entries("Secrets.dat", "Password")
```
Alternatively:
```gd
static func get_entries(file_path:String, password:String):
	var file := FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, password)
	if file == null:
		return null
	return JSON.parse_string(file.get_as_text())
```

> [!IMPORTANT]
> Ensure your export presets include the secrets file.

## Disclaimer

The author of this repository cannot be held responsible for breeched passwords or secrets.