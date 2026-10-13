# Luna Kembalilah ke Indonesia

Game 2D pixel-art buatan tim game jam. Lulu, makhluk kecil dari bulan, penasaran dengan cahaya biru dari Bumi, jatuh ke Indonesia, dikejar warga, lalu harus berbaur sebagai murid SMA. Export preset-nya bernama "WNB to WNI".

- **Engine:** Godot 4.6 (Forward+)
- **Plugin:** [Dialogic 2](https://github.com/dialogic-godot/dialogic) (2.0-Alpha-19), untuk cutscene dan dialog
- **Resolusi:** 1920x1080, stretch `canvas_items`, filter tekstur nearest (pixel art)

## Alur game

```
Main Menu ──Start──► Cutscene "Intro" (Dialogic, SCENE 01–10)
						   │  "ADA ALIENN!!! KEJAR DIAA!!!"
						   ▼
					 Minigame 2: lari dari kejaran warga (3 lajur, 3 nyawa)
						   │  menang → klik KTP "What's This?"
						   ▼
					 Cutscene "MendaratSekolah" (SCENE 11–13, "AKU JADI WNIIII")
						   ▼
					 SchoolOutside ◄──pintu──► SchoolInside (+ Ruang Band)
					   └ NPC Nabila (dialog "GreetNabila")
```

Main Menu juga punya halaman **Credits**.

## Kontrol

| Aksi | Tombol |
|---|---|
| Jalan | WASD / panah |
| Interaksi dengan NPC | E |
| Buka/tutup To-Do List | Q |
| Lanjut dialog | Enter / Spasi / X / klik kiri |
| Minigame 2: pindah lajur | W/S atau panah atas/bawah |

## Struktur folder

Repo ini adalah folder `teamgamejam/` di dalam project Godot. `project.godot` dan `addons/dialogic` ada di folder induknya, dan semua path memakai `res://teamgamejam/...`.

```
00_Globals/     Autoload: MusicManager (musik loop), SceneTransition (fade antar scene)
Assets/         Gambar, audio, font, tilemap. "MINI GAME 2/" untuk aset minigame
Dialogic/       Karakter (.dch), style, dan timeline (.dtl) cutscene/dialog
Scenes/
  Characters/   player, npc_nabila, npc_botak
  Controls/     main_menu, credits, to_do_list_ui
  Levels/       SchoolOutside, SchoolInside, RuangBand
  MINIGAME 2/   game, luna, obstacle
  pintu.tscn    Pintu animasi (buka saat player mendekat)
Scripts/        Semua script gameplay (+ "MINIGAME 2/")
```

Autoload yang terdaftar di `project.godot`: `Dialogic`, `MusicManager`, `SceneTransition`, `QuestManager` (daftar to-do), dan `GameManager` (state antar scene, misalnya posisi spawn).

## Yang belum selesai / TODO

- **NPC Botak (Hartono)** di SchoolInside belum bisa diajak bicara. Area2D `chatDetection` dan timeline `greetHartono` belum dibuat (lihat komentar di `Scripts/npc_botak.gd`).
- **Minigame 1** belum ada, baru lagunya (`Assets/Audio/Songs/Minigame 1.mp3`).
- **Quest:** baru ada satu to-do awal ("Mendapatkan Teman") dan belum ada yang menyelesaikannya.
- Portrait Putri & Rania, serta sprite NPC SMA lain, sudah ada di `Assets/` tapi belum dipakai.
- Setelah dialog dengan Nabila belum ada konsekuensi gameplay.
