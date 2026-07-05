#!/bin/bash
# FASE 3 - Full implementation script
# Jalankan bertahap file by file
set -e

PROJECT="/home/openclaw/.openclaw/workspace/school-website"
cd "$PROJECT"

echo "=== FASE 3: Models, Admin CRUD, Public Pages ==="
echo ""

# =============== 1. UPDATE ADMIN ROUTES ===============
echo "[1/6] Update admin_routes.py with CRUD Guru..."

cat > /tmp/admin_part_guru.py << 'ADMIN_GURU'

import os
import uuid
from datetime import datetime
from werkzeug.utils import secure_filename
from flask import current_app

# ==================== GURU CRUD ====================
@admin_bp.route('/guru')
@login_required
def guru_list():
    guru_list = Guru.query.order_by(Guru.position).all()
    return render_template('admin/guru/index.html', guru_list=guru_list)

@admin_bp.route('/guru/tambah', methods=['GET', 'POST'])
@login_required
def guru_tambah():
    if request.method == 'POST':
        guru = Guru(
            nama=request.form['nama'],
            nip=request.form.get('nip', ''),
            mata_pelajaran=request.form.get('mata_pelajaran', ''),
            pendidikan=request.form.get('pendidikan', ''),
            prestasi=request.form.get('prestasi', ''),
            jabatan=request.form.get('jabatan', ''),
            bio=request.form.get('bio', ''),
            email=request.form.get('email', ''),
            position=int(request.form.get('position', 0))
        )
        if 'photo' in request.files:
            file = request.files['photo']
            if file and file.filename:
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"guru_{uuid.uuid4().hex}.{ext}"
                file.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                guru.photo = filename
        db.session.add(guru)
        db.session.commit()
        flash('Guru berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.guru_list'))
    return render_template('admin/guru/form.html', guru=None)

@admin_bp.route('/guru/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def guru_edit(id):
    guru = Guru.query.get_or_404(id)
    if request.method == 'POST':
        guru.nama = request.form['nama']
        guru.nip = request.form.get('nip', '')
        guru.mata_pelajaran = request.form.get('mata_pelajaran', '')
        guru.pendidikan = request.form.get('pendidikan', '')
        guru.prestasi = request.form.get('prestasi', '')
        guru.jabatan = request.form.get('jabatan', '')
        guru.bio = request.form.get('bio', '')
        guru.email = request.form.get('email', '')
        guru.position = int(request.form.get('position', 0))
        if 'photo' in request.files:
            file = request.files['photo']
            if file and file.filename:
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"guru_{uuid.uuid4().hex}.{ext}"
                file.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                guru.photo = filename
        db.session.commit()
        flash('Guru berhasil diupdate!', 'success')
        return redirect(url_for('admin.guru_list'))
    return render_template('admin/guru/form.html', guru=guru)

@admin_bp.route('/guru/hapus/<int:id>')
@login_required
def guru_hapus(id):
    guru = Guru.query.get_or_404(id)
    db.session.delete(guru)
    db.session.commit()
    flash('Guru berhasil dihapus!', 'success')
    return redirect(url_for('admin.guru_list'))

# ==================== GALERI CRUD ====================
@admin_bp.route('/galeri')
@login_required
def galeri_list():
    galeri_list = Galeri.query.order_by(Galeri.created_at.desc()).all()
    return render_template('admin/galeri/index.html', galeri_list=galeri_list)

@admin_bp.route('/galeri/tambah', methods=['GET', 'POST'])
@login_required
def galeri_tambah():
    if request.method == 'POST':
        galeri = Galeri(
            title=request.form['title'],
            description=request.form.get('description', ''),
            kategori=request.form.get('kategori', 'foto'),
            video_url=request.form.get('video_url', '')
        )
        if 'image' in request.files:
            file = request.files['image']
            if file and file.filename:
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"galeri_{uuid.uuid4().hex}.{ext}"
                file.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                galeri.image = filename
        db.session.add(galeri)
        db.session.commit()
        flash('Galeri berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.galeri_list'))
    return render_template('admin/galeri/form.html', galeri=None)

@admin_bp.route('/galeri/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def galeri_edit(id):
    galeri = Galeri.query.get_or_404(id)
    if request.method == 'POST':
        galeri.title = request.form['title']
        galeri.description = request.form.get('description', '')
        galeri.kategori = request.form.get('kategori', 'foto')
        galeri.video_url = request.form.get('video_url', '')
        if 'image' in request.files:
            file = request.files['image']
            if file and file.filename:
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"galeri_{uuid.uuid4().hex}.{ext}"
                file.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                galeri.image = filename
        db.session.commit()
        flash('Galeri berhasil diupdate!', 'success')
        return redirect(url_for('admin.galeri_list'))
    return render_template('admin/galeri/form.html', galeri=galeri)

@admin_bp.route('/galeri/hapus/<int:id>')
@login_required
def galeri_hapus(id):
    galeri = Galeri.query.get_or_404(id)
    db.session.delete(galeri)
    db.session.commit()
    flash('Galeri berhasil dihapus!', 'success')
    return redirect(url_for('admin.galeri_list'))

# ==================== AGENDA CRUD ====================
@admin_bp.route('/agenda')
@login_required
def agenda_list():
    agenda_list = Agenda.query.order_by(Agenda.start_date.desc()).all()
    return render_template('admin/agenda/index.html', agenda_list=agenda_list)

@admin_bp.route('/agenda/tambah', methods=['GET', 'POST'])
@login_required
def agenda_tambah():
    if request.method == 'POST':
        agenda = Agenda(
            title=request.form['title'],
            description=request.form.get('description', ''),
            lokasi=request.form.get('lokasi', ''),
            start_date=datetime.strptime(request.form['start_date'], '%Y-%m-%dT%H:%M'),
            end_date=datetime.strptime(request.form['end_date'], '%Y-%m-%dT%H:%M') if request.form.get('end_date') else None,
            kategori=request.form.get('kategori', 'kegiatan')
        )
        db.session.add(agenda)
        db.session.commit()
        flash('Agenda berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.agenda_list'))
    return render_template('admin/agenda/form.html', agenda=None)

