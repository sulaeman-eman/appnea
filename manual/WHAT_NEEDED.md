# What Needed — Persiapan Environment Appnea

Dokumen ini menjelaskan **semua yang dibutuhkan supaya Appnea bisa jalan di
mesin baru**, plus alasan kenapa tiap bagian ada. Ditulis berdasarkan langkah
yang benar-benar dijalankan waktu membangun aplikasi ini, termasuk beberapa
masalah yang sempat menghadang dan cara menyelesaikannya.

Kalau kamu cuma mau tahu **cara memakai** aplikasinya, baca `MANUAL.md`.

---

## 1. Gambaran besar dulu

Sebelum menginstall apa pun, penting paham aplikasi ini terdiri dari apa. Kalau
tidak, daftar instalasi di bawah cuma terasa seperti mantra yang harus dihafal.

```
Browser
   |
   v
Express (Node)  <-- server-render React, pegang cookie sesi, teruskan /api/*
   |
   v
Rails 8 (API)   <-- semua logika bisnis, autentikasi, panel admin
   |
   v
PostgreSQL 16   <-- data
```

Tiga proses, tiga tanggung jawab:

| Bagian | Port | Tugas |
|---|---|---|
| PostgreSQL | 5432 | Menyimpan data |
| Rails | 3000 | JSON API, autentikasi, panel admin Avo |
| Express | 5173 | Render React di server, jadi perantara ke Rails |

**Kenapa ada dua server aplikasi?** Express **tidak menyimpan logika bisnis sama
sekali**. Tugasnya cuma dua: merender React jadi HTML di server (supaya Google
bisa membaca isi halaman), dan meneruskan panggilan API ke Rails sambil
menukar cookie sesi menjadi header `Authorization`. Artinya token login tidak
pernah sampai ke JavaScript di browser.

Kalau Express juga menyimpan logika bisnis, akan ada dua sumber kebenaran dan
keduanya pasti berbeda dalam waktu sebulan. Rails yang memutuskan segalanya.

---

## 2. Yang harus diinstall

### 2.1 Ringkasan

| Kebutuhan | Versi | Untuk apa |
|---|---|---|
| mise | terbaru | Mengunci versi Ruby per project |
| Ruby | 3.3.12 | Bahasa yang dipakai Rails |
| Rails | 8.1.x | Framework backend |
| Node.js | 24.x | Menjalankan Express dan build React |
| PostgreSQL | 16 | Database |
| libvips | 8.15+ | Memproses ukuran gambar |
| Git | apa saja | Version control |

### 2.2 mise dan Ruby

**Masalahnya:** mesin ini punya Ruby 2.6 bawaan sistem. Rails 8 butuh minimal
Ruby 3.2. Mengganti Ruby sistem itu ide buruk — banyak perkakas OS bergantung
padanya.

