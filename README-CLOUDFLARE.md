# 🌐 Hướng dẫn Setup Cloudflare Pages cho QCVN10

## Bước 1 - Tạo GitHub Repository

1. Vào https://github.com/new
2. Đặt tên: `qcvn10-data` (private hoặc public đều được)
3. Click **Create repository**
4. Upload toàn bộ thư mục `cloudflare-deploy/` vào repo

Hoặc dùng Git:
```bash
cd cloudflare-deploy
git init
git add .
git commit -m "init: QCVN10 data server v1.0.0"
git remote add origin https://github.com/TEN_ANH/qcvn10-data.git
git push -u origin main
```

---

## Bước 2 - Connect Cloudflare Pages

1. Vào https://dash.cloudflare.com → **Pages** → **Create a project**
2. Chọn **Connect to Git**
3. Chọn repo `qcvn10-data`
4. **Build settings**:
   - Framework preset: `None`
   - Build command: *(để trống)*
   - Build output directory: `/`
5. Click **Save and Deploy**

Sau ~1 phút, Cloudflare tạo domain:
```
https://qcvn10-data.pages.dev
```

---

## Bước 3 - Test endpoints

Mở browser kiểm tra:
- https://qcvn10-data.pages.dev/manifest.json
- https://qcvn10-data.pages.dev/bundles/bundle-latest.html

---

## Bước 4 - Cập nhật URL trong APK

Sau khi có domain Cloudflare, rebuild APK với URL đúng:

1. Mở file `/tmp/apk_decoded/AndroidManifest.xml` (hoặc update source)
2. Tìm trong `assets/index.html`:
   ```javascript
   var MANIFEST_URL = "https://qcvn10-data.pages.dev/manifest.json";
   var BUNDLE_URL   = "https://qcvn10-data.pages.dev/bundles/bundle-latest.html";
   ```
3. Đổi `qcvn10-data` thành tên repo thực của anh
4. Rebuild APK (xem BUILD-GUIDE.md)

---

## Quy trình cập nhật sau này

### Khi sửa lỗi tra cứu / thêm rule mới:

```bash
# 1. Sửa index.html trong máy anh
# 2. Chạy script deploy:

cd cloudflare-deploy
./deploy.sh 1.0.1
```

Script sẽ:
- Copy index.html mới → `bundles/bundle-1.0.1.html`
- Copy vào `bundle-latest.html`
- Update `manifest.json` với version mới

```bash
# 3. Push lên GitHub
git add .
git commit -m "fix: sua loi tra cuu nha hang A1-16"
git push
```

Cloudflare Pages tự động redeploy sau ~1 phút.

Lần mở app tiếp theo → app thấy version mới → notification → update.

---

## Version numbering

| Loại thay đổi | Ví dụ | Version |
|---|---|---|
| Fix lỗi tra cứu nhỏ | Sai điều kiện 1 rule | `1.0.0` → `1.0.1` |
| Thêm tính năng mới | Thêm chế độ chuyên gia | `1.0.x` → `1.1.0` |
| QCVN mới ban hành | QCVN 10:2026 mới | `1.x.x` → `2.0.0` |

---

## Troubleshooting

**App không nhận update:**
- Check manifest.json đã được push chưa
- Check URL trong HTML có đúng domain không
- Clear cache: Settings → Apps → QCVN10 → Clear Cache

**Bundle load chậm:**
- bundle-latest.html ~350KB, Cloudflare CDN 3-5s lần đầu
- Sau đó cached bởi browser → nhanh hơn

**App báo lỗi khi mở:**
- APK dùng bundle từ assets (offline) khi CDN không load được
- Kiểm tra network của device