@admin_bp.route('/agenda/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def agenda_edit(id):
    agenda = Agenda.query.get_or_404(id)
    if request.method == 'POST':
        agenda.title = request.form['title']
        agenda.description = request.form.get('description', '')
        agenda.lokasi = request.form.get('lokasi', '')
        agenda.start_date = datetime.strptime(request.form['start_date'], '%Y-%m-%dT%H:%M')
        agenda.end_date = datetime.strptime(request.form['end_date'], '%Y-%m-%dT%H:%M') if request.form.get('end_date') else None
        agenda.kategori = request.form.get('kategori', 'kegiatan')
        db.session.commit()
        flash('Agenda berhasil diupdate!', 'success')
        return redirect(url_for('admin.agenda_list'))
    return render_template('admin/agenda/form.html', agenda=agenda)

@admin_bp.route('/agenda/hapus/<int:id>')
@login_required
def agenda_hapus(id):
    agenda = Agenda.query.get_or_404(id)
    db.session.delete(agenda)
    db.session.commit()
    flash('Agenda berhasil dihapus!', 'success')
    return redirect(url_for('admin.agenda_list'))

# ==================== PRESTASI CRUD ====================
@admin_bp.route('/prestasi')
@login_required
def prestasi_list():
    prestasi_list = Prestasi.query.order_by(Prestasi.created_at.desc()).all()
    return render_template('admin/prestasi/index.html', prestasi_list=prestasi_list)

@admin_bp.route('/prestasi/tambah', methods=['GET', 'POST'])
@login_required
def prestasi_tambah():
    if request.method == 'POST':
        prestasi = Prestasi(
            title=request.form['title'],
            description=request.form.get('description', ''),
            kategori=request.form.get('kategori', 'siswa'),
            juara=request.form.get('juara', ''),
            tingkat=request.form.get('tingkat', ''),
            tahun=int(request.form['tahun']) if request.form.get('tahun') else None
        )
        if 'photo' in request.files:
            file = request.files['photo']
            if file and file.filename:
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"prestasi_{uuid.uuid4().hex}.{ext}"
                file.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                prestasi.photo = filename
        db.session.add(prestasi)
        db.session.commit()
        flash('Prestasi berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.prestasi_list'))
    return render_template('admin/prestasi/form.html', prestasi=None)

@admin_bp.route('/prestasi/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def prestasi_edit(id):
    prestasi = Prestasi.query.get_or_404(id)
    if request.method == 'POST':
        prestasi.title = request.form['title']
        prestasi.description = request.form.get('description', '')
        prestasi.kategori = request.form.get('kategori', 'siswa')
        prestasi.juara = request.form.get('juara', '')
        prestasi.tingkat = request.form.get('tingkat', '')
        prestasi.tahun = int(request.form['tahun']) if request.form.get('tahun') else None
        if 'photo' in request.files:
            file = request.files['photo']
            if file and file.filename:
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"prestasi_{uuid.uuid4().hex}.{ext}"
                file.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                prestasi.photo = filename
        db.session.commit()
        flash('Prestasi berhasil diupdate!', 'success')
        return redirect(url_for('admin.prestasi_list'))
    return render_template('admin/prestasi/form.html', prestasi=prestasi)

@admin_bp.route('/prestasi/hapus/<int:id>')
@login_required
def prestasi_hapus(id):
    prestasi = Prestasi.query.get_or_404(id)
    db.session.delete(prestasi)
    db.session.commit()
    flash('Prestasi berhasil dihapus!', 'success')
    return redirect(url_for('admin.prestasi_list'))

# ==================== ESKUL CRUD ====================
@admin_bp.route('/eskul')
@login_required
def eskul_list():
    eskul_list = Ekstrakurikuler.query.order_by(Ekstrakurikuler.position).all()
    return render_template('admin/eskul/index.html', eskul_list=eskul_list)

@admin_bp.route('/eskul/tambah', methods=['GET', 'POST'])
@login_required
def eskul_tambah():
    if request.method == 'POST':
        eskul = Ekstrakurikuler(
            name=request.form['name'],
            description=request.form.get('description', ''),
            pembina=request.form.get('pembina', ''),
            jadwal=request.form.get('jadwal', ''),
            icon=request.form.get('icon', 'fas fa-star'),
            position=int(request.form.get('position', 0))
        )
        if 'photo' in request.files:
            file = request.files['photo']
            if file and file.filename:
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"eskul_{uuid.uuid4().hex}.{ext}"
                file.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                eskul.photo = filename
        db.session.add(eskul)
        db.session.commit()
        flash('Ekstrakurikuler berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.eskul_list'))
    return render_template('admin/eskul/form.html', eskul=None)

