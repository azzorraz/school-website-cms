# School Website CMS - PRD

## Original Problem Statement
"cek github repo ku. lihat bagian sidebar menu halaman dashboard, coba rapikan sub menunya, agar listing ke bawah."

Repo: https://github.com/azzorraz/school-website-cms
Stack: Flask + MySQL + Tailwind CSS (existing codebase at /app)

## Tasks Done
- 2026-01: Merapikan sub-menu sidebar admin dashboard di `/app/app/templates/admin/base.html`
  - Sub-menu items sekarang listing vertikal rapi (flex column + gap)
  - Ditambahkan indentasi + garis vertikal panduan hierarki
  - Icon & padding disamakan; active state pakai warna kontras
  - Animasi expand/collapse halus
  - Dark mode support tetap terjaga

## Files Changed
- /app/app/templates/admin/base.html (hanya block <style>, HTML/JS tidak diubah)

## Next Backlog
- Optional: konversi sidebar ke component partial (`_sidebar.html`) supaya reusable
- Optional: highlight breadcrumb aktif di header berdasarkan section
