#!/bin/bash
# Setup script for School Website CMS - Fase 1
set -e

PROJECT_DIR="/home/openclaw/.openclaw/workspace/school-website"
cd "$PROJECT_DIR"

echo "[1/6] Install Python dependencies..."
pip3 install -r requirements.txt 2>&1 | tail -3

echo "[2/6] Setup MySQL database..."
# Create database and user
sudo mysql -e "CREATE DATABASE IF NOT EXISTS school_cms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || mysql -e "CREATE DATABASE IF NOT EXISTS school_cms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'school_user'@'localhost' IDENTIFIED BY 'SchoolCMS2025!';" 2>/dev/null || true
sudo mysql -e "GRANT ALL PRIVILEGES ON school_cms.* TO 'school_user'@'localhost'; FLUSH PRIVILEGES;" 2>/dev/null || true

echo "[3/6] Create .env file..."
cat > .env << 'ENVEOF'
SECRET_KEY=sk-sc-2025-secret-key-change-in-production
DATABASE_URL=mysql+pymysql://school_user:SchoolCMS2025!@localhost/school_cms
FLASK_ENV=development
FLASK_DEBUG=1
UPLOAD_FOLDER=app/static/uploads
MAX_CONTENT_LENGTH=16777216
ENVEOF

echo "[4/6] Initialize database..."
cd "$PROJECT_DIR"
python3 -c "
from app import create_app, db
app = create_app()
with app.app_context():
    db.create_all()
    print('Database tables created successfully!')
"

echo "[5/6] Create admin user..."
python3 -c "
from app import create_app, db
from app.models import User
from werkzeug.security import generate_password_hash
app = create_app()
with app.app_context():
    if not User.query.filter_by(username='admin').first():
        admin = User(
            username='admin',
            email='admin@sekolah.sch.id',
            password=generate_password_hash('admin123'),
            role='admin',
            full_name='Administrator',
            is_active=True
        )
        db.session.add(admin)
        db.session.commit()
        print('Admin user created! username: admin, password: admin123')
    else:
        print('Admin user already exists')
"

echo "[6/6] Testing app..."
# Quick test that app starts
python3 -c "
from app import create_app
app = create_app()
with app.test_client() as client:
    resp = client.get('/')
    print(f'Home page status: {resp.status_code}')
    resp = client.get('/admin/login')
    print(f'Login page status: {resp.status_code}')
print('Fase 1 complete!')
"

echo ""
echo "============================================"
echo "✅ FASE 1 SELESAI!"
echo "============================================"
echo "Jalankan: cd $PROJECT_DIR && python3 run.py"
echo "Akses: http://localhost:5000"
echo "Admin: http://localhost:5000/admin/login"
echo "Login: admin / admin123"
echo "============================================"