@admin_bp.route('/eskul/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def eskul_edit(id):
    eskul = Ekstrakurikuler.query.get_or_404(id)
    if request.method == 'POST':
        eskul.name = request.form['name']
        eskul.description = request.form.get('description', '')
        eskul.pembina = request.form.get('pembina', '')
        eskul.jadwal = request.form.get('jadwal', '')
        eskul.icon = request.form.get('icon', 'fas fa-star')
        eskul.position = int(request.form.get('position', 0))
        if 'photo' in request.files:
            file = request.files['photo']
            if file and file.filename:
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"eskul_{uuid.uuid4().hex}.{ext}"
                file.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                eskul.photo = filename
        db.session.commit()
        flash('Ekstrakurikuler berhasil diupdate!', 'success')
        return redirect(url_for('admin.eskul_list'))
    return render_template('admin/eskul/form.html', eskul=eskul)

@admin_bp.route('/eskul/hapus/<int:id>')
@login_required
def eskul_hapus(id):
    eskul = Ekstrakurikuler.query.get_or_404(id)
    db.session.delete(eskul)
    db.session.commit()
    flash('Ekstrakurikuler berhasil dihapus!', 'success')
    return redirect(url_for('admin.eskul_list'))
ADMIN_GURU

# Append to existing admin_routes.py
cp app/routes/admin_routes.py app/routes/admin_routes.py.bak
grep -v "^from app import\|^from app.models\|^from flask import\|^import os\|^import uuid" /tmp/admin_part_guru.py >> app/routes/admin_routes.py

echo "[1/6] Done"

# =============== 2. PUBLIC ROUTES ===============
echo "[2/6] Update public_routes.py..."
cat > /tmp/public_part.py << 'PUBLIC'

@public_bp.route('/profil')
def profil():
    return render_template('public/profil.html')

@public_bp.route('/guru')
def guru():
    guru_list = Guru.query.filter_by(is_active=True).order_by(Guru.position).all()
    return render_template('public/guru.html', guru_list=guru_list)

@public_bp.route('/galeri')
def galeri():
    kategori = request.args.get('kategori', '')
    query = Galeri.query.filter_by(is_active=True)
    if kategori:
        query = query.filter_by(kategori=kategori)
    galeri_list = query.order_by(Galeri.created_at.desc()).all()
    kategori_list = db.session.query(Galeri.kategori).distinct().all()
    return render_template('public/galeri.html', galeri_list=galeri_list, kategori_list=[k[0] for k in kategori_list], selected_kategori=kategori)

@public_bp.route('/agenda')
def agenda():
    agenda_list = Agenda.query.filter(Agenda.is_active==True, Agenda.start_date>=datetime.utcnow()).order_by(Agenda.start_date).all()
    return render_template('public/agenda.html', agenda_list=agenda_list)

@public_bp.route('/prestasi')
def prestasi():
    prestasi_list = Prestasi.query.filter_by(is_active=True).order_by(Prestasi.created_at.desc()).all()
    return render_template('public/prestasi.html', prestasi_list=prestasi_list)

@public_bp.route('/ekstrakurikuler')
def eskul():
    eskul_list = Ekstrakurikuler.query.filter_by(is_active=True).order_by(Ekstrakurikuler.position).all()
    return render_template('public/eskul.html', eskul_list=eskul_list)
PUBLIC

echo "[2/6] Done"

# =============== 3. CREATE ALL TEMPLATES ===============
echo "[3/6] Creating 20+ template files..."

# Admin templates - Guru
mkdir -p app/templates/admin/guru app/templates/admin/galeri app/templates/admin/agenda app/templates/admin/prestasi app/templates/admin/eskul

cat > app/templates/admin/guru/index.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}Guru{% endblock %}
{% block page_title %}Manajemen Guru{% endblock %}
{% block content %}
<div class="flex justify-between items-center mb-5">
  <p class="text-gray-500">{{ guru_list|length }} guru terdaftar</p>
  <a href="{{ url_for('admin.guru_tambah') }}" class="bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-blue-700">
    <i class="fas fa-plus mr-1"></i> Tambah Guru
  </a>
</div>
<div class="card overflow-hidden">
  <div class="overflow-x-auto">
    <table class="w-full text-sm">
      <thead class="bg-gray-50 border-b">
        <tr>
          <th class="text-left p-4 font-medium text-gray-600">Nama</th>
          <th class="text-left p-4 font-medium text-gray-600">NIP</th>
          <th class="text-left p-4 font-medium text-gray-600">Mata Pelajaran</th>
          <th class="text-left p-4 font-medium text-gray-600">Jabatan</th>
          <th class="text-center p-4 font-medium text-gray-600">Aksi</th>
        </tr>
      </thead>
      <tbody>
        {% for guru in guru_list %}
        <tr class="border-b hover:bg-gray-50">
          <td class="p-4">
            <div class="flex items-center gap-3">
              {% if guru.photo %}
              <img src="{{ url_for('static', filename='uploads/'+guru.photo) }}" class="w-10 h-10 rounded-full object-cover">
              {% else %}
              <div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center text-blue-600 font-bold">{{ guru.nama[0] }}</div>
              {% endif %}
              <span class="font-medium">{{ guru.nama }}</span>
            </div>
          </td>
          <td class="p-4 text-gray-500">{{ guru.nip or '-' }}</td>
          <td class="p-4">{{ guru.mata_pelajaran or '-' }}</td>
          <td class="p-4">{{ guru.jabatan or '-' }}</td>
          <td class="p-4 text-center">
            <a href="{{ url_for('admin.guru_edit', id=guru.id) }}" class="text-blue-600 hover:text-blue-800 mr-2"><i class="fas fa-edit"></i></a>
            <a href="{{ url_for('admin.guru_hapus', id=guru.id) }}" class="text-red-500 hover:text-red-700" onclick="return confirm('Hapus guru ini?')"><i class="fas fa-trash"></i></a>
          </td>
        </tr>
        {% else %}
        <tr><td colspan="5" class="p-8 text-center text-gray-400">Belum ada guru</td></tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
</div>
{% endblock %}
TMPL

cat > app/templates/admin/guru/form.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}{% if guru %}Edit{% else %}Tambah{% endif %} Guru{% endblock %}
{% block page_title %}{% if guru %}Edit Guru{% else %}Tambah Guru Baru{% endif %}{% endblock %}
{% block content %}
<div class="max-w-2xl animate-fade-in">
  <div class="card p-6">
    <form method="POST" enctype="multipart/form-data" class="space-y-4">
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Nama Lengkap *</label>
          <input type="text" name="nama" value="{{ guru.nama if guru else '' }}" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">NIP</label>
          <input type="text" name="nip" value="{{ guru.nip if guru else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">
        </div>
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Mata Pelajaran</label>
        <input type="text" name="mata_pelajaran" value="{{ guru.mata_pelajaran if guru else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Jabatan</label>
        <input type="text" name="jabatan" value="{{ guru.jabatan if guru else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Pendidikan</label>
        <input type="text" name="pendidikan" value="{{ guru.pendidikan if guru else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
        <input type="email" name="email" value="{{ guru.email if guru else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Bio</label>
        <textarea name="bio" rows="3" class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">{{ guru.bio if guru else '' }}</textarea>
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Prestasi</label>
        <textarea name="prestasi" rows="3" class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">{{ guru.prestasi if guru else '' }}</textarea>
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Foto</label>
        <input type="file" name="photo" accept="image/*" class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100">
        {% if guru and guru.photo %}<p class="text-xs text-gray-400 mt-1">Biarkan kosong jika tidak ingin mengganti foto</p>{% endif %}
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Urutan</label>
        <input type="number" name="position" value="{{ guru.position if guru else 0 }}" class="w-24 px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div class="flex gap-3 pt-2">
        <button type="submit" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700 transition-all">Simpan</button>
        <a href="{{ url_for('admin.guru_list') }}" class="px-6 py-2.5 rounded-xl font-medium border border-gray-200 hover:bg-gray-50 transition-all">Batal</a>
      </div>
    </form>
  </div>
