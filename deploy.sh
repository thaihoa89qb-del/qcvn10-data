#!/bin/bash
# =========================================================
# deploy.sh - Đóng gói bundle mới và deploy lên Cloudflare
# Dùng: ./deploy.sh <version> [changelog]
# Ví dụ: ./deploy.sh 1.0.1 "Fix lỗi tra cứu nhà hàng A1-16"
#         ./deploy.sh 1.1.0 "Thêm chế độ chuyên gia tính bơm"
# =========================================================
set -e

VERSION="${1}"
CHANGELOG="${2:-Cập nhật v${1}}"
DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_HTML=""

# Tìm source index.html
for p in "$DIR/../index.html" "$DIR/../../index.html" "$DIR/../assets/bundle/index.html"; do
  if [ -f "$p" ]; then
    SRC_HTML="$(realpath "$p")"
    break
  fi
done

if [ -z "$VERSION" ]; then
  echo "❌ Cần cung cấp version. Ví dụ: ./deploy.sh 1.0.1"
  exit 1
fi

if [ -z "$SRC_HTML" ]; then
  echo "❌ Không tìm thấy index.html source"
  echo "   Đặt index.html cạnh thư mục cloudflare-deploy/"
  exit 1
fi

echo "═══════════════════════════════════════"
echo " QCVN10 Deploy v${VERSION}"
echo "═══════════════════════════════════════"
echo " Source: $SRC_HTML ($(wc -c < "$SRC_HTML" | tr -d ' ') bytes)"
echo " Version: $VERSION"
echo " Changelog: $CHANGELOG"
echo ""

# Tạo bundle file có version
mkdir -p "$DIR/bundles"
BUNDLE="$DIR/bundles/bundle-${VERSION}.html"
cp "$SRC_HTML" "$BUNDLE"

# Update bundle-latest.html
cp "$SRC_HTML" "$DIR/bundles/bundle-latest.html"
echo "✅ Bundle → bundles/bundle-${VERSION}.html"
echo "✅ Latest → bundles/bundle-latest.html"

# Update manifest.json
DATE=$(date +%Y-%m-%d)
cat > "$DIR/manifest.json" << MANIFEST
{
  "version": "${VERSION}",
  "bundleUrl": "https://qcvn10-data.pages.dev/bundles/bundle-latest.html",
  "changelog": "v${VERSION} (${DATE})\n${CHANGELOG}",
  "minApp": 1,
  "releaseDate": "${DATE}"
}
MANIFEST
echo "✅ manifest.json updated"

# Git commit & push (nếu có git)
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
  cd "$DIR"
  git add -A
  git commit -m "release: bundle v${VERSION} - ${CHANGELOG}"
  git push
  echo ""
  echo "✅ GitHub pushed"
  echo "🌐 Cloudflare Pages đang deploy..."
  echo "   URL: https://qcvn10-data.pages.dev"
  echo "   (~1 phút để active)"
else
  echo ""
  echo "⚠️  Chưa init git. Chạy thủ công:"
  echo "   git add . && git commit -m 'release: v${VERSION}' && git push"
fi

echo ""
echo "═══════════════════════════════════════"
echo " ✅ Done! v${VERSION} ready"
echo "═══════════════════════════════════════"
echo ""
echo "📱 App user sẽ nhận update khi mở app"
