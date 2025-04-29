FROM gradle:8.5-jdk17


RUN apt-get update && apt-get install -y jq curl file && apt-get clean

RUN curl -L --fail -o /usr/local/bin/osv-scanner https://github.com/google/osv-scanner/releases/download/v2.0.1/osv-scanner_linux_amd64 \
    && chmod +x /usr/local/bin/osv-scanner \
    && file /usr/local/bin/osv-scanner | grep 'ELF' > /dev/null

WORKDIR /app


COPY super_vuln_checker.sh /app/
COPY entrypoint.sh /app/

RUN chmod +x /app/super_vuln_checker.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