</div>
{% endblock %}
TMPL

echo "[3/6] Guru templates done"

# Admin Galeri
cat > app/templates/admin/galeri/index.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}Galeri{% endblock %}
{% block page_title %}Manajemen Galeri{% endblock %}
{% block content %}
<div class="flex justify-between items-center mb-5">
  <p class="text-gray-500">{{ galeri_list|length }} media</p>
  <a href="{{ url_for('admin.galeri_tambah') }}" class="bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-blue-700">
    <i class="fas fa-plus mr-1"></i> Tambah Media
  </a>
</div>
<div class="grid grid-cols-2 md:grid-cols-4 gap-4">
  {% for galeri in galeri_list %}
  <div class="card overflow-hidden group">
    <div class="aspect-square relative overflow-hidden">
      <img src="{{ url_for('static', filename='uploads/'+galeri.image) }}" class="w-full h-full object-cover group-hover:scale-105 transition-all duration-300">
      <div class="absolute inset-0 bg-black/0 group-hover:bg-black/40 transition-all flex items-center justify-center gap-2">
        <a href="{{ url_for('admin.galeri_edit', id=galeri.id) }}" class="text-white opacity-0 group-hover:opacity-100 transition-all"><i class="fas fa-edit"></i></a>
        <a href="{{ url_for('admin.galeri_hapus', id=galeri.id) }}" class="text-red-300 opacity-0 group-hover:opacity-100 transition-all" onclick="return confirm('Hapus?')"><i class="fas fa-trash"></i></a>
      </div>
    </div>
    <div class="p-3">
      <p class="text-sm font-medium truncate">{{ galeri.title }}</p>
      <p class="text-xs text-gray-400">{{ galeri.kategori }}</p>
    </div>
  </div>
  {% else %}
  <div class="col-span-4 text-center py-12 text-gray-400">Belum ada media</div>
  {% endfor %}
</div>
{% endblock %}
TMPL

cat > app/templates/admin/galeri/form.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}{% if galeri %}Edit{% else %}Tambah{% endif %} Media{% endblock %}
{% block page_title %}{% if galeri %}Edit Media{% else %}Tambah Media Baru{% endif %}{% endblock %}
{% block content %}
<div class="max-w-2xl animate-fade-in">
  <div class="card p-6">
    <form method="POST" enctype="multipart/form-data" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Judul *</label>
        <input type="text" name="title" value="{{ galeri.title if galeri else '' }}" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Deskripsi</label>
        <textarea name="description" rows="3" class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">{{ galeri.description if galeri else '' }}</textarea>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
          <select name="kategori" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
            <option value="foto" {% if galeri and galeri.kategori=='foto' %}selected{% endif %}>Foto</option>
            <option value="video" {% if galeri and galeri.kategori=='video' %}selected{% endif %}>Video</option>
            <option value="kegiatan" {% if galeri and galeri.kategori=='kegiatan' %}selected{% endif %}>Kegiatan</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">URL Video (jika video)</label>
          <input type="text" name="video_url" value="{{ galeri.video_url if galeri else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Gambar *</label>
        <input type="file" name="image" accept="image/*" class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100">
      </div>
      <div class="flex gap-3 pt-2">
        <button type="submit" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700">Simpan</button>
        <a href="{{ url_for('admin.galeri_list') }}" class="px-6 py-2.5 rounded-xl font-medium border border-gray-200 hover:bg-gray-50">Batal</a>
      </div>
    </form>
  </div>
</div>
{% endblock %}
TMPL

echo "[3/6] Galeri templates done"

# Admin Agenda
cat > app/templates/admin/agenda/index.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}Agenda{% endblock %}
{% block page_title %}Manajemen Agenda{% endblock %}
{% block content %}
<div class="flex justify-between items-center mb-5">
  <p class="text-gray-500">{{ agenda_list|length }} agenda</p>
  <a href="{{ url_for('admin.agenda_tambah') }}" class="bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-blue-700">
    <i class="fas fa-plus mr-1"></i> Tambah Agenda
  </a>
</div>
<div class="card overflow-hidden">
  <div class="overflow-x-auto">
    <table class="w-full text-sm">
      <thead class="bg-gray-50 border-b">
        <tr><th class="text-left p-4 font-medium text-gray-600">Judul</th><th class="text-left p-4 font-medium text-gray-600">Tanggal</th><th class="text-left p-4 font-medium text-gray-600">Lokasi</th><th class="text-left p-4 font-medium text-gray-600">Kategori</th><th class="text-center p-4 font-medium text-gray-600">Aksi</th></tr>
      </thead>
      <tbody>
        {% for a in agenda_list %}
        <tr class="border-b hover:bg-gray-50">
          <td class="p-4 font-medium">{{ a.title }}</td>
          <td class="p-4 text-gray-500">{{ a.start_date.strftime('%d/%m/%Y') }}</td>
          <td class="p-4">{{ a.lokasi or '-' }}</td>
          <td class="p-4"><span class="px-2 py-1 bg-blue-50 text-blue-600 rounded-lg text-xs">{{ a.kategori }}</span></td>
          <td class="p-4 text-center">
            <a href="{{ url_for('admin.agenda_edit', id=a.id) }}" class="text-blue-600 hover:text-blue-800 mr-2"><i class="fas fa-edit"></i></a>
            <a href="{{ url_for('admin.agenda_hapus', id=a.id) }}" class="text-red-500 hover:text-red-700" onclick="return confirm('Hapus agenda?')"><i class="fas fa-trash"></i></a>
          </td>
        </tr>
        {% else %}
        <tr><td colspan="5" class="p-8 text-center text-gray-400">Belum ada agenda</td></tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
