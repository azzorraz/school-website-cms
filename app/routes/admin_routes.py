from datetime import datetime
from flask import render_template, redirect, url_for, flash, request, abort, jsonify, current_app
from flask_login import login_user, logout_user, login_required, current_user
from slugify import slugify
from app.routes import admin_bp
from app.models import User, Visitor, Kategori, Berita, Pengumuman, Guru, Galeri, Agenda, Prestasi, Ekstrakurikuler, PPDB, Download, Kontak, Testimoni, Slider, FAQ
from app import db
import os
from werkzeug.utils import secure_filename
from flask import current_app, current_app


@admin_bp.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('admin.dashboard'))

    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')
        remember = request.form.get('remember', False)

        user = User.query.filter_by(username=username).first()

        if user and user.check_password(password):
            if not user.is_active:
                flash('Akun dinonaktifkan. Hubungi administrator.', 'error')
                return render_template('admin/login.html')

            login_user(user, remember=remember)
            user.last_login = datetime.utcnow()
            db.session.commit()

            next_page = request.args.get('next')
            return redirect(next_page or url_for('admin.dashboard'))
        else:
            flash('Username atau password salah!', 'error')

    return render_template('admin/login.html')


@admin_bp.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Anda telah logout.', 'info')
    return redirect(url_for('admin.login'))


@admin_bp.route('/dashboard')
@login_required
def dashboard():
    stats = {
        'total_users': User.query.count(),
        'total_visitors': Visitor.query.count(),
        'visitors_today': Visitor.query.filter(
            db.func.date(Visitor.visited_at) == datetime.utcnow().date()
        ).count(),
        'active_users': User.query.filter_by(is_active=True).count(),
        'total_berita': Berita.query.count(),
        'total_pengumuman': Pengumuman.query.count(),
        'berita_draft': Berita.query.filter_by(status='draft').count(),
        'pengumuman_important': Pengumuman.query.filter_by(is_important=True).count(),
        'total_guru': Guru.query.count(),
        'total_galeri': Galeri.query.count(),
        'total_agenda': Agenda.query.count(),
        'total_prestasi': Prestasi.query.count(),
        'total_eskul': Ekstrakurikuler.query.count(),
        'guru_aktif': Guru.query.filter_by(is_active=True).count(),
        'total_ppdb': PPDB.query.count(),
        'ppdb_pending': PPDB.query.filter_by(status='pending').count(),
        'total_download': Download.query.count(),
        'total_kontak': Kontak.query.count(),
        'kontak_unread': Kontak.query.filter_by(is_read=False).count(),
        'total_testimoni': Testimoni.query.count(),
        'total_slider': Slider.query.count(),
        'total_faq': FAQ.query.count(),
    }

    recent_visitors = Visitor.query.order_by(
        Visitor.visited_at.desc()
    ).limit(10).all()

    recent_berita = Berita.query.order_by(Berita.created_at.desc()).limit(5).all()
    recent_pengumuman = Pengumuman.query.order_by(Pengumuman.created_at.desc()).limit(5).all()

    return render_template('admin/dashboard.html',
                         stats=stats,
                         recent_visitors=recent_visitors,
                         recent_berita=recent_berita,
                         recent_pengumuman=recent_pengumuman)


@admin_bp.route('/profile')
@login_required
def profile():
    return render_template('admin/profile.html', user=current_user)


# ─── KATEGORI CRUD ───────────────────────────────────────────

@admin_bp.route('/kategori')
@login_required
def kategori_index():
    kategori_list = Kategori.query.order_by(Kategori.name).all()
    return render_template('admin/kategori/index.html', kategori_list=kategori_list)


@admin_bp.route('/kategori/tambah', methods=['GET', 'POST'])
@login_required
def kategori_tambah():
    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        if not name:
            flash('Nama kategori harus diisi!', 'error')
            return redirect(url_for('admin.kategori_tambah'))

        existing = Kategori.query.filter_by(name=name).first()
        if existing:
            flash('Kategori sudah ada!', 'error')
            return redirect(url_for('admin.kategori_tambah'))

        kategori = Kategori(name=name)
        db.session.add(kategori)
        db.session.commit()
        flash('Kategori berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.kategori_index'))

    return render_template('admin/kategori/index.html', show_form=True)


