# pre-commit
pre-commit встановлено локально
➜ git commit -m "this commit contains a secret"
Detect hardcoded secrets.................................................Failed
Note: to disable the gitleaks pre-commit hook you can prepend SKIP=gitleaks to the commit command and it will skip running gitleaks

➜ SKIP=gitleaks git commit -m "skip gitleaks check"
Detect hardcoded secrets................................................Skipped