</div>
{% endblock %}
TMPL

cat > app/templates/admin/agenda/form.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}{% if agenda %}Edit{% else %}Tambah{% endif %} Agenda{% endblock %}
{% block page_title %}{% if agenda %}Edit Agenda{% else %}Tambah Agenda Baru{% endif %}{% endblock %}
{% block content %}
<div class="max-w-2xl animate-fade-in">
  <div class="card p-6">
    <form method="POST" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Judul *</label>
        <input type="text" name="title" value="{{ agenda.title if agenda else '' }}" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Deskripsi</label>
        <textarea name="description" rows="4" class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 outline-none">{{ agenda.description if agenda else '' }}</textarea>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal Mulai *</label>
          <input type="datetime-local" name="start_date" value="{{ agenda.start_date.strftime('%Y-%m-%dT%H:%M') if agenda else '' }}" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal Selesai</label>
          <input type="datetime-local" name="end_date" value="{{ agenda.end_date.strftime('%Y-%m-%dT%H:%M') if agenda and agenda.end_date else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Lokasi</label>
          <input type="text" name="lokasi" value="{{ agenda.lokasi if agenda else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
          <select name="kategori" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
            <option value="kegiatan">Kegiatan</option>
            <option value="rapat">Rapat</option>
            <option value="libur">Libur</option>
            <option value="ujian">Ujian</option>
            <option value="acara">Acara</option>
          </select>
        </div>
      </div>
      <div class="flex gap-3 pt-2">
        <button type="submit" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700">Simpan</button>
        <a href="{{ url_for('admin.agenda_list') }}" class="px-6 py-2.5 rounded-xl font-medium border border-gray-200 hover:bg-gray-50">Batal</a>
      </div>
    </form>
  </div>
</div>
{% endblock %}
TMPL

echo "[3/6] Agenda templates done"

# Admin Prestasi
cat > app/templates/admin/prestasi/index.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}Prestasi{% endblock %}
{% block page_title %}Manajemen Prestasi{% endblock %}
{% block content %}
<div class="flex justify-between items-center mb-5">
  <p class="text-gray-500">{{ prestasi_list|length }} prestasi</p>
  <a href="{{ url_for('admin.prestasi_tambah') }}" class="bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-blue-700">
    <i class="fas fa-plus mr-1"></i> Tambah Prestasi
  </a>
</div>
<div class="card overflow-hidden">
  <table class="w-full text-sm">
    <thead class="bg-gray-50 border-b">
      <tr><th class="text-left p-4 font-medium text-gray-600">Prestasi</th><th class="text-left p-4 font-medium text-gray-600">Kategori</th><th class="text-left p-4 font-medium text-gray-600">Juara</th><th class="text-left p-4 font-medium text-gray-600">Tingkat</th><th class="text-center p-4 font-medium text-gray-600">Aksi</th></tr>
    </thead>
    <tbody>
      {% for p in prestasi_list %}
      <tr class="border-b hover:bg-gray-50">
        <td class="p-4 font-medium">{{ p.title }}</td>
        <td class="p-4"><span class="px-2 py-1 bg-green-50 text-green-600 rounded-lg text-xs">{{ p.kategori }}</span></td>
        <td class="p-4">{{ p.juara or '-' }}</td>
        <td class="p-4">{{ p.tingkat or '-' }}{% if p.tahun %} ({{ p.tahun }}){% endif %}</td>
        <td class="p-4 text-center">
          <a href="{{ url_for('admin.prestasi_edit', id=p.id) }}" class="text-blue-600 hover:text-blue-800 mr-2"><i class="fas fa-edit"></i></a>
          <a href="{{ url_for('admin.prestasi_hapus', id=p.id) }}" class="text-red-500 hover:text-red-700" onclick="return confirm('Hapus?')"><i class="fas fa-trash"></i></a>
        </td>
      </tr>
      {% else %}
      <tr><td colspan="5" class="p-8 text-center text-gray-400">Belum ada prestasi</td></tr>
      {% endfor %}
    </tbody>
  </table>
</div>
{% endblock %}
TMPL

cat > app/templates/admin/prestasi/form.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}{% if prestasi %}Edit{% else %}Tambah{% endif %} Prestasi{% endblock %}
{% block page_title %}{% if prestasi %}Edit Prestasi{% else %}Tambah Prestasi Baru{% endif %}{% endblock %}
{% block content %}
<div class="max-w-2xl animate-fade-in">
  <div class="card p-6">
    <form method="POST" enctype="multipart/form-data" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Judul Prestasi *</label>
        <input type="text" name="title" value="{{ prestasi.title if prestasi else '' }}" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div class="grid grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
          <select name="kategori" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
            <option value="siswa">Siswa</option>
            <option value="guru">Guru</option>
            <option value="sekolah">Sekolah</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Juara</label>
          <input type="text" name="juara" value="{{ prestasi.juara if prestasi else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Tingkat</label>
          <select name="tingkat" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
            <option value="">Pilih</option>
            <option value="Sekolah">Sekolah</option>
            <option value="Kecamatan">Kecamatan</option>
            <option value="Kabupaten">Kabupaten</option>
            <option value="Provinsi">Provinsi</option>
            <option value="Nasional">Nasional</option>
            <option value="Internasional">Internasional</option>
          </select>
        </div>
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Tahun</label>
        <input type="number" name="tahun" value="{{ prestasi.tahun if prestasi else '' }}" class="w-32 px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Deskripsi</label>
        <textarea name="description" rows="3" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">{{ prestasi.description if prestasi else '' }}</textarea>
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Foto</label>
        <input type="file" name="photo" accept="image/*" class="w-full text-sm">
      </div>
      <div class="flex gap-3 pt-2">
        <button type="submit" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700">Simpan</button>
        <a href="{{ url_for('admin.prestasi_list') }}" class="px-6 py-2.5 rounded-xl font-medium border border-gray-200 hover:bg-gray-50">Batal</a>
      </div>
    </form>
  </div>
