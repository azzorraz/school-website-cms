#!/bin/bash
# Create all Fase 4 admin templates
set -e
cd /home/openclaw/.openclaw/workspace/school-website

# ==================== PPDB Templates ====================
cat > app/templates/admin/ppdb/index.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}PPDB{% endblock %}
{% block page_title %}Pendaftaran PPDB{% endblock %}
{% block content %}
<div class="mb-5">
  <p class="text-gray-500">{{ ppdb_list|length }} pendaftar</p>
</div>
<div class="card overflow-hidden">
  <div class="overflow-x-auto">
    <table class="w-full text-sm">
      <thead class="bg-gray-50 border-b">
        <tr>
          <th class="text-left p-4 font-medium text-gray-600">Nama</th>
          <th class="text-left p-4 font-medium text-gray-600">Asal Sekolah</th>
          <th class="text-left p-4 font-medium text-gray-600">Orang Tua</th>
          <th class="text-left p-4 font-medium text-gray-600">Status</th>
          <th class="text-center p-4 font-medium text-gray-600">Aksi</th>
        </tr>
      </thead>
      <tbody>
        {% for p in ppdb_list %}
        <tr class="border-b hover:bg-gray-50">
          <td class="p-4 font-medium">{{ p.nama_lengkap }}</td>
          <td class="p-4 text-gray-500">{{ p.asal_sekolah or '-' }}</td>
          <td class="p-4">{{ p.nama_orangtua }}</td>
          <td class="p-4">
            {% if p.status == 'pending' %}
            <span class="px-2 py-1 bg-yellow-50 text-yellow-600 rounded-lg text-xs">Pending</span>
            {% elif p.status == 'diterima' %}
            <span class="px-2 py-1 bg-green-50 text-green-600 rounded-lg text-xs">Diterima</span>
            {% else %}
            <span class="px-2 py-1 bg-red-50 text-red-600 rounded-lg text-xs">Ditolak</span>
            {% endif %}
          </td>
          <td class="p-4 text-center">
            <a href="{{ url_for('admin.ppdb_detail', id=p.id) }}" class="text-blue-600 hover:text-blue-800 mr-2"><i class="fas fa-eye"></i></a>
            <a href="{{ url_for('admin.ppdb_hapus', id=p.id) }}" class="text-red-500 hover:text-red-700" onclick="return confirm('Hapus?')"><i class="fas fa-trash"></i></a>
          </td>
        </tr>
        {% else %}
        <tr><td colspan="5" class="p-8 text-center text-gray-400">Belum ada pendaftar</td></tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
</div>
{% endblock %}
TMPL

