extends Node

# Sinyal untuk memberitahu UI kalau ada update
signal todo_list_updated

# To-Do List awal Luna
var active_todos: Array[String] = [
	"Mendapatkan Teman"
]

# Fungsi untuk menambah To-Do List baru
func add_todo(new_task: String):
	if not new_task in active_todos:
		active_todos.append(new_task)
		todo_list_updated.emit() # Beritahu UI untuk update layarnya

# Fungsi opsional kalau Luna sudah menyelesaikan task
func complete_todo(task: String):
	if task in active_todos:
		active_todos.erase(task)
		todo_list_updated.emit()
