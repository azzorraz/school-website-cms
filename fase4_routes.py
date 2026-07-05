#!/usr/bin/env python3
"""Fase 4: Add admin routes for PPDB, Download, Kontak, Testimoni, Slider, FAQ"""
import os
import sys

PROJECT = "/home/openclaw/.openclaw/workspace/school-website"
os.chdir(PROJECT)

# Read current admin_routes.py
with open('app/routes/admin_routes.py', 'r') as f:
    content = f.read()

# Check if Fase 4 routes already exist
if 'FASE 4' in content:
    print("Fase 4 routes already exist, skipping...")
    sys.exit(0)

fase4_routes = '''

# ==================== FASE 4: PPDB ====================
@admin_bp.route('/ppdb')
@login_required
def ppdb_index():
    ppdb_list = PPDB.query.order_by(PPDB.created_at.desc()).all()
    return render_template('admin/ppdb/index.html', ppdb_list=ppdb_list)

@admin_bp.route('/ppdb/detail/<int:id>')
@login_required
def ppdb_detail(id):
    ppdb = PPDB.query.get_or_404(id)
    return render_template('admin/ppdb/detail.html', ppdb=ppdb)

@admin_bp.route('/ppdb/status/<int:id>', methods=['POST'])
@login_required
def ppdb_status(id):
    ppdb = PPDB.query.get_or_404(id)
    ppdb.status = request.form['status']
    ppdb.catatan = request.form.get('catatan', '')
    db.session.commit()
    flash('Status PPDB berhasil diupdate!', 'success')
    return redirect(url_for('admin.ppdb_index'))

@admin_bp.route('/ppdb/hapus/<int:id>')
@login_required
def ppdb_hapus(id):
    ppdb = PPDB.query.get_or_404(id)
    db.session.delete(ppdb)
    db.session.commit()
    flash('Data PPDB berhasil dihapus!', 'success')
    return redirect(url_for('admin.ppdb_index'))

# ==================== FASE 4: DOWNLOAD ====================
@admin_bp.route('/download')
@login_required
def download_index():
    download_list = Download.query.order_by(Download.position).all()
    return render_template('admin/download/index.html', download_list=download_list)

@admin_bp.route('/download/tambah', methods=['GET', 'POST'])
@login_required
def download_tambah():
    if request.method == 'POST':
        dl = Download(
            title=request.form['title'],
            description=request.form.get('description', ''),
            kategori=request.form.get('kategori', 'umum'),
            position=int(request.form.get('position', 0))
        )
        if 'file' in request.files:
            f = request.files['file']
            if f and f.filename:
                import uuid
                ext = f.filename.rsplit('.', 1)[1].lower()
                filename = f"dl_{uuid.uuid4().hex}.{ext}"
                f.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                dl.file = filename
        db.session.add(dl)
        db.session.commit()
        flash('File berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.download_index'))
    return render_template('admin/download/form.html', dl=None)

@admin_bp.route('/download/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def download_edit(id):
    dl = Download.query.get_or_404(id)
    if request.method == 'POST':
        dl.title = request.form['title']
        dl.description = request.form.get('description', '')
        dl.kategori = request.form.get('kategori', 'umum')
        dl.position = int(request.form.get('position', 0))
        if 'file' in request.files:
            f = request.files['file']
            if f and f.filename:
                import uuid
                ext = f.filename.rsplit('.', 1)[1].lower()
                filename = f"dl_{uuid.uuid4().hex}.{ext}"
                f.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                dl.file = filename
        db.session.commit()
        flash('File berhasil diupdate!', 'success')
        return redirect(url_for('admin.download_index'))
    return render_template('admin/download/form.html', dl=dl)

@admin_bp.route('/download/hapus/<int:id>')
@login_required
def download_hapus(id):
    dl = Download.query.get_or_404(id)
    db.session.delete(dl)
    db.session.commit()
    flash('File berhasil dihapus!', 'success')
    return redirect(url_for('admin.download_index'))

# ==================== FASE 4: KONTAK ====================
@admin_bp.route('/kontak')
@login_required
def kontak_index():
    kontak_list = Kontak.query.order_by(Kontak.created_at.desc()).all()
    return render_template('admin/kontak/index.html', kontak_list=kontak_list)

@admin_bp.route('/kontak/baca/<int:id>')
@login_required
def kontak_baca(id):
    kontak = Kontak.query.get_or_404(id)
    kontak.is_read = True
    db.session.commit()
    return render_template('admin/kontak/detail.html', kontak=kontak)

@admin_bp.route('/kontak/hapus/<int:id>')
@login_required
def kontak_hapus(id):
    kontak = Kontak.query.get_or_404(id)
    db.session.delete(kontak)
    db.session.commit()
    flash('Pesan berhasil dihapus!', 'success')
    return redirect(url_for('admin.kontak_index'))

# ==================== FASE 4: TESTIMONI ====================
@admin_bp.route('/testimoni')
@login_required
def testimoni_index():
    testimoni_list = Testimoni.query.order_by(Testimoni.position).all()
    return render_template('admin/testimoni/index.html', testimoni_list=testimoni_list)

@admin_bp.route('/testimoni/tambah', methods=['GET', 'POST'])
@login_required
def testimoni_tambah():
    if request.method == 'POST':
        t = Testimoni(
            nama=request.form['nama'],
            role=request.form.get('role', 'Orang Tua'),
            isi=request.form['isi'],
            rating=int(request.form.get('rating', 5)),
            position=int(request.form.get('position', 0))
        )
        if 'foto' in request.files:
            f = request.files['foto']
            if f and f.filename:
                import uuid
                ext = f.filename.rsplit('.', 1)[1].lower()
                filename = f"testi_{uuid.uuid4().hex}.{ext}"
                f.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                t.foto = filename
        db.session.add(t)
        db.session.commit()
        flash('Testimoni berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.testimoni_index'))
    return render_template('admin/testimoni/form.html', t=None)

@admin_bp.route('/testimoni/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def testimoni_edit(id):
    t = Testimoni.query.get_or_404(id)
    if request.method == 'POST':
        t.nama = request.form['nama']
        t.role = request.form.get('role', 'Orang Tua')
        t.isi = request.form['isi']
        t.rating = int(request.form.get('rating', 5))
        t.position = int(request.form.get('position', 0))
        if 'foto' in request.files:
            f = request.files['foto']
            if f and f.filename:
                import uuid
                ext = f.filename.rsplit('.', 1)[1].lower()
                filename = f"testi_{uuid.uuid4().hex}.{ext}"
                f.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                t.foto = filename
        db.session.commit()
        flash('Testimoni berhasil diupdate!', 'success')
        return redirect(url_for('admin.testimoni_index'))
    return render_template('admin/testimoni/form.html', t=t)

@admin_bp.route('/testimoni/hapus/<int:id>')
@login_required
def testimoni_hapus(id):
    t = Testimoni.query.get_or_404(id)
    db.session.delete(t)
    db.session.commit()
    flash('Testimoni berhasil dihapus!', 'success')
    return redirect(url_for('admin.testimoni_index'))

# ==================== FASE 4: SLIDER ====================
@admin_bp.route('/slider')
@login_required
def slider_index():
    slider_list = Slider.query.order_by(Slider.position).all()
    return render_template('admin/slider/index.html', slider_list=slider_list)

@admin_bp.route('/slider/tambah', methods=['GET', 'POST'])
@login_required
def slider_tambah():
    if request.method == 'POST':
        s = Slider(
            title=request.form.get('title', ''),
            subtitle=request.form.get('subtitle', ''),
            url=request.form.get('url', ''),
            position=int(request.form.get('position', 0))
        )
        if 'image' in request.files:
            f = request.files['image']
            if f and f.filename:
                import uuid
                ext = f.filename.rsplit('.', 1)[1].lower()
                filename = f"slider_{uuid.uuid4().hex}.{ext}"
                f.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                s.image = filename
        db.session.add(s)
        db.session.commit()
        flash('Slider berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.slider_index'))
    return render_template('admin/slider/form.html', s=None)

@admin_bp.route('/slider/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def slider_edit(id):
    s = Slider.query.get_or_404(id)
    if request.method == 'POST':
        s.title = request.form.get('title', '')
        s.subtitle = request.form.get('subtitle', '')
        s.url = request.form.get('url', '')
        s.position = int(request.form.get('position', 0))
        if 'image' in request.files:
            f = request.files['image']
            if f and f.filename:
                import uuid
                ext = f.filename.rsplit('.', 1)[1].lower()
                filename = f"slider_{uuid.uuid4().hex}.{ext}"
                f.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
                s.image = filename
        db.session.commit()
        flash('Slider berhasil diupdate!', 'success')
        return redirect(url_for('admin.slider_index'))
    return render_template('admin/slider/form.html', s=s)

@admin_bp.route('/slider/hapus/<int:id>')
@login_required
def slider_hapus(id):
    s = Slider.query.get_or_404(id)
    db.session.delete(s)
    db.session.commit()
    flash('Slider berhasil dihapus!', 'success')
    return redirect(url_for('admin.slider_index'))

# ==================== FASE 4: FAQ ====================
@admin_bp.route('/faq')
@login_required
def faq_index():
    faq_list = FAQ.query.order_by(FAQ.position).all()
    return render_template('admin/faq/index.html', faq_list=faq_list)

@admin_bp.route('/faq/tambah', methods=['GET', 'POST'])
@login_required
def faq_tambah():
    if request.method == 'POST':
        f = FAQ(
            pertanyaan=request.form['pertanyaan'],
            jawaban=request.form['jawaban'],
            kategori=request.form.get('kategori', 'umum'),
            position=int(request.form.get('position', 0))
        )
        db.session.add(f)
        db.session.commit()
        flash('FAQ berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.faq_index'))
    return render_template('admin/faq/form.html', f=None)

@admin_bp.route('/faq/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def faq_edit(id):
    f = FAQ.query.get_or_404(id)
    if request.method == 'POST':
        f.pertanyaan = request.form['pertanyaan']
        f.jawaban = request.form['jawaban']
        f.kategori = request.form.get('kategori', 'umum')
        f.position = int(request.form.get('position', 0))
        db.session.commit()
        flash('FAQ berhasil diupdate!', 'success')
        return redirect(url_for('admin.faq_index'))
    return render_template('admin/faq/form.html', f=f)

@admin_bp.route('/faq/hapus/<int:id>')
@login_required
def faq_hapus(id):
    f = FAQ.query.get_or_404(id)
    db.session.delete(f)
    db.session.commit()
    flash('FAQ berhasil dihapus!', 'success')
    return redirect(url_for('admin.faq_index'))
'''

# Append routes
with open('app/routes/admin_routes.py', 'a') as f:
    f.write(fase4_routes)

print("Admin routes added!")
