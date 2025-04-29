# 🛡️ Gradle Libs Vuln Checker

This tool checks Java/Kotlin dependencies for known vulnerabilities using [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/).  
It is designed to be used easily with Docker
---

## How to Use

### 1. Run via Docker (one dependency per run)

Mount your current folder to `/output` (for exporting reports), and pass the dependency as a string:

```bash
docker run --rm d4rkrex/gradle-libs-vulns-checker "group:artifact:version"
```

 Example:

```bash
docker run --rm -v $(pwd):/output d4rkrex/gradle-libs-vulns-checker "org.json:json:20230618"
```

---

## What It Does

- Resolves the given dependency and its transitive dependencies using Gradle.
- Scans for known CVEs using OWASP Dependency-Check.
- Prints results and lists detected vulnerabilities, if any.
---

## ℹ️ Notes

- Multiple dependency scanning via `.txt` is not supported.
- OSV-Scanner support is disabled by default.
- Results and reports are generated in a temporary folder inside the container (shown on screen).
- Mounting to `/output` is optional if you only want terminal output.

---

## Build Locally (if needed)

```bash
docker build -t gradle-libs-vulns-checker .
```

---

##  Example Output

```
📚 Resolved libraries:
org.json:json:20230618

📄 Dependency-Check results:
🚨 Component: json-20230618.jar
  - CVE-2023-XXXX (CVSS 9.8): Some vulnerability details...
    URL: https://nvd.nist.gov/vuln/detail/CVE-2023-XXXX
```