cat > app/templates/admin/ppdb/detail.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}Detail PPDB{% endblock %}
{% block page_title %}Detail Pendaftar{% endblock %}
{% block content %}
<div class="max-w-3xl animate-fade-in">
  <div class="card p-6">
    <div class="grid grid-cols-2 gap-6">
      <div>
        <label class="text-xs text-gray-400">Nama Lengkap</label>
        <p class="font-medium">{{ ppdb.nama_lengkap }}</p>
      </div>
      <div>
        <label class="text-xs text-gray-400">Nama Panggilan</label>
        <p>{{ ppdb.nama_panggilan or '-' }}</p>
      </div>
      <div>
        <label class="text-xs text-gray-400">Jenis Kelamin</label>
        <p>{{ ppdb.jenis_kelamin }}</p>
      </div>
      <div>
        <label class="text-xs text-gray-400">Tempat, Tanggal Lahir</label>
        <p>{{ ppdb.tempat_lahir }}, {{ ppdb.tanggal_lahir.strftime('%d/%m/%Y') }}</p>
      </div>
      <div>
        <label class="text-xs text-gray-400">Agama</label>
        <p>{{ ppdb.agama or '-' }}</p>
      </div>
      <div>
        <label class="text-xs text-gray-400">Asal Sekolah</label>
        <p>{{ ppdb.asal_sekolah or '-' }}</p>
      </div>
      <div class="col-span-2">
        <label class="text-xs text-gray-400">Alamat</label>
        <p>{{ ppdb.alamat }}</p>
      </div>
      <div>
        <label class="text-xs text-gray-400">Nama Orang Tua</label>
        <p>{{ ppdb.nama_orangtua }}</p>
      </div>
      <div>
        <label class="text-xs text-gray-400">No HP Orang Tua</label>
        <p>{{ ppdb.no_hp_orangtua }}</p>
      </div>
      <div>
        <label class="text-xs text-gray-400">Email Orang Tua</label>
        <p>{{ ppdb.email_orangtua or '-' }}</p>
      </div>
      <div>
        <label class="text-xs text-gray-400">Nilai Rata-rata</label>
        <p>{{ ppdb.nilai_rata or '-' }}</p>
      </div>
    </div>
    <form method="POST" action="{{ url_for('admin.ppdb_status', id=ppdb.id) }}" class="mt-6 pt-6 border-t space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
        <select name="status" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
          <option value="pending" {% if ppdb.status=='pending' %}selected{% endif %}>Pending</option>
          <option value="diterima" {% if ppdb.status=='diterima' %}selected{% endif %}>Diterima</option>
          <option value="ditolak" {% if ppdb.status=='ditolak' %}selected{% endif %}>Ditolak</option>
        </select>
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Catatan</label>
        <textarea name="catatan" rows="3" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">{{ ppdb.catatan or '' }}</textarea>
      </div>
      <div class="flex gap-3">
        <button type="submit" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700">Update Status</button>
        <a href="{{ url_for('admin.ppdb_index') }}" class="px-6 py-2.5 rounded-xl font-medium border border-gray-200 hover:bg-gray-50">Kembali</a>
      </div>
    </form>
  </div>
</div>
{% endblock %}
TMPL

echo "PPDB templates done"

# ==================== Download Templates ====================
cat > app/templates/admin/download/index.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}Download{% endblock %}
{% block page_title %}Manajemen Download{% endblock %}
{% block content %}
<div class="flex justify-between items-center mb-5">
  <p class="text-gray-500">{{ download_list|length }} file</p>
  <a href="{{ url_for('admin.download_tambah') }}" class="bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-blue-700">
    <i class="fas fa-plus mr-1"></i> Tambah File
  </a>
</div>
<div class="card overflow-hidden">
  <table class="w-full text-sm">
    <thead class="bg-gray-50 border-b">
      <tr><th class="text-left p-4 font-medium text-gray-600">Judul</th><th class="text-left p-4 font-medium text-gray-600">Kategori</th><th class="text-left p-4 font-medium text-gray-600">Download</th><th class="text-center p-4 font-medium text-gray-600">Aksi</th></tr>
    </thead>
    <tbody>
      {% for d in download_list %}
      <tr class="border-b hover:bg-gray-50">
        <td class="p-4 font-medium">{{ d.title }}</td>
        <td class="p-4"><span class="px-2 py-1 bg-blue-50 text-blue-600 rounded-lg text-xs">{{ d.kategori }}</span></td>
        <td class="p-4">{{ d.downloads }}x</td>
        <td class="p-4 text-center">
          <a href="{{ url_for('admin.download_edit', id=d.id) }}" class="text-blue-600 hover:text-blue-800 mr-2"><i class="fas fa-edit"></i></a>
          <a href="{{ url_for('admin.download_hapus', id=d.id) }}" class="text-red-500 hover:text-red-700" onclick="return confirm('Hapus?')"><i class="fas fa-trash"></i></a>
        </td>
      </tr>
      {% else %}
      <tr><td colspan="4" class="p-8 text-center text-gray-400">Belum ada file</td></tr>
      {% endfor %}
    </tbody>
  </table>
</div>
{% endblock %}
TMPL