@admin_bp.route('/kategori/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def kategori_edit(id):
    kategori = Kategori.query.get_or_404(id)
    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        if not name:
            flash('Nama kategori harus diisi!', 'error')
            return redirect(url_for('admin.kategori_edit', id=id))

        existing = Kategori.query.filter(Kategori.name == name, Kategori.id != id).first()
        if existing:
            flash('Nama kategori sudah digunakan!', 'error')
            return redirect(url_for('admin.kategori_edit', id=id))

        kategori.name = name
        kategori.slug = slugify(name)
        db.session.commit()
        flash('Kategori berhasil diperbarui!', 'success')
        return redirect(url_for('admin.kategori_index'))

    return render_template('admin/kategori/index.html', edit_kategori=kategori)


@admin_bp.route('/kategori/hapus/<int:id>', methods=['POST'])
@login_required
def kategori_hapus(id):
    kategori = Kategori.query.get_or_404(id)
    if kategori.berita.count() > 0:
        flash(f'Tidak bisa menghapus kategori "{kategori.name}" karena masih memiliki berita!', 'error')
        return redirect(url_for('admin.kategori_index'))
    db.session.delete(kategori)
    db.session.commit()
    flash('Kategori berhasil dihapus!', 'success')
    return redirect(url_for('admin.kategori_index'))


# ─── BERITA CRUD ─────────────────────────────────────────────

@admin_bp.route('/berita')
@login_required
def berita_index():
    page = request.args.get('page', 1, type=int)
    status_filter = request.args.get('status', '')
    kategori_filter = request.args.get('kategori', 0, type=int)

    query = Berita.query

    if status_filter:
        query = query.filter(Berita.status == status_filter)
    if kategori_filter:
        query = query.filter(Berita.kategori_id == kategori_filter)

    berita_list = query.order_by(Berita.created_at.desc()).paginate(
        page=page, per_page=20, error_out=False
    )
    kategori_list = Kategori.query.order_by(Kategori.name).all()

    return render_template('admin/berita/index.html',
                         berita_list=berita_list,
                         kategori_list=kategori_list,
                         status_filter=status_filter,
                         kategori_filter=kategori_filter)


@admin_bp.route('/berita/tambah', methods=['GET', 'POST'])
@login_required
def berita_tambah():
    kategori_list = Kategori.query.order_by(Kategori.name).all()

    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        content = request.form.get('content', '').strip()
        excerpt = request.form.get('excerpt', '').strip()
        featured_image = request.form.get('featured_image', '').strip()
        status = request.form.get('status', 'draft')
        is_featured = request.form.get('is_featured') == 'on'
        meta_description = request.form.get('meta_description', '').strip()
        meta_keywords = request.form.get('meta_keywords', '').strip()
        kategori_id = request.form.get('kategori_id', type=int)

        if not title:
            flash('Judul berita harus diisi!', 'error')
            return render_template('admin/berita/form.html', kategori_list=kategori_list)

        if not content:
            flash('Konten berita harus diisi!', 'error')
            return render_template('admin/berita/form.html', kategori_list=kategori_list)

        berita = Berita(
            title=title,
            content=content,
            excerpt=excerpt or None,
            featured_image=featured_image or None,
            status=status,
            is_featured=is_featured,
            meta_description=meta_description or None,
            meta_keywords=meta_keywords or None,
            kategori_id=kategori_id or None,
            author_id=current_user.id,
        )

        if status == 'published':
            berita.published_at = datetime.utcnow()

        db.session.add(berita)
        db.session.commit()
        flash('Berita berhasil dibuat!', 'success')
        return redirect(url_for('admin.berita_index'))

    return render_template('admin/berita/form.html', kategori_list=kategori_list)


@admin_bp.route('/berita/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def berita_edit(id):
    berita = Berita.query.get_or_404(id)
    kategori_list = Kategori.query.order_by(Kategori.name).all()

    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        content = request.form.get('content', '').strip()
        excerpt = request.form.get('excerpt', '').strip()
        featured_image = request.form.get('featured_image', '').strip()
        status = request.form.get('status', 'draft')
        is_featured = request.form.get('is_featured') == 'on'
        meta_description = request.form.get('meta_description', '').strip()
        meta_keywords = request.form.get('meta_keywords', '').strip()
        kategori_id = request.form.get('kategori_id', type=int)

        if not title:
            flash('Judul berita harus diisi!', 'error')
            return render_template('admin/berita/form.html', berita=berita, kategori_list=kategori_list)

        if not content:
            flash('Konten berita harus diisi!', 'error')
            return render_template('admin/berita/form.html', berita=berita, kategori_list=kategori_list)

        berita.title = title
        berita.content = content
        berita.excerpt = excerpt or None
        berita.featured_image = featured_image or None
        berita.status = status
        berita.is_featured = is_featured
        berita.meta_description = meta_description or None
        berita.meta_keywords = meta_keywords or None
        berita.kategori_id = kategori_id or None
        berita.updated_at = datetime.utcnow()

        if status == 'published' and not berita.published_at:
            berita.published_at = datetime.utcnow()
        elif status == 'draft':
            berita.published_at = None

        # Regenerate slug
        berita.slug = slugify(berita.title)

        db.session.commit()
        flash('Berita berhasil diperbarui!', 'success')
        return redirect(url_for('admin.berita_index'))

    return render_template('admin/berita/form.html', berita=berita, kategori_list=kategori_list)


@admin_bp.route('/berita/hapus/<int:id>', methods=['POST'])
@login_required
def berita_hapus(id):
    berita = Berita.query.get_or_404(id)
    db.session.delete(berita)
    db.session.commit()
    flash('Berita berhasil dihapus!', 'success')
    return redirect(url_for('admin.berita_index'))


@admin_bp.route('/berita/toggle-featured/<int:id>', methods=['POST'])
@login_required
def berita_toggle_featured(id):
    berita = Berita.query.get_or_404(id)
    berita.is_featured = not berita.is_featured
    db.session.commit()
    flash(f'Berita {"diunggulkan" if berita.is_featured else "tidak diunggulkan"}!', 'success')
    return redirect(url_for('admin.berita_index'))


@admin_bp.route('/berita/preview/<int:id>')
@login_required
def berita_preview(id):
    berita = Berita.query.get_or_404(id)
    return render_template('public/berita_detail.html', berita=berita, preview=True)


# ─── PENGUMUMAN CRUD ─────────────────────────────────────────

@admin_bp.route('/pengumuman')
@login_required
def pengumuman_index():
    page = request.args.get('page', 1, type=int)
    status_filter = request.args.get('status', '')
    query = Pengumuman.query

    if status_filter:
        query = query.filter(Pengumuman.status == status_filter)

    pengumuman_list = query.order_by(
        Pengumuman.is_important.desc(),
        Pengumuman.created_at.desc()
    ).paginate(page=page, per_page=20, error_out=False)

    return render_template('admin/pengumuman/index.html',
                         pengumuman_list=pengumuman_list,
                         status_filter=status_filter)


@admin_bp.route('/pengumuman/tambah', methods=['GET', 'POST'])
@login_required
def pengumuman_tambah():
    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        content = request.form.get('content', '').strip()
        status = request.form.get('status', 'draft')
        is_important = request.form.get('is_important') == 'on'

        if not title:
            flash('Judul pengumuman harus diisi!', 'error')
            return render_template('admin/pengumuman/form.html')

        if not content:
            flash('Konten pengumuman harus diisi!', 'error')
            return render_template('admin/pengumuman/form.html')

        pengumuman = Pengumuman(
            title=title,
            content=content,
            status=status,
            is_important=is_important,
            author_id=current_user.id,
        )

        if status == 'published':
            pengumuman.published_at = datetime.utcnow()

        db.session.add(pengumuman)
        db.session.commit()
        flash('Pengumuman berhasil dibuat!', 'success')
        return redirect(url_for('admin.pengumuman_index'))

    return render_template('admin/pengumuman/form.html')


@admin_bp.route('/pengumuman/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def pengumuman_edit(id):
    pengumuman = Pengumuman.query.get_or_404(id)

    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        content = request.form.get('content', '').strip()
        status = request.form.get('status', 'draft')
        is_important = request.form.get('is_important') == 'on'

        if not title:
            flash('Judul pengumuman harus diisi!', 'error')
            return render_template('admin/pengumuman/form.html', pengumuman=pengumuman)

        if not content:
            flash('Konten pengumuman harus diisi!', 'error')
            return render_template('admin/pengumuman/form.html', pengumuman=pengumuman)

        pengumuman.title = title
        pengumuman.content = content
        pengumuman.status = status
        pengumuman.is_important = is_important
        pengumuman.updated_at = datetime.utcnow()

        if status == 'published' and not pengumuman.published_at:
            pengumuman.published_at = datetime.utcnow()
        elif status == 'draft':
            pengumuman.published_at = None

        db.session.commit()
        flash('Pengumuman berhasil diperbarui!', 'success')
        return redirect(url_for('admin.pengumuman_index'))

    return render_template('admin/pengumuman/form.html', pengumuman=pengumuman)


@admin_bp.route('/pengumuman/hapus/<int:id>', methods=['POST'])
@login_required
def pengumuman_hapus(id):
    pengumuman = Pengumuman.query.get_or_404(id)
    db.session.delete(pengumuman)
    db.session.commit()
    flash('Pengumuman berhasil dihapus!', 'success')
    return redirect(url_for('admin.pengumuman_index'))


# ─── GURU CRUD ───────────────────────────────────────────────

@admin_bp.route('/guru')
@login_required
def guru_index():
    guru_list = Guru.query.order_by(Guru.position, Guru.nama).all()
    return render_template('admin/guru/index.html', guru_list=guru_list)


@admin_bp.route('/guru/tambah', methods=['GET', 'POST'])
@login_required
def guru_tambah():
    if request.method == 'POST':
        nama = request.form.get('nama', '').strip()
        nip = request.form.get('nip', '').strip() or None
        mata_pelajaran = request.form.get('mata_pelajaran', '').strip() or None
        pendidikan = request.form.get('pendidikan', '').strip() or None
        prestasi = request.form.get('prestasi', '').strip() or None
        jabatan = request.form.get('jabatan', '').strip() or None
        bio = request.form.get('bio', '').strip() or None
        email = request.form.get('email', '').strip() or None
        position = request.form.get('position', 0, type=int)

        if not nama:
            flash('Nama guru harus diisi!', 'error')
            return render_template('admin/guru/form.html')

        photo = None
        if request.files.get('photo'):
            file = request.files['photo']
            if file.filename:
                filename = secure_filename(file.filename)
                ext = filename.rsplit('.', 1)[1].lower() if '.' in filename else ''
                if ext in {'jpg', 'jpeg', 'png', 'gif', 'webp'}:
                    import uuid
                    new_filename = f"guru_{uuid.uuid4().hex[:8]}.{ext}"
                    upload_dir = current_app.config.get('UPLOAD_FOLDER', 'app/static/uploads')
                    file.save(os.path.join(upload_dir, new_filename))
                    photo = f'/static/uploads/{new_filename}'
                else:
                    flash('Format foto tidak didukung! (jpg, jpeg, png, gif, webp)', 'error')
                    return render_template('admin/guru/form.html')

        guru = Guru(
            nama=nama,
            nip=nip,
            photo=photo,
            mata_pelajaran=mata_pelajaran,
            pendidikan=pendidikan,
            prestasi=prestasi,
            jabatan=jabatan,
            bio=bio,
            email=email,
            position=position
        )
        db.session.add(guru)
        db.session.commit()
        flash('Guru berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.guru_index'))

    return render_template('admin/guru/form.html')


@admin_bp.route('/guru/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def guru_edit(id):
    guru = Guru.query.get_or_404(id)

    if request.method == 'POST':
        nama = request.form.get('nama', '').strip()
        nip = request.form.get('nip', '').strip() or None
        mata_pelajaran = request.form.get('mata_pelajaran', '').strip() or None
        pendidikan = request.form.get('pendidikan', '').strip() or None
        prestasi = request.form.get('prestasi', '').strip() or None
        jabatan = request.form.get('jabatan', '').strip() or None
        bio = request.form.get('bio', '').strip() or None
        email = request.form.get('email', '').strip() or None
        position = request.form.get('position', 0, type=int)
        is_active = request.form.get('is_active') == 'on'

        if not nama:
            flash('Nama guru harus diisi!', 'error')
            return render_template('admin/guru/form.html', guru=guru)

        if request.files.get('photo'):
            file = request.files['photo']
            if file.filename:
                filename = secure_filename(file.filename)
                ext = filename.rsplit('.', 1)[1].lower() if '.' in filename else ''
                if ext in {'jpg', 'jpeg', 'png', 'gif', 'webp'}:
                    import uuid
                    new_filename = f"guru_{uuid.uuid4().hex[:8]}.{ext}"
                    upload_dir = current_app.config.get('UPLOAD_FOLDER', 'app/static/uploads')
                    file.save(os.path.join(upload_dir, new_filename))
                    guru.photo = f'/static/uploads/{new_filename}'
                else:
                    flash('Format foto tidak didukung!', 'error')
                    return render_template('admin/guru/form.html', guru=guru)

        guru.nama = nama
        guru.nip = nip
        guru.mata_pelajaran = mata_pelajaran
        guru.pendidikan = pendidikan
        guru.prestasi = prestasi
        guru.jabatan = jabatan
        guru.bio = bio
        guru.email = email
        guru.position = position
        guru.is_active = is_active
        db.session.commit()
        flash('Guru berhasil diperbarui!', 'success')
        return redirect(url_for('admin.guru_index'))

    return render_template('admin/guru/form.html', guru=guru)


@admin_bp.route('/guru/hapus/<int:id>', methods=['POST'])
@login_required
def guru_hapus(id):
    guru = Guru.query.get_or_404(id)
    db.session.delete(guru)
    db.session.commit()
    flash('Guru berhasil dihapus!', 'success')
    return redirect(url_for('admin.guru_index'))


# ─── GALERI CRUD ─────────────────────────────────────────────

@admin_bp.route('/galeri')
@login_required
def galeri_index():
    galeri_list = Galeri.query.order_by(Galeri.created_at.desc()).all()
    return render_template('admin/galeri/index.html', galeri_list=galeri_list)


@admin_bp.route('/galeri/tambah', methods=['GET', 'POST'])
@login_required
def galeri_tambah():
    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        description = request.form.get('description', '').strip() or None
        kategori = request.form.get('kategori', 'foto')
        video_url = request.form.get('video_url', '').strip() or None

        if not title:
            flash('Judul harus diisi!', 'error')
            return render_template('admin/galeri/form.html')

        image = None
        if request.files.get('image'):
            file = request.files['image']
            if file.filename:
                filename = secure_filename(file.filename)
                ext = filename.rsplit('.', 1)[1].lower() if '.' in filename else ''
                if ext in {'jpg', 'jpeg', 'png', 'gif', 'webp'}:
                    import uuid
                    new_filename = f"galeri_{uuid.uuid4().hex[:8]}.{ext}"
                    upload_dir = current_app.config.get('UPLOAD_FOLDER', 'app/static/uploads')
                    file.save(os.path.join(upload_dir, new_filename))
                    image = f'/static/uploads/{new_filename}'
                else:
                    flash('Format gambar tidak didukung!', 'error')
                    return render_template('admin/galeri/form.html')

        if not image and kategori == 'foto':
            flash('Gambar harus diupload untuk kategori foto!', 'error')
            return render_template('admin/galeri/form.html')

        galeri = Galeri(
            title=title,
            description=description,
            image=image or '',
            kategori=kategori,
            video_url=video_url if kategori == 'video' else None
        )
        db.session.add(galeri)
        db.session.commit()
        flash('Galeri berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.galeri_index'))

    return render_template('admin/galeri/form.html')


@admin_bp.route('/galeri/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def galeri_edit(id):
    galeri = Galeri.query.get_or_404(id)

    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        description = request.form.get('description', '').strip() or None
        kategori = request.form.get('kategori', 'foto')
        video_url = request.form.get('video_url', '').strip() or None
        is_active = request.form.get('is_active') == 'on'

        if not title:
            flash('Judul harus diisi!', 'error')
            return render_template('admin/galeri/form.html', galeri=galeri)

        if request.files.get('image'):
            file = request.files['image']
            if file.filename:
                filename = secure_filename(file.filename)
                ext = filename.rsplit('.', 1)[1].lower() if '.' in filename else ''
                if ext in {'jpg', 'jpeg', 'png', 'gif', 'webp'}:
                    import uuid
                    new_filename = f"galeri_{uuid.uuid4().hex[:8]}.{ext}"
                    upload_dir = current_app.config.get('UPLOAD_FOLDER', 'app/static/uploads')
                    file.save(os.path.join(upload_dir, new_filename))
                    galeri.image = f'/static/uploads/{new_filename}'
                else:
                    flash('Format gambar tidak didukung!', 'error')
                    return render_template('admin/galeri/form.html', galeri=galeri)

        galeri.title = title
        galeri.description = description
        galeri.kategori = kategori
        galeri.video_url = video_url if kategori == 'video' else None
        galeri.is_active = is_active
        db.session.commit()
        flash('Galeri berhasil diperbarui!', 'success')
        return redirect(url_for('admin.galeri_index'))

    return render_template('admin/galeri/form.html', galeri=galeri)


@admin_bp.route('/galeri/hapus/<int:id>', methods=['POST'])
@login_required
def galeri_hapus(id):
    galeri = Galeri.query.get_or_404(id)
    db.session.delete(galeri)
    db.session.commit()
    flash('Galeri berhasil dihapus!', 'success')
    return redirect(url_for('admin.galeri_index'))


# ─── AGENDA CRUD ─────────────────────────────────────────────

@admin_bp.route('/agenda')
@login_required
def agenda_index():
    agenda_list = Agenda.query.order_by(Agenda.start_date.desc()).all()
    return render_template('admin/agenda/index.html', agenda_list=agenda_list)


@admin_bp.route('/agenda/tambah', methods=['GET', 'POST'])
@login_required
def agenda_tambah():
    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        description = request.form.get('description', '').strip() or None
        lokasi = request.form.get('lokasi', '').strip() or None
        start_date_str = request.form.get('start_date', '')
        end_date_str = request.form.get('end_date', '') or None
        kategori = request.form.get('kategori', 'kegiatan')

        if not title:
            flash('Judul agenda harus diisi!', 'error')
            return render_template('admin/agenda/form.html')

        if not start_date_str:
            flash('Tanggal mulai harus diisi!', 'error')
            return render_template('admin/agenda/form.html')

        try:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%dT%H:%M')
        except ValueError:
            try:
                start_date = datetime.strptime(start_date_str, '%Y-%m-%d')
            except ValueError:
                flash('Format tanggal tidak valid!', 'error')
                return render_template('admin/agenda/form.html')

        end_date = None
        if end_date_str:
            try:
                end_date = datetime.strptime(end_date_str, '%Y-%m-%dT%H:%M')
            except ValueError:
                try:
                    end_date = datetime.strptime(end_date_str, '%Y-%m-%d')
                except ValueError:
                    pass

        agenda = Agenda(
            title=title,
            description=description,
            lokasi=lokasi,
            start_date=start_date,
            end_date=end_date,
            kategori=kategori
        )
        db.session.add(agenda)
        db.session.commit()
        flash('Agenda berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.agenda_index'))

    return render_template('admin/agenda/form.html')


@admin_bp.route('/agenda/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def agenda_edit(id):
    agenda = Agenda.query.get_or_404(id)

    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        description = request.form.get('description', '').strip() or None
        lokasi = request.form.get('lokasi', '').strip() or None
        start_date_str = request.form.get('start_date', '')
        end_date_str = request.form.get('end_date', '') or None
        kategori = request.form.get('kategori', 'kegiatan')
        is_active = request.form.get('is_active') == 'on'

        if not title:
            flash('Judul agenda harus diisi!', 'error')
            return render_template('admin/agenda/form.html', agenda=agenda)

        if not start_date_str:
            flash('Tanggal mulai harus diisi!', 'error')
            return render_template('admin/agenda/form.html', agenda=agenda)

        try:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%dT%H:%M')
        except ValueError:
            try:
                start_date = datetime.strptime(start_date_str, '%Y-%m-%d')
            except ValueError:
                flash('Format tanggal tidak valid!', 'error')
                return render_template('admin/agenda/form.html', agenda=agenda)

        end_date = None
        if end_date_str:
            try:
                end_date = datetime.strptime(end_date_str, '%Y-%m-%dT%H:%M')
            except ValueError:
                try:
                    end_date = datetime.strptime(end_date_str, '%Y-%m-%d')
                except ValueError:
                    pass

        agenda.title = title
        agenda.description = description
        agenda.lokasi = lokasi
        agenda.start_date = start_date
        agenda.end_date = end_date
        agenda.kategori = kategori
        agenda.is_active = is_active
        db.session.commit()
        flash('Agenda berhasil diperbarui!', 'success')
        return redirect(url_for('admin.agenda_index'))

    return render_template('admin/agenda/form.html', agenda=agenda)


@admin_bp.route('/agenda/hapus/<int:id>', methods=['POST'])
@login_required
def agenda_hapus(id):
    agenda = Agenda.query.get_or_404(id)
    db.session.delete(agenda)
    db.session.commit()
    flash('Agenda berhasil dihapus!', 'success')
    return redirect(url_for('admin.agenda_index'))


# ─── PRESTASI CRUD ───────────────────────────────────────────

@admin_bp.route('/prestasi')
@login_required
def prestasi_index():
    prestasi_list = Prestasi.query.order_by(Prestasi.tahun.desc(), Prestasi.created_at.desc()).all()
    return render_template('admin/prestasi/index.html', prestasi_list=prestasi_list)


@admin_bp.route('/prestasi/tambah', methods=['GET', 'POST'])
@login_required
def prestasi_tambah():
    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        description = request.form.get('description', '').strip() or None
        kategori = request.form.get('kategori', 'siswa')
        juara = request.form.get('juara', '').strip() or None
        tingkat = request.form.get('tingkat', '').strip() or None
        tahun = request.form.get('tahun', type=int) or None

        if not title:
            flash('Judul prestasi harus diisi!', 'error')
            return render_template('admin/prestasi/form.html')

        photo = None
        if request.files.get('photo'):
            file = request.files['photo']
            if file.filename:
                filename = secure_filename(file.filename)
                ext = filename.rsplit('.', 1)[1].lower() if '.' in filename else ''
                if ext in {'jpg', 'jpeg', 'png', 'gif', 'webp'}:
                    import uuid
                    new_filename = f"prestasi_{uuid.uuid4().hex[:8]}.{ext}"
                    upload_dir = current_app.config.get('UPLOAD_FOLDER', 'app/static/uploads')
                    file.save(os.path.join(upload_dir, new_filename))
                    photo = f'/static/uploads/{new_filename}'
                else:
                    flash('Format foto tidak didukung!', 'error')
                    return render_template('admin/prestasi/form.html')

        prestasi = Prestasi(
            title=title,
            description=description,
            kategori=kategori,
            juara=juara,
            tingkat=tingkat,
            tahun=tahun,
            photo=photo
        )
        db.session.add(prestasi)
        db.session.commit()
        flash('Prestasi berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.prestasi_index'))

    return render_template('admin/prestasi/form.html')


@admin_bp.route('/prestasi/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def prestasi_edit(id):
    prestasi = Prestasi.query.get_or_404(id)

    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        description = request.form.get('description', '').strip() or None
        kategori = request.form.get('kategori', 'siswa')
        juara = request.form.get('juara', '').strip() or None
        tingkat = request.form.get('tingkat', '').strip() or None
        tahun = request.form.get('tahun', type=int) or None
        is_active = request.form.get('is_active') == 'on'

        if not title:
            flash('Judul prestasi harus diisi!', 'error')
            return render_template('admin/prestasi/form.html', prestasi=prestasi)

        if request.files.get('photo'):
            file = request.files['photo']
            if file.filename:
                filename = secure_filename(file.filename)
                ext = filename.rsplit('.', 1)[1].lower() if '.' in filename else ''
                if ext in {'jpg', 'jpeg', 'png', 'gif', 'webp'}:
                    import uuid
                    new_filename = f"prestasi_{uuid.uuid4().hex[:8]}.{ext}"
                    upload_dir = current_app.config.get('UPLOAD_FOLDER', 'app/static/uploads')
                    file.save(os.path.join(upload_dir, new_filename))
                    prestasi.photo = f'/static/uploads/{new_filename}'
                else:
                    flash('Format foto tidak didukung!', 'error')
                    return render_template('admin/prestasi/form.html', prestasi=prestasi)

        prestasi.title = title
        prestasi.description = description
        prestasi.kategori = kategori
        prestasi.juara = juara
        prestasi.tingkat = tingkat
        prestasi.tahun = tahun
        prestasi.is_active = is_active
        db.session.commit()
        flash('Prestasi berhasil diperbarui!', 'success')
        return redirect(url_for('admin.prestasi_index'))

    return render_template('admin/prestasi/form.html', prestasi=prestasi)


@admin_bp.route('/prestasi/hapus/<int:id>', methods=['POST'])
@login_required
def prestasi_hapus(id):
    prestasi = Prestasi.query.get_or_404(id)
    db.session.delete(prestasi)
    db.session.commit()
    flash('Prestasi berhasil dihapus!', 'success')
    return redirect(url_for('admin.prestasi_index'))


# ─── EKSTRAKURIKULER CRUD ────────────────────────────────────

@admin_bp.route('/eskul')
@login_required
def eskul_index():
    eskul_list = Ekstrakurikuler.query.order_by(Ekstrakurikuler.position, Ekstrakurikuler.name).all()
    return render_template('admin/eskul/index.html', eskul_list=eskul_list)


@admin_bp.route('/eskul/tambah', methods=['GET', 'POST'])
@login_required
def eskul_tambah():
    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        description = request.form.get('description', '').strip() or None
        pembina = request.form.get('pembina', '').strip() or None
        jadwal = request.form.get('jadwal', '').strip() or None
        icon = request.form.get('icon', 'fas fa-star')
        position = request.form.get('position', 0, type=int)

        if not name:
            flash('Nama ekstrakurikuler harus diisi!', 'error')
            return render_template('admin/eskul/form.html')

        photo = None
        if request.files.get('photo'):
            file = request.files['photo']
            if file.filename:
                filename = secure_filename(file.filename)
                ext = filename.rsplit('.', 1)[1].lower() if '.' in filename else ''
                if ext in {'jpg', 'jpeg', 'png', 'gif', 'webp'}:
                    import uuid
                    new_filename = f"eskul_{uuid.uuid4().hex[:8]}.{ext}"
                    upload_dir = current_app.config.get('UPLOAD_FOLDER', 'app/static/uploads')
                    file.save(os.path.join(upload_dir, new_filename))
                    photo = f'/static/uploads/{new_filename}'

        eskul = Ekstrakurikuler(
            name=name,
            description=description,
            pembina=pembina,
            jadwal=jadwal,
            photo=photo,
            icon=icon,
            position=position
        )
        db.session.add(eskul)
        db.session.commit()
        flash('Ekstrakurikuler berhasil ditambahkan!', 'success')
        return redirect(url_for('admin.eskul_index'))

    return render_template('admin/eskul/form.html')


@admin_bp.route('/eskul/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def eskul_edit(id):
    eskul = Ekstrakurikuler.query.get_or_404(id)

    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        description = request.form.get('description', '').strip() or None
        pembina = request.form.get('pembina', '').strip() or None
        jadwal = request.form.get('jadwal', '').strip() or None
        icon = request.form.get('icon', 'fas fa-star')
        position = request.form.get('position', 0, type=int)
        is_active = request.form.get('is_active') == 'on'

        if not name:
            flash('Nama ekstrakurikuler harus diisi!', 'error')
            return render_template('admin/eskul/form.html', eskul=eskul)

        if request.files.get('photo'):
            file = request.files['photo']
            if file.filename:
                filename = secure_filename(file.filename)
                ext = filename.rsplit('.', 1)[1].lower() if '.' in filename else ''
                if ext in {'jpg', 'jpeg', 'png', 'gif', 'webp'}:
                    import uuid
                    new_filename = f"eskul_{uuid.uuid4().hex[:8]}.{ext}"
                    upload_dir = current_app.config.get('UPLOAD_FOLDER', 'app/static/uploads')
                    file.save(os.path.join(upload_dir, new_filename))
                    eskul.photo = f'/static/uploads/{new_filename}'

        eskul.name = name
        eskul.description = description
        eskul.pembina = pembina
        eskul.jadwal = jadwal
        eskul.icon = icon
        eskul.position = position
        eskul.is_active = is_active
        db.session.commit()
        flash('Ekstrakurikuler berhasil diperbarui!', 'success')
        return redirect(url_for('admin.eskul_index'))

    return render_template('admin/eskul/form.html', eskul=eskul)


@admin_bp.route('/eskul/hapus/<int:id>', methods=['POST'])
@login_required
def eskul_hapus(id):
    eskul = Ekstrakurikuler.query.get_or_404(id)
    db.session.delete(eskul)
    db.session.commit()
    flash('Ekstrakurikuler berhasil dihapus!', 'success')
    return redirect(url_for('admin.eskul_index'))

from datetime import datetime


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
