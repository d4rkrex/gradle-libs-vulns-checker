# 🛡️ Super Vuln Checker

This tool checks Java/Kotlin dependencies for known vulnerabilities using [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/).  
It is designed to be used easily with Docker and **analyzes one dependency at a time**.

---

## 🚀 How to Use

### 1. Run via Docker 

Mount your current folder into `/app` and pass the dependency as argument:

```bash
docker run --rm -v $(pwd):/app super-vuln-checker "group:artifact:version"
```

✅ Example:

```bash
docker run --rm -v $(pwd):/app super-vuln-checker "org.json:json:20230618"
```

---

## What It Does

- Resolves the given dependency and its transitive dependencies using Gradle.
- Scans for known CVEs using OWASP Dependency-Check.
- Prints results and lists detected vulnerabilities, if any.
- Outputs a `resolved-libs.txt` and a vulnerability report (JSON & HTML).

---

## ℹ️ Notes

- OSV-Scanner support is disabled by default.

---

## Building the Docker Image (if needed)

```bash
docker build -t super-vuln-checker .
```

---

## Example Output

```
📚 Resolved libraries:
org.json:json:20230618

📄 Dependency-Check results:
🚨 Component: json-20230618.jar
  - CVE-2023-XXXX (CVSS 9.8): Some vulnerability details...
    URL: https://nvd.nist.gov/vuln/detail/CVE-2023-XXXX
```