cat > app/templates/admin/download/form.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}{% if dl %}Edit{% else %}Tambah{% endif %} File{% endblock %}
{% block page_title %}{% if dl %}Edit File{% else %}Tambah File Baru{% endif %}{% endblock %}
{% block content %}
<div class="max-w-2xl animate-fade-in">
  <div class="card p-6">
    <form method="POST" enctype="multipart/form-data" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Judul *</label>
        <input type="text" name="title" value="{{ dl.title if dl else '' }}" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Deskripsi</label>
        <textarea name="description" rows="3" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">{{ dl.description if dl else '' }}</textarea>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
          <select name="kategori" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
            <option value="umum">Umum</option>
            <option value="formulir">Formulir</option>
            <option value="kurikulum">Kurikulum</option>
            <option value="panduan">Panduan</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Urutan</label>
          <input type="number" name="position" value="{{ dl.position if dl else 0 }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">File</label>
        <input type="file" name="file" class="w-full text-sm">
        {% if dl and dl.file %}<p class="text-xs text-gray-400 mt-1">File saat ini: {{ dl.file }}</p>{% endif %}
      </div>
      <div class="flex gap-3 pt-2">
        <button type="submit" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700">Simpan</button>
        <a href="{{ url_for('admin.download_index') }}" class="px-6 py-2.5 rounded-xl font-medium border border-gray-200 hover:bg-gray-50">Batal</a>
      </div>
    </form>
  </div>
</div>
{% endblock %}
TMPL

echo "Download templates done"

# ==================== Kontak Templates ====================
cat > app/templates/admin/kontak/index.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}Pesan Kontak{% endblock %}
{% block page_title %}Pesan Kontak{% endblock %}
{% block content %}
<div class="mb-5">
  <p class="text-gray-500">{{ kontak_list|length }} pesan ({{ kontak_list|selectattr('is_sameas', false)|list|length }} belum dibaca)</p>
</div>
<div class="card overflow-hidden">
  <table class="w-full text-sm">
    <thead class="bg-gray-50 border-b">
      <tr><th class="text-left p-4 font-medium text-gray-600">Nama</th><th class="text-left p-4 font-medium text-gray-600">Subjek</th><th class="text-left p-4 font-medium text-gray-600">Tanggal</th><th class="text-left p-4 font-medium text-gray-600">Status</th><th class="text-center p-4 font-medium text-gray-600">Aksi</th></tr>
    </thead>
    <tbody>
      {% for k in kontak_list %}
      <tr class="border-b hover:bg-gray-50 {% if not k.is_read %}bg-blue-50/30{% endif %}">
        <td class="p-4 font-medium">{{ k.nama }}</td>
        <td class="p-4">{{ k.subjek }}</td>
        <td class="p-4 text-gray-500">{{ k.created_at.strftime('%d/%m/%Y %H:%M') }}</td>
        <td class="p-4">
          {% if k.is_read %}<span class="text-green-500 text-xs">Dibaca</span>
          {% else %}<span class="text-blue-600 text-xs font-medium">Baru</span>{% endif %}
        </td>
        <td class="p-4 text-center">
          <a href="{{ url_for('admin.kontak_baca', id=k.id) }}" class="text-blue-600 hover:text-blue-800 mr-2"><i class="fas fa-eye"></i></a>
          <a href="{{ url_for('admin.kontak_hapus', id=k.id) }}" class="text-red-500 hover:text-red-700" onclick="return confirm('Hapus?')"><i class="fas fa-trash"></i></a>
        </td>
      </tr>
      {% else %}
      <tr><td colspan="5" class="p-8 text-center text-gray-400">Belum ada pesan</td></tr>
      {% endfor %}
    </tbody>
  </table>
</div>
{% endblock %}
TMPL

