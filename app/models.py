from datetime import datetime
from app import db, login_manager
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash

class User(UserMixin, db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False, index=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    full_name = db.Column(db.String(150), nullable=False)
    photo = db.Column(db.String(255), nullable=True)
    role = db.Column(db.String(20), nullable=False, default='guru')
    is_active = db.Column(db.Boolean, default=True)
    last_login = db.Column(db.DateTime, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def __repr__(self):
        return f'<User {self.username}>'


class Menu(db.Model):
    __tablename__ = 'menus'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    url = db.Column(db.String(255), nullable=True)
    icon = db.Column(db.String(50), nullable=True)
    parent_id = db.Column(db.Integer, db.ForeignKey('menus.id'), nullable=True)
    position = db.Column(db.Integer, default=0)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    children = db.relationship('Menu', backref=db.backref('parent', remote_side=[id]), lazy='dynamic')


class Setting(db.Model):
    __tablename__ = 'settings'

    id = db.Column(db.Integer, primary_key=True)
    key = db.Column(db.String(100), unique=True, nullable=False, index=True)
    value = db.Column(db.Text, nullable=True)
    description = db.Column(db.String(255), nullable=True)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class Visitor(db.Model):
    __tablename__ = 'visitors'

    id = db.Column(db.Integer, primary_key=True)
    ip_address = db.Column(db.String(45), nullable=True)
    user_agent = db.Column(db.String(255), nullable=True)
    page = db.Column(db.String(255), nullable=True)
    visited_at = db.Column(db.DateTime, default=datetime.utcnow)

from slugify import slugify

class Kategori(db.Model):
    __tablename__ = 'kategori'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    slug = db.Column(db.String(100), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if not self.slug and self.name:
            self.slug = slugify(self.name)


class Berita(db.Model):
    __tablename__ = 'berita'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    slug = db.Column(db.String(255), unique=True, nullable=False)
    content = db.Column(db.Text, nullable=False)
    excerpt = db.Column(db.Text, nullable=True)
    featured_image = db.Column(db.String(255), nullable=True)
    status = db.Column(db.String(20), default='draft')  # draft, published
    is_featured = db.Column(db.Boolean, default=False)
    views = db.Column(db.Integer, default=0)
    meta_description = db.Column(db.String(255), nullable=True)
    meta_keywords = db.Column(db.String(255), nullable=True)
    kategori_id = db.Column(db.Integer, db.ForeignKey('kategori.id'), nullable=True)
    author_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    published_at = db.Column(db.DateTime, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    kategori = db.relationship('Kategori', backref='berita')
    author = db.relationship('User', backref='berita')

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if not self.slug and self.title:
            self.slug = slugify(self.title)


class Pengumuman(db.Model):
    __tablename__ = 'pengumuman'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    slug = db.Column(db.String(255), unique=True, nullable=False)
    content = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(20), default='draft')
    is_important = db.Column(db.Boolean, default=False)
    views = db.Column(db.Integer, default=0)
    author_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    published_at = db.Column(db.DateTime, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    author = db.relationship('User', backref='pengumuman')

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if not self.slug and self.title:
            self.slug = slugify(self.title)


class Guru(db.Model):
    __tablename__ = 'guru'
    id = db.Column(db.Integer, primary_key=True)
    nama = db.Column(db.String(150), nullable=False)
    nip = db.Column(db.String(50), unique=True, nullable=True)
    photo = db.Column(db.String(255), nullable=True)
    mata_pelajaran = db.Column(db.String(200), nullable=True)
    pendidikan = db.Column(db.String(200), nullable=True)
    prestasi = db.Column(db.Text, nullable=True)
    jabatan = db.Column(db.String(100), nullable=True)
    bio = db.Column(db.Text, nullable=True)
    email = db.Column(db.String(120), nullable=True)
    is_active = db.Column(db.Boolean, default=True)
    position = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


class Galeri(db.Model):
    __tablename__ = 'galeri'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=True)
    image = db.Column(db.String(255), nullable=False)
    kategori = db.Column(db.String(50), default='foto')  # foto/video
    video_url = db.Column(db.String(500), nullable=True)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


class Agenda(db.Model):
    __tablename__ = 'agenda'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=True)
    lokasi = db.Column(db.String(255), nullable=True)
    start_date = db.Column(db.DateTime, nullable=False)
    end_date = db.Column(db.DateTime, nullable=True)
    kategori = db.Column(db.String(50), default='kegiatan')
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


class Prestasi(db.Model):
    __tablename__ = 'prestasi'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=True)
    kategori = db.Column(db.String(50), default='siswa')  # siswa/guru/sekolah
    juara = db.Column(db.String(50), nullable=True)
    tingkat = db.Column(db.String(50), nullable=True)  # kabupaten/provinsi/nasional
    tahun = db.Column(db.Integer, nullable=True)
    photo = db.Column(db.String(255), nullable=True)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


class Ekstrakurikuler(db.Model):
    __tablename__ = 'ekstrakurikuler'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(150), nullable=False)
    description = db.Column(db.Text, nullable=True)
    pembina = db.Column(db.String(150), nullable=True)
    jadwal = db.Column(db.String(255), nullable=True)
    photo = db.Column(db.String(255), nullable=True)
    icon = db.Column(db.String(50), default='fas fa-star')
    is_active = db.Column(db.Boolean, default=True)
    position = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)



