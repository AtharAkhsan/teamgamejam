extends Node

# Sinyal untuk memberitahu UI kalau ada update
signal todo_list_updated
# Khusus saat to-do baru ditambahkan / diselesaikan (dipakai untuk notifikasi)
signal todo_added(task: String)
signal todo_completed(task: String)

# To-Do List awal Luna
var active_todos: Array[String] = [
	"Mendapatkan Teman"
]
var completed_todos: Array[String] = []

# Fungsi untuk menambah To-Do List baru (diabaikan kalau sudah aktif atau sudah selesai)
func add_todo(new_task: String):
	if new_task in active_todos or new_task in completed_todos:
		return
	active_todos.append(new_task)
	todo_added.emit(new_task)
	todo_list_updated.emit() # Beritahu UI untuk update layarnya

# Dipanggil saat Luna menyelesaikan task
func complete_todo(task: String):
	if task in active_todos:
		active_todos.erase(task)
		completed_todos.append(task)
		todo_completed.emit(task)
		todo_list_updated.emit()

func is_active(task: String) -> bool:
	return task in active_todos

func is_completed(task: String) -> bool:
	return task in completed_todos
