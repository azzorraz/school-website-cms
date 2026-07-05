from datetime import datetime
from flask import render_template, request, abort
from app.routes import public_bp
from app.models import Berita, Pengumuman, Kategori, Guru, Galeri, Agenda, Prestasi, Ekstrakurikuler, PPDB, Download, Kontak, Testimoni, Slider, FAQ
from app import db


@public_bp.route('/')
def index():
    berita_terbaru = Berita.query.filter_by(status='published').order_by(
        Berita.published_at.desc()
    ).limit(3).all()

    pengumuman_terbaru = Pengumuman.query.filter_by(status='published').order_by(
        Pengumuman.is_important.desc(),
        Pengumuman.published_at.desc()
    ).limit(5).all()

    berita_populer = Berita.query.filter_by(status='published').order_by(
        Berita.views.desc()
    ).limit(3).all()

    prestasi_terbaru = Prestasi.query.filter_by(is_active=True).order_by(
        Prestasi.tahun.desc(), Prestasi.created_at.desc()
    ).limit(3).all()

    eskul_list = Ekstrakurikuler.query.filter_by(is_active=True).order_by(
        Ekstrakurikuler.position, Ekstrakurikuler.name
    ).limit(6).all()

    galeri_list = Galeri.query.filter_by(is_active=True, kategori='foto').order_by(
        Galeri.created_at.desc()
    ).limit(4).all()

    return render_template('public/index.html',
                         current_time=datetime.now(),
                         berita_terbaru=berita_terbaru,
                         pengumuman_terbaru=pengumuman_terbaru,
                         berita_populer=berita_populer,
                         prestasi_terbaru=prestasi_terbaru,
                         eskul_list=eskul_list,
                         galeri_list=galeri_list)


@public_bp.route('/about')
def about():
    return render_template('public/about.html')


@public_bp.route('/contact')
def contact():
    return render_template('public/contact.html')


@public_bp.route('/berita')
def news():
    page = request.args.get('page', 1, type=int)
    kategori_slug = request.args.get('kategori', '')

    query = Berita.query.filter_by(status='published')

    if kategori_slug:
        kategori = Kategori.query.filter_by(slug=kategori_slug).first()
        if kategori:
            query = query.filter(Berita.kategori_id == kategori.id)

    berita_list = query.order_by(Berita.published_at.desc()).paginate(
        page=page, per_page=9, error_out=False
    )
    kategori_list = Kategori.query.order_by(Kategori.name).all()
    featured_berita = Berita.query.filter_by(status='published', is_featured=True).order_by(
        Berita.published_at.desc()
    ).limit(5).all()

    return render_template('public/berita.html',
                         berita_list=berita_list,
                         kategori_list=kategori_list,
                         featured_berita=featured_berita,
                         kategori_slug=kategori_slug)


@public_bp.route('/berita/<slug>')
def news_detail(slug):
    berita = Berita.query.filter_by(slug=slug).first_or_404()

    if berita.status != 'published':
        abort(404)

    # Increment views
    berita.views = (berita.views or 0) + 1
    from app import db
    db.session.commit()

    # Get related berita (same category)
    related = Berita.query.filter(
        Berita.status == 'published',
        Berita.id != berita.id
    )
    if berita.kategori_id:
        related = related.filter(Berita.kategori_id == berita.kategori_id)
    related = related.order_by(Berita.published_at.desc()).limit(3).all()

    return render_template('public/berita_detail.html',
                         berita=berita,
                         related=related)


@public_bp.route('/pengumuman')
def announcements():
    page = request.args.get('page', 1, type=int)

    pengumuman_list = Pengumuman.query.filter_by(status='published').order_by(
        Pengumuman.is_important.desc(),
        Pengumuman.published_at.desc()
    ).paginate(page=page, per_page=10, error_out=False)

    return render_template('public/pengumuman.html',
                         pengumuman_list=pengumuman_list)


@public_bp.route('/pengumuman/<slug>')
def announcement_detail(slug):
    pengumuman = Pengumuman.query.filter_by(slug=slug).first_or_404()

    if pengumuman.status != 'published':
        abort(404)

    pengumuman.views = (pengumuman.views or 0) + 1
    from app import db
    db.session.commit()

    return render_template('public/berita_detail.html',
                         berita=pengumuman, is_pengumuman=True)


@public_bp.route('/profil')
def profil():
    return render_template('public/profil.html')


@public_bp.route('/guru')
def guru():
    mapel_filter = request.args.get('mapel', '')
    query = Guru.query.filter_by(is_active=True).order_by(Guru.position, Guru.nama)
    if mapel_filter:
        query = query.filter(Guru.mata_pelajaran.ilike(f'%{mapel_filter}%'))
    guru_list = query.all()
    mapel_list = [g.mata_pelajaran for g in Guru.query.filter(Guru.mata_pelajaran.isnot(None), Guru.is_active == True).distinct().all() if g.mata_pelajaran]
    mapel_list = sorted(list(set(mapel_list)))
    return render_template('public/guru.html', guru_list=guru_list, mapel_list=mapel_list, mapel_filter=mapel_filter)


@public_bp.route('/galeri')
def galeri():
    kategori = request.args.get('kategori', '')
    query = Galeri.query.filter_by(is_active=True)
    if kategori:
        query = query.filter(Galeri.kategori == kategori)
    galeri_list = query.order_by(Galeri.created_at.desc()).all()
    return render_template('public/galeri.html', galeri_list=galeri_list, kategori_filter=kategori)


