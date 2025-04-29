#!/bin/bash

# Super Vuln Checker v4.3
# Dependency-Check + OSV-Scanner (CycloneDX SBOM) + Resolved Dependencies Listing

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN} - Super Vuln Checker v4.3 started...${NC}"

if [ "$#" -lt 1 ]; then
  echo -e "${RED}❌ Invalid usage.${NC}"
  echo "Usage:"
  echo "  $0 group:artifact:version"
  echo "  $0 file.txt (one dependency per line)"
  exit 1
fi

WORKDIR=$(mktemp -d -t vulncheck-XXXXXXXX)
echo -e "- 📁 Working directory created: ${YELLOW}$WORKDIR${NC}"
cd "$WORKDIR" || exit 2

echo -e "${CYAN} - Creating settings.gradle...${NC}"
cat > settings.gradle <<EOF
rootProject.name = 'vulncheck'
EOF

echo -e "${CYAN} - Creating build.gradle...${NC}"
cat > build.gradle <<EOF
plugins {
    id 'java'
    id 'org.owasp.dependencycheck' version '8.4.0'
    id 'org.cyclonedx.bom' version '1.7.4'
}

repositories {
    mavenCentral()
}

dependencies {
EOF

add_dependency() {
  local dep=$1
  echo "    implementation '$dep'" >> build.gradle
}

if [[ -f "$1" ]]; then
  echo -e "📄 Reading dependencies from file: ${YELLOW}$1${NC}"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    add_dependency "$line"
  done < "$1"
else
  echo -e "📄 Adding single dependency: ${YELLOW}$1${NC}"
  add_dependency "$1"
fi

cat >> build.gradle <<EOF
}

dependencyCheck {
    autoUpdate = true
    scanConfigurations = ['runtimeClasspath']
    formats = ['HTML', 'JSON']
    outputDirectory = "\$buildDir/reports/dependency-check"
    failBuildOnCVSS = 11.0
}

cyclonedxBom {
    includeConfigs = ["runtimeClasspath"]
    destination = file("build/reports")
    outputName = "bom"
    outputFormat = "json"
}
EOF

echo -e "${CYAN}🔄 Resolving Gradle dependencies...${NC}"
gradle dependencies --configuration runtimeClasspath > gradle_dependencies_output.txt 2>&1
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Error resolving dependencies:${NC}"
  cat gradle_dependencies_output.txt
  exit 2
fi

echo -e "${GREEN}✅ Dependencies resolved successfully.${NC}"

grep "\---" gradle_dependencies_output.txt | awk '{print $2}' | sed 's/(.*)//' | sort | uniq > resolved-libs.txt

if [ ! -s resolved-libs.txt ]; then
  echo -e "${RED}❌ No resolved libraries found. Aborting.${NC}"
  exit 2
fi

echo -e "\n Resolved libraries:"
cat resolved-libs.txt
echo -e "\n Saved to: ${YELLOW}$WORKDIR/resolved-libs.txt${NC}"

echo -e "\n${CYAN}🛡️ Running Dependency-Check...${NC}"
gradle dependencyCheckAnalyze --info > gradle_dependencycheck_output.txt 2>&1
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Error running Dependency-Check:${NC}"
  cat gradle_dependencycheck_output.txt
  exit 3
fi
echo -e "${GREEN}✅ Dependency-Check completed.${NC}"

REPORT_DIR="build/reports/dependency-check"
REPORT_FILE="$REPORT_DIR/dependency-check-report.json"

if [ -f "$REPORT_FILE" ]; then
  echo -e "\n Dependency-Check results:"
  jq -r '.dependencies[] | select(.vulnerabilities != null) | "\n🚨 Component: \(.fileName)\nVulnerabilities:\n\(.vulnerabilities[] | "  - \(.name) (CVSS \(.cvssv3Score)): \(.description)\n    URL: \(.url)")"' "$REPORT_FILE"
  TOTAL=$(jq '.dependencies[] | select(.vulnerabilities != null) | .vulnerabilities | length' "$REPORT_FILE" | awk '{s+=$1} END {print s}')
  echo -e "\n${RED}⚠️ Total vulnerabilities detected (Dependency-Check): $TOTAL${NC}"
else
  echo -e "${YELLOW}⚠️ No Dependency-Check report found.${NC}"
fi

echo -e "\n${CYAN} Generating SBOM for OSV-Scanner...${NC}"
gradle cyclonedxBom > /dev/null 2>&1

if [ ! -f "build/reports/bom.json" ]; then
  echo -e "${RED}❌ SBOM not generated. Check CycloneDX plugin or Gradle setup.${NC}"
  exit 4
fi

#echo -e "${CYAN} -  Running OSV-Scanner...${NC}"
#osv-scanner --sbom build/reports/bom.json --output osv_results.json > /dev/null 2>&1
#
#if [ $? -eq 0 ]; then
#  VULN_COUNT=$(jq '.vulnerabilities | length' osv_results.json)
#  if [ "$VULN_COUNT" -eq 0 ]; then
#    echo -e "${GREEN}✅ No vulnerabilities found by OSV-Scanner.${NC}"
#  else
#    echo -e "${RED}⚠️ Vulnerabilities detected by OSV-Scanner: $VULN_COUNT${NC}"
#    jq -r '.vulnerabilities[] | "\n🚨 Vulnerability: \(.id)\n  Package: \(.package.name)\n  Description: \(.details)\n  URL: \(.references[0].url)"' osv_results.json
#  fi
#else
#  echo -e "${RED}❌ Error running OSV-Scanner.${NC}"
#fi

echo -e "\n🏁 ${GREEN}Analysis complete.${NC}"
echo -e "- Reports saved in: ${YELLOW}$WORKDIR${NC}"