cat > app/templates/admin/kontak/detail.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}Detail Pesan{% endblock %}
{% block page_title %}Detail Pesan Kontak{% endblock %}
{% block content %}
<div class="max-w-2xl animate-fade-in">
  <div class="card p-6">
    <div class="space-y-4">
      <div><label class="text-xs text-gray-400">Nama</label><p class="font-medium">{{ kontak.nama }}</p></div>
      <div><label class="text-xs text-gray-400">Email</label><p>{{ kontak.email }}</p></div>
      {% if kontak.no_hp %}<div><label class="text-xs text-gray-400">No HP</label><p>{{ kontak.no_hp }}</p></div>{% endif %}
      <div><label class="text-xs text-gray-400">Subjek</label><p class="font-medium">{{ kontak.subjek }}</p></div>
      <div><label class="text-xs text-gray-400">Pesan</label><p class="text-gray-600 whitespace-pre-wrap">{{ kontak.pesan }}</p></div>
      <div><label class="text-xs text-gray-400">Tanggal</label><p>{{ kontak.created_at.strftime('%d/%m/%Y %H:%M') }}</p></div>
    </div>
    <div class="mt-6 pt-4 border-t">
      <a href="mailto:{{ kontak.email }}?subject=Re: {{ kontak.subjek }}" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700">
        <i class="fas fa-reply mr-1"></i> Balas via Email
      </a>
      <a href="{{ url_for('admin.kontak_index') }}" class="ml-3 px-6 py-2.5 rounded-xl font-medium border border-gray-200 hover:bg-gray-50">Kembali</a>
    </div>
  </div>
</div>
{% endblock %}
TMPL

echo "Kontak templates done"

# ==================== Testimoni Templates ====================
cat > app/templates/admin/testimoni/index.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}Testimoni{% endblock %}
{% block page_title %}Manajemen Testimoni{% endblock %}
{% block content %}
<div class="flex justify-between items-center mb-5">
  <p class="text-gray-500">{{ testimoni_list|length }} testimoni</p>
  <a href="{{ url_for('admin.testimoni_tambah') }}" class="bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-blue-700">
    <i class="fas fa-plus mr-1"></i> Tambah Testimoni
  </a>
</div>
<div class="grid md:grid-cols-2 gap-4">
  {% for t in testimoni_list %}
  <div class="card p-5">
    <div class="flex items-start gap-4">
      {% if t.foto %}
      <img src="{{ url_for('static', filename='uploads/'+t.foto) }}" class="w-12 h-12 rounded-full object-cover">
      {% else %}
      <div class="w-12 h-12 bg-purple-100 text-purple-600 rounded-full flex items-center justify-center font-bold">{{ t.nama[0] }}</div>
      {% endif %}
      <div class="flex-1">
        <div class="flex items-center justify-between">
          <div>
            <p class="font-medium">{{ t.nama }}</p>
            <p class="text-xs text-gray-400">{{ t.role }}</p>
          </div>
          <div class="flex gap-1">
            {% for i in range(t.rating) %}<i class="fas fa-star text-yellow-400 text-xs"></i>{% endfor %}
          </div>
        </div>
        <p class="text-sm text-gray-500 mt-2">"{{ t.isi[:150] }}{% if t.isi|length > 150 %}...{% endif %}"</p>
        <div class="mt-3 flex gap-2">
          <a href="{{ url_for('admin.testimoni_edit', id=t.id) }}" class="text-blue-600 hover:text-blue-800 text-xs"><i class="fas fa-edit"></i> Edit</a>
          <a href="{{ url_for('admin.testimoni_hapus', id=t.id) }}" class="text-red-500 hover:text-red-700 text-xs" onclick="return confirm('Hapus?')"><i class="fas fa-trash"></i> Hapus</a>
        </div>
      </div>
    </div>
  </div>
  {% else %}
  <div class="col-span-full text-center py-12 text-gray-400">Belum ada testimoni</div>
  {% endfor %}
</div>
{% endblock %}
TMPL

