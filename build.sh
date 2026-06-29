#!/usr/bin/env bash
# ============================================================
#  Skin Painter Mod - Auto Build Script (Linux / macOS)
#  Requires: Java 17+  and  internet connection
# ============================================================
set -e

GRADLE_VERSION="8.4"
GRADLE_ZIP="gradle-${GRADLE_VERSION}-bin.zip"
GRADLE_URL="https://services.gradle.org/distributions/${GRADLE_ZIP}"
GRADLE_DIR="gradle-${GRADLE_VERSION}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${GREEN}=== Skin Painter Mod Builder ===${NC}"
echo ""

# ── Check Java ──────────────────────────────────────────────
if ! command -v java &>/dev/null; then
  echo -e "${RED}[ERROR] Java tidak ditemukan!${NC}"
  echo "Install Java 17: https://adoptium.net/"
  exit 1
fi

JAVA_VER=$(java -version 2>&1 | head -1 | grep -oP '(?<=version ")[\d]+')
if [ "${JAVA_VER:-0}" -lt 17 ]; then
  echo -e "${RED}[ERROR] Java 17+ diperlukan. Versi saat ini: ${JAVA_VER}${NC}"
  exit 1
fi
echo -e "${GREEN}✓ Java ${JAVA_VER} ditemukan${NC}"

# ── Download Gradle if not present ──────────────────────────
if [ ! -f "${GRADLE_DIR}/bin/gradle" ]; then
  echo -e "${YELLOW}[INFO] Mendownload Gradle ${GRADLE_VERSION}...${NC}"
  if command -v curl &>/dev/null; then
    curl -L --progress-bar "${GRADLE_URL}" -o "${GRADLE_ZIP}"
  elif command -v wget &>/dev/null; then
    wget --progress=bar "${GRADLE_URL}" -O "${GRADLE_ZIP}"
  else
    echo -e "${RED}[ERROR] curl atau wget diperlukan.${NC}"; exit 1
  fi
  echo -e "${YELLOW}[INFO] Mengekstrak Gradle...${NC}"
  unzip -q "${GRADLE_ZIP}"
  rm "${GRADLE_ZIP}"
  echo -e "${GREEN}✓ Gradle ${GRADLE_VERSION} siap${NC}"
else
  echo -e "${GREEN}✓ Gradle ${GRADLE_VERSION} sudah ada${NC}"
fi

GRADLE_BIN="./${GRADLE_DIR}/bin/gradle"
chmod +x "${GRADLE_BIN}"

# ── Generate Gradle wrapper ─────────────────────────────────
echo -e "${YELLOW}[INFO] Membuat Gradle wrapper...${NC}"
"${GRADLE_BIN}" wrapper --gradle-version "${GRADLE_VERSION}" -q
echo -e "${GREEN}✓ Gradle wrapper dibuat${NC}"

# ── Build mod ───────────────────────────────────────────────
echo ""
echo -e "${YELLOW}[INFO] Mendownload dependencies & kompilasi...${NC}"
echo -e "${YELLOW}      (Ini bisa memakan waktu 5-10 menit pertama kali)${NC}"
echo ""

chmod +x ./gradlew
./gradlew build --info 2>&1 | grep -E "BUILD|error|warning|Task|Downloading" || true

# ── Copy result ─────────────────────────────────────────────
echo ""
JAR_FILE=$(find build/libs -name "skinpainter-*.jar" ! -name "*sources*" | head -1)

if [ -z "${JAR_FILE}" ]; then
  echo -e "${RED}[ERROR] Build gagal! Cek output di atas.${NC}"
  exit 1
fi

cp "${JAR_FILE}" ./skinpainter-mod.jar
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   BUILD SUKSES! ✓                         ║${NC}"
echo -e "${GREEN}║   File: skinpainter-mod.jar               ║${NC}"
echo -e "${GREEN}║   Copy ke folder mods/ Minecraft kamu!    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
