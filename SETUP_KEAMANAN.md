# Panduan Mengamankan Dashboard Reklamasi

Saat ini data Anda **bisa diubah/dihapus siapa saja** yang membuka web, karena
penulisan ke database masih memakai anon key tanpa pembatasan. Ikuti 3 langkah
berikut untuk menutup celah itu. Selama belum diikuti, aplikasi tetap berjalan
seperti biasa (tidak ada yang rusak) — tetapi belum aman.

Perkiraan waktu: ~10 menit. Tidak perlu menyentuh kode selain 1 baris di langkah 3.

---

## Langkah 1 — Buat user admin di Supabase Auth

1. Buka dashboard Supabase proyek Anda.
2. Menu kiri: **Authentication → Users → Add user → Create new user**.
3. Isi **Email** (mis. `admin@esdm-aceh.go.id`) dan **Password** yang kuat.
   Centang "Auto Confirm User" bila ada.
4. Klik **Create**.

> Email + password inilah yang nanti dipakai untuk login sebagai Admin.
> (Di layar login, kolom "Username" diisi dengan **email** ini.)

---

## Langkah 2 — Jalankan aturan keamanan (RLS)

1. Menu kiri: **SQL Editor → New query**.
2. Buka file **`supabase_security.sql`** (ada di folder yang sama dengan `index.html`),
   salin seluruh isinya ke editor.
3. Klik **Run**. Pastikan muncul "Success".

Ini mengaktifkan aturan: **semua orang boleh membaca**, tetapi **hanya yang login
yang boleh menulis/menghapus**.

---

## Langkah 3 — Aktifkan login aman di aplikasi

1. Buka **`index.html`**.
2. Cari baris:

   ```js
   const USE_SUPABASE_AUTH = false;
   ```

3. Ubah menjadi:

   ```js
   const USE_SUPABASE_AUTH = true;
   ```

4. Simpan, lalu unggah/deploy ulang `index.html` seperti biasa.

Selesai. Sekarang:

- **Admin** login dengan email + password yang dibuat di Langkah 1.
- **Viewer** tetap bisa melihat data tanpa login.
- Percobaan mengubah data lewat Console browser tanpa login admin akan **ditolak server**.

---

## Cara menguji sudah aman

1. Buka web dalam mode Viewer (atau tanpa login).
2. Tekan `F12` → tab **Console** → ketik:

   ```js
   sb.from('iup').delete().neq('id', 0)
   ```

3. Jika muncul error / `row-level security` dan data **tidak** terhapus → berhasil aman.
   Jika data terhapus → berarti Langkah 2 belum berjalan; ulangi.

---

## Kalau login admin gagal setelah Langkah 3

- Pastikan kolom "Username" diisi dengan **email** admin (bukan nama).
- Pastikan user sudah **Confirmed** di Authentication → Users.
- Untuk sementara bisa kembalikan `USE_SUPABASE_AUTH = false` agar bisa masuk lagi,
  lalu periksa ulang Langkah 1–2.