@public_bp.route('/agenda')
def agenda():
    bulan = request.args.get('bulan', '')
    tahun = request.args.get('tahun', '')
    kategori = request.args.get('kategori', '')
    query = Agenda.query.filter_by(is_active=True)
    if kategori:
        query = query.filter(Agenda.kategori == kategori)
    if bulan:
        query = query.filter(db.func.extract('month', Agenda.start_date) == int(bulan))
    if tahun:
        query = query.filter(db.func.extract('year', Agenda.start_date) == int(tahun))
    agenda_list = query.order_by(Agenda.start_date.desc()).all()
    return render_template('public/agenda.html', agenda_list=agenda_list, bulan_filter=bulan, tahun_filter=tahun, kategori_filter=kategori)


@public_bp.route('/prestasi')
def prestasi():
    prestasi_list = Prestasi.query.filter_by(is_active=True).order_by(Prestasi.tahun.desc(), Prestasi.created_at.desc()).all()
    return render_template('public/prestasi.html', prestasi_list=prestasi_list)


@public_bp.route('/ekstrakurikuler')
def eskul():
    eskul_list = Ekstrakurikuler.query.filter_by(is_active=True).order_by(Ekstrakurikuler.position, Ekstrakurikuler.name).all()
    return render_template('public/eskul.html', eskul_list=eskul_list)


# ==================== FASE 4 PUBLIC ROUTES ====================

@public_bp.route('/ppdb', methods=['GET', 'POST'])
def ppdb():
    if request.method == 'POST':
        from datetime import datetime as dt
        ppdb = PPDB(
            nama_lengkap=request.form['nama_lengkap'],
            nama_panggilan=request.form.get('nama_panggilan', ''),
            jenis_kelamin=request.form['jenis_kelamin'],
            tempat_lahir=request.form['tempat_lahir'],
            tanggal_lahir=dt.strptime(request.form['tanggal_lahir'], '%Y-%m-%d').date(),
            agama=request.form.get('agama', ''),
            alamat=request.form['alamat'],
            nama_orangtua=request.form['nama_orangtua'],
            no_hp_orangtua=request.form['no_hp_orangtua'],
            email_orangtua=request.form.get('email_orangtua', ''),
            asal_sekolah=request.form.get('asal_sekolah', '')
        )
        db.session.add(ppdb)
        db.session.commit()
        flash('Pendaftaran berhasil dikirim! Kami akan menghubungi Anda segera.', 'success')
        return redirect(url_for('public.ppdb'))
    return render_template('public/ppdb.html')

@public_bp.route('/download')
def download():
    download_list = Download.query.filter_by(is_active=True).order_by(Download.position).all()
    return render_template('public/download.html', download_list=download_list)

@public_bp.route('/download/<int:id>')
def download_file(id):
    dl = Download.query.get_or_404(id)
    dl.downloads += 1
    db.session.commit()
    return redirect(url_for('static', filename='uploads/' + dl.file))

@public_bp.route('/kontak', methods=['GET', 'POST'])
def kontak():
    if request.method == 'POST':
        k = Kontak(
            nama=request.form['nama'],
            email=request.form['email'],
            no_hp=request.form.get('no_hp', ''),
            subjek=request.form['subjek'],
            pesan=request.form['pesan']
        )
        db.session.add(k)
        db.session.commit()
        flash('Pesan berhasil dikirim! Terima kasih.', 'success')
        return redirect(url_for('public.kontak'))
    return render_template('public/kontak.html')

@public_bp.route('/faq')
def faq():
    faq_list = FAQ.query.filter_by(is_active=True).order_by(FAQ.position).all()
    return render_template('public/faq.html', faq_list=faq_list)


# ==================== FASE 5: SEO & PWA ====================

@public_bp.route('/sitemap.xml')
def sitemap():
    from flask import Response
    berita = Berita.query.filter_by(status='published').order_by(Berita.created_at.desc()).limit(100).all()
    
    xml = '<?xml version="1.0" encoding="UTF-8"?>\n'
    xml += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
    xml += '  <url><loc>' + request.host_url + '</loc><changefreq>daily</changefreq><priority>1.0</priority></url>\n'
    xml += '  <url><loc>' + request.host_url + 'profil</loc><changefreq>monthly</changefreq><priority>0.8</priority></url>\n'
    xml += '  <url><loc>' + request.host_url + 'berita</loc><changefreq>daily</changefreq><priority>0.9</priority></url>\n'
    xml += '  <url><loc>' + request.host_url + 'guru</loc><changefreq>monthly</changefreq><priority>0.7</priority></url>\n'
    xml += '  <url><loc>' + request.host_url + 'galeri</loc><changefreq>weekly</changefreq><priority>0.7</priority></url>\n'
    xml += '  <url><loc>' + request.host_url + 'agenda</loc><changefreq>weekly</changefreq><priority>0.8</priority></url>\n'
    xml += '  <url><loc>' + request.host_url + 'prestasi</loc><changefreq>monthly</changefreq><priority>0.7</priority></url>\n'
    xml += '  <url><loc>' + request.host_url + 'ppdb</loc><changefreq>monthly</changefreq><priority>0.9</priority></url>\n'
    xml += '  <url><loc>' + request.host_url + 'kontak</loc><changefreq>monthly</changefreq><priority>0.6</priority></url>\n'
    xml += '  <url><loc>' + request.host_url + 'faq</loc><changefreq>monthly</changefreq><priority>0.6</priority></url>\n'
    
    for b in berita:
        xml += '  <url><loc>' + request.host_url + 'berita/' + b.slug + '</loc><changefreq>monthly</changefreq><priority>0.6</priority></url>\n'
    
    xml += '</urlset>'
    
    return Response(xml, mimetype='application/xml')

@public_bp.route('/robots.txt')
def robots():
    from flask import Response
    txt = "User-agent: *\nAllow: /\nSitemap: " + request.host_url + "sitemap.xml\n"
    return Response(txt, mimetype='text/plain')

@public_bp.route('/offline')
def offline():
    return render_template('public/offline.html')