</div>
{% endblock %}
TMPL

echo "[3/6] Prestasi templates done"

# Admin Eskul
cat > app/templates/admin/eskul/index.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}Ekstrakurikuler{% endblock %}
{% block page_title %}Manajemen Ekstrakurikuler{% endblock %}
{% block content %}
<div class="flex justify-between items-center mb-5">
  <p class="text-gray-500">{{ eskul_list|length }} eskul</p>
  <a href="{{ url_for('admin.eskul_tambah') }}" class="bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-blue-700">
    <i class="fas fa-plus mr-1"></i> Tambah Eskul
  </a>
</div>
<div class="card overflow-hidden">
  <table class="w-full text-sm">
    <thead class="bg-gray-50 border-b">
      <tr><th class="text-left p-4 font-medium text-gray-600">Nama</th><th class="text-left p-4 font-medium text-gray-600">Pembina</th><th class="text-left p-4 font-medium text-gray-600">Jadwal</th><th class="text-center p-4 font-medium text-gray-600">Aksi</th></tr>
    </thead>
    <tbody>
      {% for e in eskul_list %}
      <tr class="border-b hover:bg-gray-50">
        <td class="p-4 font-medium">{{ e.name }}</td>
        <td class="p-4">{{ e.pembina or '-' }}</td>
        <td class="p-4">{{ e.jadwal or '-' }}</td>
        <td class="p-4 text-center">
          <a href="{{ url_for('admin.eskul_edit', id=e.id) }}" class="text-blue-600 hover:text-blue-800 mr-2"><i class="fas fa-edit"></i></a>
          <a href="{{ url_for('admin.eskul_hapus', id=e.id) }}" class="text-red-500 hover:text-red-700" onclick="return confirm('Hapus?')"><i class="fas fa-trash"></i></a>
        </td>
      </tr>
      {% else %}
      <tr><td colspan="4" class="p-8 text-center text-gray-400">Belum ada eskul</td></tr>
      {% endfor %}
    </tbody>
  </table>
</div>
{% endblock %}
TMPL

cat > app/templates/admin/eskul/form.html << 'TMPL'
{% extends "admin/base.html" %}
{% block title %}{% if eskul %}Edit{% else %}Tambah{% endif %} Ekstrakurikuler{% endblock %}
{% block page_title %}{% if eskul %}Edit Ekstrakurikuler{% else %}Tambah Ekstrakurikuler Baru{% endif %}{% endblock %}
{% block content %}
<div class="max-w-2xl animate-fade-in">
  <div class="card p-6">
    <form method="POST" enctype="multipart/form-data" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Nama Ekstrakurikuler *</label>
        <input type="text" name="name" value="{{ eskul.name if eskul else '' }}" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Pembina</label>
        <input type="text" name="pembina" value="{{ eskul.pembina if eskul else '' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Jadwal</label>
        <input type="text" name="jadwal" value="{{ eskul.jadwal if eskul else '' }}" placeholder="Contoh: Senin & Kamis 15:30-17:00" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Deskripsi</label>
        <textarea name="description" rows="4" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">{{ eskul.description if eskul else '' }}</textarea>
      </div>
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Ikon (Font Awesome)</label>
        <input type="text" name="icon" value="{{ eskul.icon if eskul else 'fas fa-star' }}" class="w-full px-4 py-2.5 rounded-xl border border-gray-200">
      </div>
      <div class="flex gap-3 pt-2">
        <button type="submit" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700">Simpan</button>
        <a href="{{ url_for('admin.eskul_list') }}" class="px-6 py-2.5 rounded-xl font-medium border border-gray-200 hover:bg-gray-50">Batal</a>
      </div>
    </form>
  </div>
</div>
{% endblock %}
TMPL

echo "[3/6] Eskul templates done"

# =============== 4. PUBLIC TEMPLATES ===============
echo "[4/6] Creating public templates..."

mkdir -p app/templates/public

cat > app/templates/public/profil.html << 'TMPL'
{% extends "public/base.html" %}
{% block title %}Profil Sekolah{% endblock %}
{% block content %}
<section class="bg-blue-600 py-16">
  <div class="max-w-7xl mx-auto px-4 text-center">
    <h1 class="text-3xl font-bold text-white mb-3">Profil Sekolah</h1>
    <p class="text-blue-100">Mengenal lebih dekat {{ site_name }}</p>
  </div>
</section>
<section class="py-16">
  <div class="max-w-4xl mx-auto px-4">
    <div class="prose max-w-none">
      <h2 class="text-2xl font-bold mb-4">Sejarah Singkat</h2>
      <p class="text-gray-600 leading-relaxed mb-8">{{ site_name }} berdiri dengan visi mencetak generasi penerus bangsa yang unggul dalam prestasi dan berkarakter mulia. Sekolah kami berkomitmen untuk memberikan pendidikan berkualitas dengan didukung tenaga pengajar profesional dan fasilitas modern.</p>
      <h2 class="text-2xl font-bold mb-4">Visi & Misi</h2>
      <div class="bg-blue-50 rounded-2xl p-6 mb-6">
        <h3 class="font-semibold text-lg mb-2">Visi</h3>
        <p class="text-gray-600">"Terwujudnya generasi yang beriman, bertaqwa, berprestasi, berkarakter mulia, dan berwawasan global."</p>
      </div>
      <div class="bg-green-50 rounded-2xl p-6 mb-8">
        <h3 class="font-semibold text-lg mb-2">Misi</h3>
        <ol class="list-decimal list-inside space-y-2 text-gray-600">
          <li>Menyelenggarakan pendidikan yang berkualitas dan berkarakter</li>
          <li>Mengembangkan potensi siswa secara optimal</li>
          <li>Menciptakan lingkungan belajar yang kondusif dan inovatif</li>
          <li>Menjalin kerjasama dengan orang tua dan masyarakat</li>
        </ol>
      </div>
    </div>
  </div>
</section>
{% endblock %}
TMPL