cat > app/templates/admin/testimoni/form.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}{% if t %}Edit{% else %}Tambah{% endif %} Testimoni{% endblock %}
{% block page_title %}{% if t %}Edit Testimoni{% else %}Tambah Testimoni{% endif %}{% endblock %}
{% block content %}
<div class="max-w-2xl animate-fade-in">
  <div class="card p-6">
    <form method="POST" enctype="multipart/form-data" class="space-y-4">
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Nama *</label>
          <input type="text" name="nama" value="{{ t.nama if t else '' }}" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
          <select name="role" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
            <option value="Orang Tua">Orang Tua</option>
            <option value="Siswa">Siswa</option>
            <option value="Alumni">Alumni</option>
          </select>
        </div>
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Isi Testimoni *</label>
        <textarea name="isi" rows="4" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">{{ t.isi if t else '' }}</textarea>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Rating</label>
          <select name="rating" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
            {% for i in range(1,6) %}
            <option value="{{ i }}" {% if t and t.rating==i %}selected{% endif %}>{{ i }} Bintang</option>
            {% endfor %}
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Urutan</label>
          <input type="number" name="position" value="{{ t.position if t else 0 }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Foto</label>
        <input type="file" name="foto" accept="image/*" class="w-full text-sm">
      </div>
      <div class="flex gap-3 pt-2">
        <button type="submit" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700">Simpan</button>
        <a href="{{ url_for('admin.testimoni_index') }}" class="px-6 py-2.5 rounded-xl font-medium border border-gray-200 hover:bg-gray-50">Batal</a>
      </div>
    </form>
  </div>
</div>
{% endblock %}
TMPL

echo "Testimoni templates done"

# ==================== Slider Templates ====================
cat > app/templates/admin/slider/index.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}Slider{% endblock %}
{% block page_title %}Manajemen Slider{% endblock %}
{% block content %}
<div class="flex justify-between items-center mb-5">
  <p class="text-gray-500">{{ slider_list|length }} slider</p>
  <a href="{{ url_for('admin.slider_tambah') }}" class="bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-blue-700">
    <i class="fas fa-plus mr-1"></i> Tambah Slider
  </a>
</div>
<div class="grid md:grid-cols-2 gap-4">
  {% for s in slider_list %}
  <div class="card overflow-hidden group">
    <div class="aspect-video relative">
      <img src="{{ url_for('static', filename='uploads/'+s.image) }}" class="w-full h-full object-cover">
      <div class="absolute inset-0 bg-black/0 group-hover:bg-black/40 transition-all flex items-center justify-center gap-2">
        <a href="{{ url_for('admin.slider_edit', id=s.id) }}" class="text-white opacity-0 group-hover:opacity-100 transition-all"><i class="fas fa-edit"></i></a>
        <a href="{{ url_for('admin.slider_hapus', id=s.id) }}" class="text-red-300 opacity-0 group-hover:opacity-100 transition-all" onclick="return confirm('Hapus?')"><i class="fas fa-trash"></i></a>
      </div>
    </div>
    <div class="p-4">
      <p class="font-medium">{{ s.title or 'Tanpa Judul' }}</p>
      <p class="text-xs text-gray-400">{{ s.subtitle or '' }}</p>
    </div>
  </div>
  {% else %}
  <div class="col-span-full text-center py-12 text-gray-400">Belum ada slider</div>
  {% endfor %}
</div>
{% endblock %}
TMPL