# ==================== FASE 4 MODELS ====================

class PPDB(db.Model):
    __tablename__ = 'ppdb'
    id = db.Column(db.Integer, primary_key=True)
    nama_lengkap = db.Column(db.String(150), nullable=False)
    nama_panggilan = db.Column(db.String(50), nullable=True)
    jenis_kelamin = db.Column(db.String(10), nullable=False)
    tempat_lahir = db.Column(db.String(100), nullable=False)
    tanggal_lahir = db.Column(db.Date, nullable=False)
    agama = db.Column(db.String(20), nullable=True)
    alamat = db.Column(db.Text, nullable=False)
    nama_orangtua = db.Column(db.String(150), nullable=False)
    no_hp_orangtua = db.Column(db.String(20), nullable=False)
    email_orangtua = db.Column(db.String(120), nullable=True)
    asal_sekolah = db.Column(db.String(150), nullable=True)
    nilai_rata = db.Column(db.Float, nullable=True)
    foto = db.Column(db.String(255), nullable=True)
    akta = db.Column(db.String(255), nullable=True)
    kk = db.Column(db.String(255), nullable=True)
    status = db.Column(db.String(20), default='pending')  # pending, diterima, ditolak
    catatan = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Download(db.Model):
    __tablename__ = 'downloads'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=True)
    file = db.Column(db.String(255), nullable=False)
    kategori = db.Column(db.String(50), default='umum')  # umum, formulir, kurikulum, panduan
    downloads = db.Column(db.Integer, default=0)
    is_active = db.Column(db.Boolean, default=True)
    position = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Kontak(db.Model):
    __tablename__ = 'kontak'
    id = db.Column(db.Integer, primary_key=True)
    nama = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    no_hp = db.Column(db.String(20), nullable=True)
    subjek = db.Column(db.String(255), nullable=False)
    pesan = db.Column(db.Text, nullable=False)
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Testimoni(db.Model):
    __tablename__ = 'testimoni'
    id = db.Column(db.Integer, primary_key=True)
    nama = db.Column(db.String(150), nullable=False)
    role = db.Column(db.String(50), default='Orang Tua')  # Orang Tua, Siswa, Alumni
    foto = db.Column(db.String(255), nullable=True)
    isi = db.Column(db.Text, nullable=False)
    rating = db.Column(db.Integer, default=5)
    is_active = db.Column(db.Boolean, default=True)
    position = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Slider(db.Model):
    __tablename__ = 'sliders'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=True)
    subtitle = db.Column(db.String(255), nullable=True)
    image = db.Column(db.String(255), nullable=False)
    url = db.Column(db.String(255), nullable=True)
    is_active = db.Column(db.Boolean, default=True)
    position = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class FAQ(db.Model):
    __tablename__ = 'faq'
    id = db.Column(db.Integer, primary_key=True)
    pertanyaan = db.Column(db.String(500), nullable=False)
    jawaban = db.Column(db.Text, nullable=False)
    kategori = db.Column(db.String(50), default='umum')
    is_active = db.Column(db.Boolean, default=True)
    position = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