cat > app/templates/public/guru.html << 'TMPL'
{% extends "public/base.html" %}
{% block title %}Guru & Tenaga Kependidikan{% endblock %}
{% block content %}
<section class="bg-blue-600 py-16">
  <div class="max-w-7xl mx-auto px-4 text-center">
    <h1 class="text-3xl font-bold text-white mb-3">Guru & Tenaga Kependidikan</h1>
    <p class="text-blue-100">Tenaga pengajar profesional dan berdedikasi</p>
  </div>
</section>
<section class="py-16">
  <div class="max-w-7xl mx-auto px-4">
    <div class="grid md:grid-cols-3 lg:grid-cols-4 gap-6">
      {% for guru in guru_list %}
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-lg transition-all">
        <div class="aspect-[3/4] bg-gray-100">
          {% if guru.photo %}
          <img src="{{ url_for('static', filename='uploads/'+guru.photo) }}" class="w-full h-full object-cover">
          {% else %}
          <div class="w-full h-full flex items-center justify-center text-gray-300"><i class="fas fa-user text-6xl"></i></div>
          {% endif %}
        </div>
        <div class="p-4 text-center">
          <h3 class="font-semibold">{{ guru.nama }}</h3>
          <p class="text-sm text-blue-600">{{ guru.mata_pelajaran or 'Guru' }}</p>
          {% if guru.jabatan %}<p class="text-xs text-gray-400 mt-1">{{ guru.jabatan }}</p>{% endif %}
        </div>
      </div>
      {% else %}
      <div class="col-span-full text-center py-12 text-gray-400">Data guru belum tersedia</div>
      {% endfor %}
    </div>
  </div>
</section>
{% endblock %}
TMPL

cat > app/templates/public/galeri.html << 'TMPL'
{% extends "public/base.html" %}
{% block title %}Galeri{% endblock %}
{% block content %}
<section class="bg-blue-600 py-16">
  <div class="max-w-7xl mx-auto px-4 text-center">
    <h1 class="text-3xl font-bold text-white mb-3">Galeri</h1>
    <p class="text-blue-100">Dokumentasi kegiatan dan momen berharga</p>
  </div>
</section>
<section class="py-8">
  <div class="max-w-7xl mx-auto px-4">
    <div class="flex flex-wrap gap-2 mb-8 justify-center">
      <a href="{{ url_for('public.galeri') }}" class="px-4 py-2 rounded-xl text-sm font-medium {% if not selected_kategori %}bg-blue-600 text-white{% else %}bg-gray-100 text-gray-600 hover:bg-gray-200{% endif %}">Semua</a>
      {% for k in kategori_list %}
      <a href="{{ url_for('public.galeri', kategori=k) }}" class="px-4 py-2 rounded-xl text-sm font-medium {% if selected_kategori==k %}bg-blue-600 text-white{% else %}bg-gray-100 text-gray-600 hover:bg-gray-200{% endif %}">{{ k|title }}</a>
      {% endfor %}
    </div>
    <div class="grid md:grid-cols-3 lg:grid-cols-4 gap-4">
      {% for g in galeri_list %}
      <div class="group relative rounded-2xl overflow-hidden aspect-square">
        <img src="{{ url_for('static', filename='uploads/'+g.image) }}" class="w-full h-full object-cover group-hover:scale-105 transition-all duration-500">
        <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-all">
          <div class="absolute bottom-0 p-4 text-white">
            <p class="font-medium">{{ g.title }}</p>
            <p class="text-xs text-white/70">{{ g.kategori }}</p>
          </div>
        </div>
      </div>
      {% else %}
      <div class="col-span-full text-center py-12 text-gray-400">Belum ada galeri</div>
      {% endfor %}
    </div>
  </div>
</section>
{% endblock %}
TMPL

cat > app/templates/public/agenda.html << 'TMPL'
{% extends "public/base.html" %}
{% block title %}Agenda{% endblock %}
{% block content %}
<section class="bg-blue-600 py-16">
  <div class="max-w-7xl mx-auto px-4 text-center">
    <h1 class="text-3xl font-bold text-white mb-3">Agenda Kegiatan</h1>
    <p class="text-blue-100">Jadwal kegiatan dan acara sekolah</p>
  </div>
</section>
<section class="py-16">
  <div class="max-w-4xl mx-auto px-4">
    <div class="space-y-4">
      {% for a in agenda_list %}
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 flex gap-5 items-start hover:shadow-md transition-all">
        <div class="text-center flex-shrink-0 w-16">
          <div class="text-2xl font-bold text-blue-600">{{ a.start_date.strftime('%d') }}</div>
          <div class="text-sm text-gray-500">{{ a.start_date.strftime('%B') }}</div>
        </div>
        <div class="flex-1">
          <h3 class="font-semibold text-lg">{{ a.title }}</h3>
          {% if a.description %}<p class="text-gray-500 text-sm mt-1">{{ a.description[:200] }}</p>{% endif %}
          <div class="flex flex-wrap gap-3 mt-3 text-xs text-gray-400">
            {% if a.lokasi %}<span><i class="fas fa-map-marker-alt mr-1"></i>{{ a.lokasi }}</span>{% endif %}
            <span><i class="fas fa-clock mr-1"></i>{{ a.start_date.strftime('%H:%M') }}</span>
            <span class="px-2 py-1 bg-blue-50 text-blue-600 rounded-lg">{{ a.kategori }}</span>
          </div>
        </div>
      </div>
      {% else %}
      <div class="text-center py-12 text-gray-400">Belum ada agenda mendatang</div>
      {% endfor %}
    </div>
  </div>
</section>
{% endblock %}
TMPL

cat > app/templates/public/prestasi.html << 'TMPL'
{% extends "public/base.html" %}
{% block title %}Prestasi{% endblock %}
{% block content %}
<section class="bg-blue-600 py-16">
  <div class="max-w-7xl mx-auto px-4 text-center">
    <h1 class="text-3xl font-bold text-white mb-3">Prestasi</h1>
    <p class="text-blue-100">Prestasi yang telah diraih siswa, guru, dan sekolah</p>
  </div>