cat > app/templates/admin/slider/form.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}{% if s %}Edit{% else %}Tambah{% endif %} Slider{% endblock %}
{% block page_title %}{% if s %}Edit Slider{% else %}Tambah Slider{% endif %}{% endblock %}
{% block content %}
<div class="max-w-2xl animate-fade-in">
  <div class="card p-6">
    <form method="POST" enctype="multipart/form-data" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Judul</label>
        <input type="text" name="title" value="{{ s.title if s else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Subtitle</label>
        <input type="text" name="subtitle" value="{{ s.subtitle if s else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">URL (opsional)</label>
        <input type="text" name="url" value="{{ s.url if s else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Gambar *</label>
        <input type="file" name="image" accept="image/*" class="w-full text-sm">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Urutan</label>
        <input type="number" name="position" value="{{ s.position if s else 0 }}" class="w-24 px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div class="flex gap-3 pt-2">
        <button type="submit" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700">Simpan</button>
        <a href="{{ url_for('admin.slider_index') }}" class="px-6 py-2.5 rounded-xl font-medium border border-gray-200 hover:bg-gray-50">Batal</a>
      </div>
    </form>
  </div>
</div>
{% endblock %}
TMPL

echo "Slider templates done"

# ==================== FAQ Templates ====================
cat > app/templates/admin/faq/index.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}FAQ{% endblock %}
{% block page_title %}Manajemen FAQ{% endblock %}
{% block content %}
<div class="flex justify-between items-center mb-5">
  <p class="text-gray-500">{{ faq_list|length }} FAQ</p>
  <a href="{{ url_for('admin.faq_tambah') }}" class="bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-blue-700">
    <i class="fas fa-plus mr-1"></i> Tambah FAQ
  </a>
</div>
<div class="space-y-3">
  {% for f in faq_list %}
  <div class="card p-5">
    <div class="flex items-start justify-between">
      <div class="flex-1">
        <p class="font-medium">{{ f.pertanyaan }}</p>
        <p class="text-sm text-gray-500 mt-1">{{ f.jawaban[:200] }}{% if f.jawaban|length > 200 %}...{% endif %}</p>
        <span class="text-xs text-gray-400 mt-2 inline-block">{{ f.kategori }}</span>
      </div>
      <div class="flex gap-2 ml-4">
        <a href="{{ url_for('admin.faq_edit', id=f.id) }}" class="text-blue-600 hover:text-blue-800"><i class="fas fa-edit"></i></a>
        <a href="{{ url_for('admin.faq_hapus', id=f.id) }}" class="text-red-500 hover:text-red-700" onclick="return confirm('Hapus?')"><i class="fas fa-trash"></i></a>
      </div>
    </div>
  </div>
  {% else %}
  <div class="text-center py-12 text-gray-400">Belum ada FAQ</div>
  {% endfor %}
</div>
{% endblock %}
TMPL

cat > app/templates/admin/faq/form.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}{% if f %}Edit{% else %}Tambah{% endif %} FAQ{% endblock %}
{% block page_title %}{% if f %}Edit FAQ{% else %}Tambah FAQ{% endif %}{% endblock %}
{% block content %}
<div class="max-w-2xl animate-fade-in">
  <div class="card p-6">
    <form method="POST" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Pertanyaan *</label>
        <input type="text" name="pertanyaan" value="{{ f.pertanyaan if f else '' }}" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Jawaban *</label>
        <textarea name="jawaban" rows="5" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">{{ f.jawaban if f else '' }}</textarea>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
          <select name="kategori" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
            <option value="umum">Umum</option>
            <option value="ppdb">PPDB</option>
            <option value="akademik">Akademik</option>
            <option value="fasilitas">Fasilitas</option>
            <option value="biaya">Biaya</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Urutan</label>
          <input type="number" name="position" value="{{ f.position if f else 0 }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
      </div>
      <div class="flex gap-3 pt-2">
        <button type="submit" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700">Simpan</button>
        <a href="{{ url_for('admin.faq_index') }}" class="px-6 py-2.5 rounded-xl font-medium border border-gray-200 hover:bg-gray-50">Batal</a>
      </div>
    </form>
  </div>
</div>
{% endblock %}
TMPL

echo "FAQ templates done"

# ==================== Public templates ====================

