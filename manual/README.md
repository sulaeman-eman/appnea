# Dokumentasi Appnea

Folder ini berisi dua dokumen. Keduanya tersedia dalam bentuk Markdown (untuk
dibaca di editor atau GitHub) dan HTML (untuk dicetak jadi PDF).

| Dokumen | Isinya | Untuk siapa |
|---|---|---|
| [MANUAL.md](MANUAL.md) &middot; [MANUAL.html](MANUAL.html) | Cara memakai aplikasi: browsing, booking, dan panel admin | Pengunjung, murid, dan tim Appnea |
| [WHAT_NEEDED.md](WHAT_NEEDED.md) &middot; [WHAT_NEEDED.html](WHAT_NEEDED.html) | Persiapan environment: apa yang harus diinstall, kenapa, dan masalah yang mungkin muncul | Developer |

## Membuat PDF

1. Buka file `.html` di browser
2. Tekan `Ctrl+P` (atau `Cmd+P` di Mac)
3. Pilih **Save as PDF**

Gaya cetaknya sudah diatur: margin halaman rapi, judul tidak terpotong di
pergantian halaman, dan tabel atau gambar tidak terbelah dua.

## Struktur folder

```
manual/
├── README.md            file ini
├── MANUAL.md            sumber manual penggunaan
├── MANUAL.html          hasil build, siap dicetak
├── WHAT_NEEDED.md       sumber panduan environment
├── WHAT_NEEDED.html     hasil build, siap dicetak
├── images/              25 tangkapan layar aplikasi
├── build.mjs            pengubah Markdown jadi HTML
└── package.json
```

## Mengubah isi dokumen

**Edit file `.md`, jangan file `.html`.** File HTML dibuat otomatis dari
Markdown dan akan tertimpa setiap kali di-build.

```bash
cd manual
npm install     # sekali saja
npm run build
```

Perintah build membaca setiap file `.md` di folder ini dan menghasilkan `.html`
dengan nama yang sama.

## Tentang tangkapan layarnya

Semua gambar di `images/` diambil dari aplikasi yang benar-benar berjalan, bukan
mockup. Kalau tampilan aplikasi berubah, gambarnya perlu diambil ulang.

Gambar sampul kursus yang terlihat di tangkapan layar itu gradien yang dibuat
otomatis oleh data contoh, bukan foto asli. Ganti dengan foto sungguhan lewat
panel admin sebelum website dipakai betulan.