**Solusinya:** version manager. Kita pakai [mise](https://mise.jdx.dev), yang
membaca file `mise.toml` di root project dan otomatis memakai Ruby yang benar
begitu kamu masuk ke folder itu.

```bash
# Install mise (kalau belum ada)
curl https://mise.run | sh

# Install Ruby dan kunci versinya untuk project ini
cd /path/ke/Appnea
mise use ruby@3.3.12
```

File `mise.toml` di root project isinya cuma ini:

```toml
[tools]
ruby = "3.3.12"
```

Karena versinya tertulis di dalam repo, siapa pun yang clone project ini dapat
Ruby yang sama persis. Tidak ada lagi "di laptop saya jalan kok".

> **Catatan dari proses pembangunan:** awalnya kami install Ruby 3.4, tapi
> ternyata 3.3.12 sudah ada di mesin dan Rails 8 mendukungnya. Jadi kami pakai
> yang sudah ada — proses kompilasi Ruby memakan waktu 10+ menit, tidak perlu
> diulang tanpa alasan.

**Kenapa harus `mise exec`?** Semua perintah Ruby di project ini diawali
`mise exec --`, misalnya `mise exec -- bin/rails server`. Itu memastikan
perintahnya jalan pakai Ruby 3.3.12, bukan Ruby sistem. Kalau shell kamu sudah
di-hook ke mise (`mise activate`), awalan itu tidak perlu.

### 2.3 Rails

```bash
mise exec -- gem install rails -v '~> 8.0'
```

Rails di-install sebagai gem, bukan lewat apt. Versi apt hampir selalu
ketinggalan dan tidak menghormati version manager.

Aplikasi ini dibuat dengan mode **API-only**:

```bash
rails new backend --api -d postgresql -T --skip-git --skip-kamal --skip-docker
```

Arti tiap flag:

- `--api` — buang middleware dan generator yang cuma berguna untuk aplikasi
  full-stack. Frontend kita React, jadi Rails tidak perlu merender HTML.
- `-d postgresql` — pakai PostgreSQL, bukan SQLite default.
- `-T` — jangan pasang Minitest; kita pakai RSpec.
- `--skip-docker`, `--skip-kamal` — Docker tidak terpasang di mesin ini.

> **Jebakan yang kami temui:** `--skip-git` berarti Rails **tidak membuat
> `.gitignore`**. Kami menulisnya manual, dan baris untuk `config/master.key`
> hampir terlewat. File itu adalah kunci utama aplikasi. Kalau ikut ter-commit,
> ia masuk riwayat Git selamanya. Selalu cek:
> ```bash
> git check-ignore -v backend/config/master.key
> ```
> Kalau perintah itu tidak menampilkan apa-apa, kuncimu belum aman.

### 2.4 Node.js

```bash
# Lewat mise juga, supaya konsisten
mise use node@24
```

Node dipakai untuk dua hal: menjalankan server Express, dan menjalankan Vite
yang mem-bundle React.

### 2.5 PostgreSQL

```bash
sudo apt-get install -y postgresql-16
sudo systemctl start postgresql
```

Aplikasi terhubung lewat **domain socket** dengan **peer authentication**.
Artinya: PostgreSQL percaya pada user sistem operasi kamu, tanpa password.
Praktis untuk development, dan `config/database.yml` jadi bersih tanpa
kredensial.

Supaya itu bekerja, harus ada role PostgreSQL dengan nama sama seperti user
Linux kamu, dan role itu harus boleh membuat database:

```bash
sudo -u postgres createuser --createdb $(whoami)
```

Cek berhasil atau tidak:

```bash
psql -d postgres -c '\du'
```

Nama user kamu harus muncul dengan atribut `Create DB`.

### 2.6 libvips

```bash
sudo apt-get install -y libvips42 libvips-tools
```

Ini yang mengubah gambar yang diupload jadi berbagai ukuran. Active Storage
punya dua pilihan pemroses gambar: libvips atau ImageMagick. Rails 8 memilih
libvips secara default karena lebih cepat dan lebih hemat memori.

**Tanpa ini, upload gambar tetap tersimpan tapi variannya gagal dibuat**, jadi
kartu di halaman katalog akan kosong. Gejalanya membingungkan karena upload-nya
sendiri sukses.

Cek terpasang:

```bash
vips --version          # harus keluar: vips-8.15.1 atau lebih baru
```

---

## 3. Menjalankan aplikasi

### 3.1 Sekali saja, saat pertama setup

```bash
git clone <repo> Appnea
cd Appnea

# --- Backend ---
cd backend
mise exec -- bundle install
mise exec -- bin/rails db:create db:migrate db:seed
cp .env.example .env

# --- Frontend ---
cd ../web
npm install
```

`db:seed` mengisi database dengan 4 kursus, 2 instruktur, 12 jadwal, 2 trip,
dan beberapa artikel — lengkap dengan terjemahan Indonesia dan gambar
placeholder. Seed ini **idempotent**: aman dijalankan berkali-kali, tidak akan
membuat duplikat.

### 3.2 Setiap hari

```bash
bin/dev
```

Satu perintah dari root project, menjalankan Rails dan Express sekaligus.
`Ctrl-C` mematikan keduanya.

Isinya sederhana:

```bash
( cd "$root/backend" && mise exec -- bin/rails server -p 3000 ) &
( cd "$root/web" && npm run dev ) &
wait
```

Setelah jalan:

| Alamat | Isi |
|---|---|
| http://localhost:5173 | Website publik |
| http://localhost:3000/admin/login | Panel admin |
| http://localhost:3000/api/health | Cek API hidup atau tidak |

Login bawaan dari seed, keduanya password `changeme123`:

- `admin@appnea.test` — bisa masuk panel admin
- `student@appnea.test` — user biasa, bisa booking

### 3.3 Kalau ada yang tidak jalan

| Gejala | Kemungkinan penyebab | Cara cek |
|---|---|---|
| `bin/rails` tidak ditemukan | Ruby sistem yang kepakai | `mise exec -- ruby -v` harus 3.3.12 |
| `PG::ConnectionBad` | PostgreSQL mati | `pg_isready` |
| `FATAL: role does not exist` | Role belum dibuat | `sudo -u postgres createuser --createdb $(whoami)` |
| Halaman tampil tapi kosong isinya | Rails mati, Express hidup | `curl localhost:3000/api/health` |
| Gambar tidak muncul | libvips belum ada | `vips --version` |
| Admin panel error 500 | Lihat bagian 5.1 di bawah | `tail backend/log/development.log` |

---

## 4. Anatomi project

```
Appnea/
├── mise.toml              # kunci versi Ruby
├── bin/dev                # jalankan kedua server
├── PLAN.md                # arsitektur dan riwayat keputusan
├── README.md              # rujukan cepat
├── manual/                # dokumen ini
│
├── backend/               # Rails 8 API-only
│   ├── app/
│   │   ├── models/        # Course, Schedule, Booking, User, ...
│   │   │   └── concerns/  # Translatable, Searchable, HasCoverImage
│   │   ├── controllers/
│   │   │   └── api/       # endpoint JSON
│   │   ├── blueprints/    # ubah model jadi JSON (Blueprinter)
│   │   ├── services/      # Bookings::Create, Bookings::Cancel
│   │   ├── avo/           # definisi tampilan panel admin
│   │   └── mailers/       # email booking
│   ├── config/
│   │   ├── database.yml
│   │   ├── routes.rb
│   │   └── initializers/avo.rb
│   ├── db/
│   │   ├── migrate/       # riwayat perubahan struktur database
│   │   ├── schema.rb      # bentuk database saat ini (jangan diedit manual)
│   │   └── seeds.rb       # data contoh
│   └── spec/              # 154 test RSpec
│
└── web/                   # Express + React + TypeScript
    └── src/
        ├── client/        # halaman React, routing, state
        ├── server/        # Express, SSR, proxy ke Rails
        ├── shared/        # tipe data dan pemanggil API
        └── test/          # setup vitest
```

### 4.1 Konsep Rails yang dipakai di sini

Kalau kamu baru di Rails, ini istilah yang paling sering muncul di project ini.

**Model** — satu class Ruby mewakili satu tabel database. `Course` mewakili
tabel `courses`. Validasi, relasi antar tabel, dan aturan bisnis kecil tinggal
di sini.

**Migration** — satu file yang menjelaskan satu perubahan struktur database.
Dijalankan berurutan, dan tercatat di tabel `schema_migrations`. Jangan pernah
mengubah migration yang sudah pernah jalan di mesin orang lain; buat migration
baru.

```bash
mise exec -- bin/rails generate migration AddPhoneToUsers phone:string
mise exec -- bin/rails db:migrate
```

**Controller** — menerima request HTTP, memanggil model atau service, lalu
mengembalikan JSON. Di project ini semuanya ada di `app/controllers/api/`.

**Service object** — kelas biasa untuk logika yang terlalu besar untuk model.
`Bookings::Create` contohnya: ia mengambil kunci baris database, memeriksa sisa
kursi, membuat booking, dan mengirim email. Kalau logika seperti itu ditaruh di
controller, ia tidak bisa dipakai ulang dari panel admin.

**Concern** — modul yang bisa di-`include` ke beberapa model. `Translatable`
dipakai Course, Trip, dan Article, jadi ketiganya dapat kemampuan terjemahan
tanpa menyalin kode.

**Blueprint (serializer)** — menentukan model diubah jadi JSON seperti apa.
Memisahkan bentuk database dari bentuk API, jadi mengganti nama kolom tidak
otomatis merusak frontend.

### 4.2 Gem penting dan alasannya

| Gem | Untuk apa | Kenapa yang ini |
|---|---|---|
| `pg` | Driver PostgreSQL | — |
| `bcrypt` | Hash password | Standar `has_secure_password` |
| `jwt` | Token API | Stateless, cocok untuk API |
| `blueprinter` | Serializer JSON | ActiveModelSerializers sudah tidak dirawat |
| `avo` | Panel admin | Admin di sini murni CRUD; membuat sendiri tidak menambah nilai |
| `ransack` | Query pencarian admin | Dibutuhkan Avo, tapi harus ditambah manual |
| `image_processing` | Varian gambar | Jembatan ke libvips |
| `rspec-rails` | Testing | — |
| `dotenv-rails` | Baca `.env` | Rails tidak membacanya sendiri |
| `json` (dikunci ~> 2.9) | Parsing JSON | Lihat bagian 5.1 |

---

## 5. Masalah nyata yang kami temui

Bagian ini bukan teori. Semua ini benar-benar terjadi saat membangun Appnea, dan
kemungkinan besar akan kamu temui lagi kalau setup dari nol.

### 5.1 Gem `json` versi 3 merusak sesi Rails

**Gejala:** panel admin balas 500 di browser, tapi `curl` bilang 200.

**Penyebab:** gem `json` 3.x menghapus argumen kedua dari `JSON.parse`, padahal
ActiveSupport masih mengirimnya saat mendekripsi cookie sesi:

```
ArgumentError (wrong number of arguments (given 2, expected 1))
  json (3.0.2) lib/json/common.rb:296:in `parse'
  activesupport (8.1.3.1) lib/active_support/json/decoding.rb:25:in `decode'
```

**Kenapa curl lolos tapi browser gagal:** curl tidak mengirim cookie. Browser
mengirim, jadi jalur dekripsi sesi kena, dan crash.

**Solusi:** kunci versinya di `Gemfile`.

```ruby
gem "json", "~> 2.9"
```

**Pelajarannya:** menguji dengan curl saja tidak cukup untuk apa pun yang
melibatkan sesi. Kalau fitur menyangkut cookie, ujilah dengan cookie jar
(`curl -c jar.txt -b jar.txt`) atau browser sungguhan.

### 5.2 Avo butuh `ransack`, tapi tidak memintanya

**Gejala:** pencarian di panel admin balas 500 dengan pesan yang
membingungkan — `ArgumentError: missing keyword: :label`.

**Penyebab:** Avo 4 memperlakukan `ransack` sebagai opsional, tapi blok search
di resource memerlukannya. Lebih parah, penanganan error Avo sendiri punya bug
yang menyembunyikan error aslinya (`NoMethodError: undefined method 'ransack'`).

**Solusi:** tambahkan `gem "ransack"` ke Gemfile.

**Pelajarannya:** kalau pesan error terasa tidak nyambung dengan yang kamu
kerjakan, curigai penanganan error-nya sendiri. Panggil kode yang bermasalah
langsung dari `rails runner` untuk melihat error yang sebenarnya.

### 5.3 Avo di dalam aplikasi API-only

Mode `--api` membuang middleware cookie, session, dan flash. Avo butuh
ketiganya. Kami mengembalikannya secara eksplisit di `config/application.rb`:

```ruby
config.middleware.use ActionDispatch::Cookies
config.middleware.use ActionDispatch::Session::CookieStore, key: "_appnea_admin"
config.middleware.use ActionDispatch::Flash
```

API JSON-nya sendiri tetap stateless dan pakai JWT. Sesi itu khusus admin.

### 5.4 Active Storage: mode redirect membocorkan origin Rails

Secara default, Active Storage membalas permintaan gambar dengan redirect ke
storage service. Di arsitektur ini, redirect tersebut mengirim browser langsung
ke `localhost:3000` — padahal seluruh desainnya justru menyembunyikan Rails di
balik Express.

Solusinya, ubah ke mode proxy:

```ruby
config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

dan minta Express meneruskan `/rails/*` seperti ia meneruskan `/api/*`.

### 5.5 Halaman kosong sampai di-refresh

**Gejala:** klik menu, halaman kosong. Tekan F5, isinya muncul.

**Penyebab:** saat berpindah halaman, React Router merender halaman baru
sementara state masih memegang data halaman lama. Tiap halaman mengubah data itu
ke bentuknya sendiri, jadi halaman Instructors membaca
`payload.instructors.length` dari data courses — `undefined.length` — lalu
melempar error. Tanpa error boundary, seluruh aplikasi ikut mati.

**Kenapa refresh menyembuhkan:** refresh melewati jalur SSR, yang memang
memberi data yang benar sejak awal.

**Solusi:** provider sekarang memutuskan **saat render**, bukan di dalam
`useEffect`, apakah data yang dipegang milik halaman yang sedang tampil. Router
memasang halaman baru di commit yang sama dengan navigasi, jadi membersihkan
data di effect itu sudah terlambat.

**Pelajarannya:** memverifikasi dengan `curl` tidak pernah bisa menemukan bug
ini, karena curl selalu mengambil tiap URL dari nol — itu jalur SSR. Perpindahan
antar halaman hanya terjadi di browser. Sekarang ada test vitest yang menirunya.

### 5.6 Overbooking dan kunci baris database

Ini bukan bug yang terjadi, tapi bug yang **sengaja dicegah**, dan cara
membuktikannya menarik.

`Bookings::Create` mengambil kunci baris (`schedule.lock!`) sebelum menghitung
sisa kursi. Untuk membuktikan kunci itu benar-benar diperlukan, kuncinya kami
lepas sementara lalu jalankan test konkurensi: **8 booking berhasil masuk ke
jadwal berkapasitas 4**.

Yang menarik: constraint database `seats_taken <= capacity` **tidak menangkap
ini**. Setiap thread membaca `seats_taken` bernilai 0 lalu menulis 1, jadi
angkanya tidak pernah melebihi kapasitas. Ini disebut *lost update*. Kuncinya
yang menyelamatkan, constraint cuma jaring pengaman kedua.

**Pelajarannya:** test konkurensi yang tidak pernah bisa gagal itu tidak ada
gunanya. Lepas dulu pengamannya, pastikan test-nya merah, baru pasang lagi.

---

## 6. Menjalankan test

```bash
# Backend: 154 contoh
cd backend && mise exec -- bundle exec rspec

# Backend: pemeriksa gaya penulisan kode
cd backend && mise exec -- bundle exec rubocop

# Frontend: 6 test, fokus ke navigasi antar halaman
cd web && npm test

# Frontend: pemeriksa tipe
cd web && npx tsc --noEmit

# Frontend: build produksi
cd web && npm run build
```

Jalankan semuanya sebelum commit. Kalau ada satu saja yang merah, jangan commit.

---

## 7. Perintah yang paling sering dipakai

```bash
# Console Rails: coba-coba query dan model secara langsung
mise exec -- bin/rails console

# Lihat semua route yang terdaftar
mise exec -- bin/rails routes

# Buat migration baru
mise exec -- bin/rails generate migration NamaPerubahannya

# Jalankan migration
mise exec -- bin/rails db:migrate

# Batalkan migration terakhir
mise exec -- bin/rails db:rollback

# Reset database dari nol lalu isi ulang seed
mise exec -- bin/rails db:drop db:create db:migrate db:seed

# Jalankan satu baris kode di dalam aplikasi
mise exec -- bin/rails runner 'puts Course.published.count'

# Lihat log
tail -f backend/log/development.log
```

---

## 8. Kalau nanti mau deploy

Belum dikerjakan, tapi ini yang perlu disiapkan:

1. **`SECRET_KEY_BASE`** — kunci penandatangan JWT diturunkan dari sini.
   Berbeda per environment, tidak boleh masuk repo.
2. **`config/master.key`** — kirim lewat jalur aman, jangan lewat Git.
3. **`DATABASE_URL`** — production tidak memakai peer authentication.
4. **`CORS_ORIGINS`** — isi dengan domain asli.
5. **Cookie `secure`** — sudah otomatis aktif saat `NODE_ENV=production`, jadi
   HTTPS itu wajib, bukan pilihan.
6. **Storage** — `config/storage.yml` sekarang menulis ke disk lokal. Di
   production sebaiknya S3 atau sejenisnya.
7. **Email** — development menulis ke `tmp/mails`. Production perlu SMTP asli.
8. **Solid Queue** — email dikirim lewat background job, jadi `bin/jobs` harus
   ikut berjalan.

---

## 9. Bacaan lanjutan

- [Rails Guides](https://guides.rubyonrails.org/) — dokumentasi resmi, mulai
  dari "Getting Started" dan "Active Record Basics".
- [Dokumentasi Avo](https://docs.avohq.io) — panel admin.
- [Dokumentasi Vite](https://vite.dev/guide/ssr) — bagian server-side rendering.
- `PLAN.md` di root project — arsitektur dan alasan tiap keputusan diambil.