cat > app/templates/public/ppdb.html << 'TMPL'
{% extends "public/base.html" %}
{% block title %}PPDB Online{% endblock %}
{% block content %}
<section class="bg-blue-600 py-16">
  <div class="max-w-7xl mx-auto px-4 text-center">
    <h1 class="text-3xl font-bold text-white mb-3">Pendaftaran PPDB Online</h1>
    <p class="text-blue-100">Penerimaan Peserta Didik Baru {{ site_name }}</p>
  </div>
</section>
<section class="py-16">
  <div class="max-w-2xl mx-auto px-4">
    <div class="card p-8">
      <h2 class="text-xl font-bold mb-6">Formulir Pendaftaran</h2>
      <form method="POST" enctype="multipart/form-data" class="space-y-4">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nama Lengkap *</label>
            <input type="text" name="nama_lengkap" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nama Panggilan</label>
            <input type="text" name="nama_panggilan" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
          </div>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Jenis Kelamin *</label>
            <select name="jenis_kelamin" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
              <option value="Laki-laki">Laki-laki</option>
              <option value="Perempuan">Perempuan</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Agama</label>
            <select name="agama" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
              <option value="Islam">Islam</option>
              <option value="Kristen">Kristen</option>
              <option value="Katolik">Katolik</option>
              <option value="Hindu">Hindu</option>
              <option value="Buddha">Buddha</option>
              <option value="Konghucu">Konghucu</option>
            </select>
          </div>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Tempat Lahir *</label>
            <input type="text" name="tempat_lahir" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal Lahir *</label>
            <input type="date" name="tanggal_lahir" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
          </div>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Alamat *</label>
          <textarea name="alamat" rows="3" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200"></textarea>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nama Orang Tua *</label>
            <input type="text" name="nama_orangtua" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">No HP Orang Tua *</label>
            <input type="text" name="no_hp_orangtua" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
          </div>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email Orang Tua</label>
            <input type="email" name="email_orangtua" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Asal Sekolah</label>
            <input type="text" name="asal_sekolah" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
          </div>
        </div>
        <button type="submit" class="w-full bg-blue-600 text-white py-3 rounded-xl font-medium hover:bg-blue-700 transition-all">
          <i class="fas fa-paper-plane mr-2"></i> Kirim Pendaftaran
        </button>
      </form>
    </div>
  </div>
</section>
{% endblock %}
TMPL

cat > app/templates/public/download.html << 'TMPL'
{% extends "public/base.html" %}
{% block title %}Download{% endblock %}
{% block content %}
<section class="bg-blue-600 py-16">
  <div class="max-w-7xl mx-auto px-4 text-center">
    <h1 class="text-3xl font-bold text-white mb-3">Pusat Download</h1>
    <p class="text-blue-100">Download dokumen dan formulir sekolah</p>
  </div>
</section>
<section class="py-16">
  <div class="max-w-4xl mx-auto px-4">
    <div class="space-y-4">
      {% for d in download_list %}
      <div class="card p-5 flex items-center justify-between hover:shadow-md transition-all">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 bg-blue-100 text-blue-600 rounded-xl flex items-center justify-center">
            <i class="fas fa-file-download text-xl"></i>
          </div>
          <div>
            <p class="font-medium">{{ d.title }}</p>
            {% if d.description %}<p class="text-sm text-gray-500">{{ d.description[:100] }}</p>{% endif %}
            <span class="text-xs text-gray-400">{{ d.kategori }} · {{ d.downloads }}x download</span>
          </div>
        </div>
        <a href="{{ url_for('public.download_file', id=d.id) }}" class="bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-blue-700">
          <i class="fas fa-download mr-1"></i> Download
        </a>
      </div>
      {% else %}
      <div class="text-center py-12 text-gray-400">Belum ada file tersedia</div>
      {% endfor %}
    </div>
  </div>
</section>
{% endblock %}
TMPL

