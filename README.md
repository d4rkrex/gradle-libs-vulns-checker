#  Super Vuln Checker

This tool checks your Java/Kotlin dependencies for known vulnerabilities using [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/).  
It's designed to be used easily via Docker, accepting a single dependency or a `.txt` file with multiple ones.

---

##  Usage

### 🔹 1. Create a `dependencies.txt` file (one per line)

```
org.json:json:20230618
com.google.code.gson:gson:2.10.1
org.jetbrains.kotlin:kotlin-stdlib:1.9.0
```

### 🔹 2. Run with Docker

Mount your current folder as `/app` and pass the filename:

```bash
docker run --rm -v $(pwd):/app super-vuln-checker dependencies.txt
```

✅ You can also check a single dependency like this:

```bash
docker run --rm super-vuln-checker "org.json:json:20230618"
```

### 🔹 3. Reports

At the end, you will see:

- A list of resolved dependencies
- Vulnerabilities with CVSS score
- A path to the full report (in JSON and HTML)

---

##  Advanced Notes

- The script uses a temporary working directory inside the container.
- If `dependencies.txt` is missing or mounted incorrectly, the script will fail early with a helpful message.
- **OSV-Scanner support is included but currently commented out due to known issues**. You can reactivate it later.

---

##  Docker Image Build (if needed)

If you're developing or modifying the tool:

```bash
docker build -t super-vuln-checker .
```

---

##  Output Example

```bash
📚 Resolved libraries:
org.json:json:20230618
com.google.code.gson:gson:2.10.1

📄 Dependency-Check results:
🚨 Component: json-20230618.jar
  - CVE-2023-XYZ (CVSS 9.8): Vulnerability description...
    URL: https://nvd.nist.gov/vuln/detail/CVE-2023-XYZ
```
