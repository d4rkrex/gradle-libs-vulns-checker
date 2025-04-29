# Super Vuln Checker v4.2

A CLI tool to analyze Java/Kotlin dependencies using OWASP Dependency-Check and OSV-Scanner.  
Intended for CI/CD environments to generate audit-ready dependency listings and vulnerability reports.

## Features

- Resolves project dependencies via Gradle
- Lists all resolved dependencies in a plain text file
- Scans with OWASP Dependency-Check (offline NVD)
- Scans again with OSV-Scanner (Google's CVE index)
- Prevents build failure on vulnerability detection (safe-mode)
- Outputs human-readable and JSON-formatted reports

---

## 🔧 Usage without Docker

### Requirements

- Java 17
- Gradle 8.5+
- jq
- osv-scanner

### Run locally

```bash
chmod +x super_vuln_checker.sh
./super_vuln_checker.sh "com.example:example-lib:1.2.3"
```

Or with a file:

```bash
./super_vuln_checker.sh dependencies.txt
```

---

## Usage with Docker

### Build the image

```bash
docker build -t super-vuln-checker .
```

### Run with a single dependency

```bash
docker run --rm super-vuln-checker "com.example:example-lib:1.2.3"
```

### Run with a file

Prepare a `dependencies.txt` file in your current directory:

```
org.apache.commons:commons-lang3:3.12.0
com.fasterxml.jackson.core:jackson-databind:2.13.1
```

Then run:

```bash
docker run --rm -v $(pwd)/dependencies.txt:/app/dependencies.txt super-vuln-checker /app/dependencies.txt
```

---

## How to get the report

To export the generated report files (JSON, HTML, resolved-libs):

```bash
docker run --rm -v $(pwd):/output super-vuln-checker /app/dependencies.txt

# Reports will be saved in your current folder under:
# - ./output/resolved-libs.txt
# - ./output/dependency-check-report.json
# - ./output/dependency-check-report.html
# - ./output/osv_results.json
```

> You can customize the Dockerfile or the script to copy those files into `/output` automatically if needed.

---

## Output

- `resolved-libs.txt`: All libraries detected
- `build/reports/dependency-check/*.json/html`: Dependency-Check output
- `osv_results.json`: OSV vulnerability summary

---

## Notes

- Designed to run safely in CI without stopping pipelines
- Currently supports Gradle projects only
- You can extend this tool to export SBOM or integrate with MongoDB

---

## Roadmap

- Add SBOM generation (CycloneDX)
- Export results to MongoDB Atlas
- Support for Maven and npm
- Build Excel reports or dashboards from output