cat > app/templates/public/kontak.html << 'TMPL'
{% extends "public/base.html" %}
{% block title %}Hubungi Kami{% endblock %}
{% block content %}
<section class="bg-blue-600 py-16">
  <div class="max-w-7xl mx-auto px-4 text-center">
    <h1 class="text-3xl font-bold text-white mb-3">Hubungi Kami</h1>
    <p class="text-blue-100">Sampaikan pertanyaan atau saran Anda</p>
  </div>
</section>
<section class="py-16">
  <div class="max-w-4xl mx-auto px-4 grid md:grid-cols-2 gap-8">
    <div>
      <h2 class="text-xl font-bold mb-4">Kirim Pesan</h2>
      <form method="POST" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Nama *</label>
          <input type="text" name="nama" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Email *</label>
          <input type="email" name="email" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">No HP</label>
          <input type="text" name="no_hp" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Subjek *</label>
          <input type="text" name="subjek" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Pesan *</label>
          <textarea name="pesan" rows="5" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200"></textarea>
        </div>
        <button type="submit" class="w-full bg-blue-600 text-white py-3 rounded-xl font-medium hover:bg-blue-700">
          <i class="fas fa-paper-plane mr-2"></i> Kirim Pesan
        </button>
      </form>
    </div>
    <div>
      <h2 class="text-xl font-bold mb-4">Informasi Kontak</h2>
      <div class="space-y-4">
        <div class="flex items-start gap-3">
          <div class="w-10 h-10 bg-blue-100 text-blue-600 rounded-xl flex items-center justify-center flex-shrink-0"><i class="fas fa-map-marker-alt"></i></div>
          <div><p class="font-medium">Alamat</p><p class="text-gray-500 text-sm">Jl. Pendidikan No. 123, Kota Anda</p></div>
        </div>
        <div class="flex items-start gap-3">
          <div class="w-10 h-10 bg-green-100 text-green-600 rounded-xl flex items-center justify-center flex-shrink-0"><i class="fas fa-phone"></i></div>
          <div><p class="font-medium">Telepon</p><p class="text-gray-500 text-sm">(021) 1234567</p></div>
        </div>
        <div class="flex items-start gap-3">
          <div class="w-10 h-10 bg-purple-100 text-purple-600 rounded-xl flex items-center justify-center flex-shrink-0"><i class="fas fa-envelope"></i></div>
          <div><p class="font-medium">Email</p><p class="text-gray-500 text-sm">info@sekolah.sch.id</p></div>
        </div>
      </div>
    </div>
  </div>
</section>
{% endblock %}
TMPL

cat > app/templates/public/faq.html << 'TMPL'
{% extends "public/base.html" %}
{% block title %}FAQ{% endblock %}
{% block content %}
<section class="bg-blue-600 py-16">
  <div class="max-w-7xl mx-auto px-4 text-center">
    <h1 class="text-3xl font-bold text-white mb-3">FAQ</h1>
    <p class="text-blue-100">Pertanyaan yang Sering Diajukan</p>
  </div>
</section>
<section class="py-16">
  <div class="max-w-3xl mx-auto px-4">
    <div class="space-y-4">
      {% for f in faq_list %}
      <div class="card overflow-hidden">
        <button onclick="this.nextElementSibling.classList.toggle('hidden'); this.querySelector('.faq-icon').classList.toggle('rotate-180')" class="w-full text-left p-5 flex items-center justify-between hover:bg-gray-50 transition-all">
          <span class="font-medium pr-4">{{ f.pertanyaan }}</span>
          <i class="fas fa-chevron-down faq-icon transition-transform flex-shrink-0"></i>
        </button>
        <div class="hidden px-5 pb-5 text-gray-500 text-sm border-t pt-4">
          {{ f.jawaban }}
        </div>
      </div>
      {% else %}
      <div class="text-center py-12 text-gray-400">Belum ada FAQ</div>
      {% endfor %}
    </div>
  </div>
</section>
{% endblock %}
TMPL

echo "All public templates done"
echo "=== FASE 4 TEMPLATES COMPLETE ==="