</section>
<section class="py-16">
  <div class="max-w-7xl mx-auto px-4">
    <div class="grid md:grid-cols-3 gap-6">
      {% for p in prestasi_list %}
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-lg transition-all">
        <div class="w-12 h-12 bg-yellow-100 text-yellow-600 rounded-xl flex items-center justify-center mb-4"><i class="fas fa-trophy text-xl"></i></div>
        <h3 class="font-semibold mb-1">{{ p.title }}</h3>
        <p class="text-sm text-gray-500 mb-3">{{ p.description[:150] if p.description else '' }}</p>
        <div class="flex flex-wrap gap-2">
          <span class="px-2 py-1 bg-green-50 text-green-600 rounded-lg text-xs">{{ p.kategori }}</span>
          {% if p.juara %}<span class="px-2 py-1 bg-blue-50 text-blue-600 rounded-lg text-xs">{{ p.juara }}</span>{% endif %}
          {% if p.tingkat %}<span class="px-2 py-1 bg-purple-50 text-purple-600 rounded-lg text-xs">{{ p.tingkat }}</span>{% endif %}
        </div>
      </div>
      {% else %}
      <div class="col-span-full text-center py-12 text-gray-400">Belum ada prestasi</div>
      {% endfor %}
    </div>
  </div>
</section>
{% endblock %}
TMPL

cat > app/templates/public/eskul.html << 'TMPL'
{% extends "public/base.html" %}
{% block title %}Ekstrakurikuler{% endblock %}
{% block content %}
<section class="bg-blue-600 py-16">
  <div class="max-w-7xl mx-auto px-4 text-center">
    <h1 class="text-3xl font-bold text-white mb-3">Ekstrakurikuler</h1>
    <p class="text-blue-100">Wadah pengembangan bakat dan minat siswa</p>
  </div>
</section>
<section class="py-16">
  <div class="max-w-7xl mx-auto px-4">
    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
      {% for e in eskul_list %}
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-lg transition-all">
        <div class="w-12 h-12 bg-blue-100 text-blue-600 rounded-xl flex items-center justify-center mb-4"><i class="{{ e.icon }} text-xl"></i></div>
        <h3 class="font-semibold text-lg mb-2">{{ e.name }}</h3>
        {% if e.description %}<p class="text-gray-500 text-sm mb-4">{{ e.description[:200] }}</p>{% endif %}
        <div class="space-y-2 text-sm text-gray-500">
          {% if e.pembina %}<p><i class="fas fa-user mr-2 text-blue-400"></i>{{ e.pembina }}</p>{% endif %}
          {% if e.jadwal %}<p><i class="fas fa-clock mr-2 text-blue-400"></i>{{ e.jadwal }}</p>{% endif %}
        </div>
      </div>
      {% else %}
      <div class="col-span-full text-center py-12 text-gray-400">Belum ada ekstrakurikuler</div>
      {% endfor %}
    </div>
  </div>
</section>
{% endblock %}
TMPL

echo "[4/6] Public templates done"

# =============== 5. UPDATE SIDEBAR + DASHBOARD ===============
echo "[5/6] Updating sidebar and dashboard..."

# Update admin base sidebar
python3 << 'PYEOF'
with open('app/templates/admin/base.html', 'r') as f:
    content = f.read()

# Enable sidebar links by removing opacity-50 and cursor-not-allowed
sidebar_links = {
    'Berita': ('/admin/berita', 'fa-newspaper'),
    'Pengumuman': ('/admin/pengumuman', 'fa-bullhorn'),
    'Kategori': ('/admin/kategori', 'fa-tags'),
}
for name, (url, icon) in sidebar_links.items():
    old = f'<a href="#" class="sidebar-link text-gray-600 opacity-50 cursor-not-allowed"><i class="fas {icon} w-5 text-center"></i> {name}</a>'
    new = f'<a href="{url}" class="sidebar-link text-gray-600"><i class="fas {icon} w-5 text-center"></i> {name}</a>'
    if old in content:
        content = content.replace(old, new)

# Add new sidebar sections
guru_section = '''                <a href="{{ url_for('admin.guru_list') }}" class="sidebar-link text-gray-600"><i class="fas fa-users w-5 text-center"></i> Guru</a>'''
prestasi_section = '''                <a href="{{ url_for('admin.prestasi_list') }}" class="sidebar-link text-gray-600"><i class="fas fa-trophy w-5 text-center"></i> Prestasi</a>'''
galeri_section = '''                <a href="{{ url_for('admin.galeri_list') }}" class="sidebar-link text-gray-600"><i class="fas fa-images w-5 text-center"></i> Galeri</a>'''
agenda_section = '''                <a href="{{ url_for('admin.agenda_list') }}" class="sidebar-link text-gray-600"><i class="fas fa-calendar w-5 text-center"></i> Agenda</a>'''
eskul_section = '''                <a href="{{ url_for('admin.eskul_list') }}" class="sidebar-link text-gray-600"><i class="fas fa-star w-5 text-center"></i> Ekstrakurikuler</a>'''

# Add after Galeri disabled link
old_galeri = '<a href="#" class="sidebar-link text-gray-600 opacity-50 cursor-not-allowed"><i class="fas fa-images w-5 text-center"></i> Galeri</a>'
content = content.replace(old_galeri, galeri_section)

# Add new links before Pengaturan section
pengaturan_marker = '<p class="text-xs font-semibold text-gray-400 uppercase tracking-wider px-4">Pengaturan</p>'
new_links = f'''{guru_section}
{prestasi_section}
{eskul_section}
{agenda_section}
                <div class="pt-3 pb-1">
                    <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider px-4">Sekolah</p>
                </div>
                <div class="pt-3 pb-1">
                    <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider px-4">Pengaturan</p>'''

# Add before pengaturan section
content = content.replace(
    '<p class="text-xs font-semibold text-gray-400 uppercase tracking-wider px-4">Pengaturan</p>',
    new_links
)

with open('app/templates/admin/base.html', 'w') as f:
    f.write(content)

print("Sidebar updated")
PYEOF

echo "[5/6] Sidebar done"

echo ""
echo "=== FASE 3 SELESAI ==="