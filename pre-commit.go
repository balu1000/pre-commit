package main

import (
    "fmt"
    "os"
    "os/exec"
    "runtime"
)

func init() {
    // Check if gitleaks is enabled
    out, err := exec.Command("git", "config", "--get", "hooks.gitleaks").Output()
    if err != nil {
        fmt.Println("Error getting git config:", err)
        os.Exit(1)
    }

    if string(out) != "enabled\n" {
        fmt.Println("gitleaks is not enabled. Enable it by running `git config --add hooks.gitleaks enabled`.")
        os.Exit(0)
    }

    // Check if gitleaks is installed
    _, err = exec.LookPath("gitleaks")
    if err != nil {
        fmt.Println("gitleaks not found, installing...")

        var installCmd *exec.Cmd

        switch runtime.GOOS {
        case "darwin":
            installCmd = exec.Command("sh", "-c", `curl -s https://api.github.com/repos/zricethezav/gitleaks/releases/latest | grep "browser_download_url.*darwin_amd64" | cut -d : -f 2,3 | tr -d \" | wget -qi - && tar -xvf gitleaks-darwin-amd64.tar.gz && chmod +x gitleaks && sudo mv gitleaks /usr/local/bin/`)
        case "linux":
            installCmd = exec.Command("sh", "-c", `curl -s https://api.github.com/repos/zricethezav/gitleaks/releases/latest | grep "browser_download_url.*linux_amd64" | cut -d : -f 2,3 | tr -d \" | wget -qi - && tar -xvf gitleaks-linux-amd64.tar.gz && chmod +x gitleaks && sudo mv gitleaks /usr/local/bin/`)
        default:
            fmt.Println("Unsupported OS")
            os.Exit(1)
        }

        if err := installCmd.Run(); err != nil {
            fmt.Println("Error installing gitleaks:", err)
            os.Exit(1)
        }
    }

    // Run gitleaks to check for secrets
    cmd := exec.Command("gitleaks", "detect", "--source", ".", "--no-git")
    output, err := cmd.CombinedOutput()
    if err != nil {
        fmt.Println("Secrets detected by gitleaks. Commit rejected.")
        fmt.Println(string(output))
        os.Exit(1)
    }

    fmt.Println("No secrets detected by gitleaks.")
}
