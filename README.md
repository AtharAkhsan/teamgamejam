# Luna Kembalilah ke Indonesia

Game 2D pixel-art buatan tim game jam. Lulu, makhluk kecil dari bulan, penasaran dengan cahaya biru dari Bumi, meluncur ke Bumi sebagai meteor, jatuh di sebuah SMA di Indonesia, dikejar warga, lalu harus berbaur sebagai murid SMA. Export preset-nya bernama "WNB to WNI".

- **Engine:** Godot 4.6 (Forward+)
- **Plugin:** [Dialogic 2](https://github.com/dialogic-godot/dialogic) (2.0-Alpha-19), sudah termasuk di `addons/`, untuk cutscene dan dialog
- **Resolusi:** 1920x1080, stretch `canvas_items`, filter tekstur nearest (pixel art)

## Cara membuka

```bash
git config --global core.longpaths true   # Windows: path di dalam Dialogic panjang
git clone https://github.com/AtharAkhsan/teamgamejam.git
```

Buka `project.godot` di Godot 4.6. Waktu pertama dibuka, Godot akan mengimpor aset dan mungkin menampilkan beberapa error; tutup lalu buka lagi, setelah itu bersih.

## Alur game

```
Main Menu ──Start──► Cutscene "Intro" (SCENE 01–07: Bulan → Lulu meluncur ke Bumi)
                           ▼
                     Minigame 1: jatuh dari Bulan ke Bumi sebagai meteor,
                           │      hindari asteroid & satelit (3 nyawa)
                           ▼
                     Cutscene "IntroBumi" (SCENE 08–10: menabrak sekolah,
                           │                "ADA ALIENN!!! KEJAR DIAA!!!")
                           ▼
                     Minigame 2: lari dari kejaran warga (3 lajur, 3 nyawa)
                           │  menang → klik KTP "What's This?"
                           ▼
                     Cutscene "MendaratSekolah" (SCENE 11–13, "AKU JADI WNIIII")
                           ▼
                     SchoolOutside ◄──pintu──► SchoolInside (+ Ruang Band)
                       ├ tiba dekat pagar (ArrivalSpawn) + monolog "TibaDiSekolah"
                       └ Quest: ngobrol Nabila (gagal, "bakar apa?") → baca kamus di rak buku
                         kelas (SchoolInside) → ngobrol lagi → "Mendapatkan Teman" selesai
```

Main Menu juga punya halaman **Credits**. Kalau kalah di minigame, ada tombol untuk mengulang minigame itu.

## Kontrol

| Aksi | Tombol |
|---|---|
| Jalan | WASD / panah |
| Interaksi dengan NPC / objek (muncul prompt "E") | E |
| Buka/tutup To-Do List | Q |
| Lanjut dialog | Enter / Spasi / X / klik kiri |
| Minigame 1: geser kiri/kanan | A/D atau panah kiri/kanan |
| Minigame 2: pindah lajur | W/S atau panah atas/bawah |

## Struktur folder

Semua file game ada di `teamgamejam/`, dan path-nya memakai `res://teamgamejam/...`.

```
project.godot       Setting project: input map, autoload, setting Dialogic
addons/dialogic/    Plugin Dialogic 2
teamgamejam/
  00_Globals/       Autoload: MusicManager (musik loop), SceneTransition (fade antar scene)
  Assets/           Gambar, audio, font, tilemap. "MINI GAME 2/" untuk aset minigame 2
  Dialogic/         Karakter (.dch), style, dan timeline (.dtl) cutscene/dialog
  Scenes/
    Characters/     player, npc_nabila, npc_botak
    Controls/       main_menu, credits, to_do_list_ui, interact_prompt
    Levels/         SchoolOutside, SchoolInside, RuangBand
    MINIGAME 1/     game (dunia 480x270 di SubViewport, di-scale 4x)
    MINIGAME 2/     game, luna, obstacle
    pintu.tscn      Pintu animasi (buka saat player mendekat)
  Scripts/          Semua script gameplay (+ "MINIGAME 1/", "MINIGAME 2/")
```

Autoload yang terdaftar di `project.godot`: `Dialogic`, `MusicManager`, `SceneTransition`, `QuestManager` (daftar to-do), dan `GameManager` (state antar scene, misalnya posisi spawn).

### Menyetel Minigame 1

Tingkat kesulitan bisa diatur dari Inspector di node root `Minigame_1_game.tscn`: `total_distance` (panjang permainan, ±60 detik), `start_speed` / `end_speed`, `start_spawn_interval` / `end_spawn_interval`, dan `max_health`. Grafik meteor Lulu, asteroid, satelit, dan latar masih digambar lewat kode (`_draw()` di `Scripts/MINIGAME 1/`), jadi bisa diganti sprite dari artist.

### Menambah NPC / objek yang bisa diinteraksi

**NPC:** ikuti `npc_nabila.tscn`: Area2D `chatDetection` (signal `body_entered`/`body_exited`), instance `Scenes/Controls/interact_prompt.tscn` di atas kepala (prompt tombol "E"), dan script yang mengatur `prompt.visible` lalu memanggil `Dialogic.start()` saat tombol `interact` ditekan.

**Objek** (rak buku, papan, dll.): pakai Area2D dengan script `Scripts/interactable.gd` + child CollisionShape2D dan `interact_prompt.tscn`, lalu isi di Inspector: `timeline` (yang diputar), `required_todo` (hanya aktif selama to-do ini ada), `completes_todo` (diselesaikan setelah timeline selesai). Contohnya `RakBuku` di `SchoolInside.tscn`.

**Quest:** `QuestManager.add_todo("...")` dan `QuestManager.complete_todo("...")`; notifikasi "To-Do baru" / "Selesai" muncul otomatis. Quest yang sudah selesai tidak bisa ditambahkan lagi, cek dengan `is_active()` / `is_completed()`.

## Yang belum selesai / TODO

- **Minigame 1:** grafiknya masih placeholder dari kode, belum ada sprite Lulu-meteor, asteroid, dan satelit dari artist.
- **NPC Botak (Hartono)** di SchoolInside belum bisa diajak bicara. Area2D `chatDetection` dan timeline `greetHartono` belum dibuat (lihat komentar di `Scripts/npc_botak.gd`).
- **Quest berikutnya:** setelah berteman dengan Nabila, to-do list kosong dan belum ada tujuan selanjutnya.
- Portrait Putri & Rania, serta sprite NPC SMA lain, sudah ada di `Assets/` tapi belum dipakai.
