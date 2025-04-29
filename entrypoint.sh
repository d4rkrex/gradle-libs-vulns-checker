#!/bin/bash

# Intelligent ENTRYPOINT for super-vuln-checker

# If the first argument is a known shell or command, execute it directly
case "$1" in
    bash|sh|zsh|ls|cat|vi|vim)
        exec "$@"
        ;;
    -*)
        # Support for flags (e.g., --help)
        exec /app/super_vuln_checker.sh "$@"
        ;;
    *)
        # Fallback: treat as dependency or file input
        exec /app/super_vuln_checker.sh "$@"
        ;;
esac
