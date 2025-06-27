# 🚀 Terraform + VirtualBox RHEL9 VM Automation

This project provides a Bash script (`vm.sh`) to automate the following on a Windows machine:

- Check and install Terraform (if not already installed)
- Permanently add Terraform to the Windows PATH (User and System)
- Prompt user to provide VM details interactively
- Create and launch a RHEL 9 Virtual Machine via VirtualBox

---

## 📁 Requirements

- Windows OS
- [Git Bash](https://gitforwindows.org/) (to run the Bash script)
- [VirtualBox](https://www.virtualbox.org/) (installed and added to system PATH)
- Admin privileges (required to update the system environment variables)

---

## 🛠️ Features

- ✅ Installs Terraform v1.8.5 (via official HashiCorp URL)
- ✅ Adds `C:\terraform` to both **User** and **System** PATH permanently
- ✅ Uses `reg.exe` + PowerShell to ensure registry-based updates work reliably
- ✅ Launches RHEL 9 VM from user-provided `.iso` and `.vdi` paths
- ✅ Works from **PowerShell (Admin)** or **Git Bash (Admin)**

---

## 🧪 How to Run

### Step 1: Open PowerShell as Administrator

### Step 2: Run the script via Git Bash from Admin PowerShell:
```
& "C:\Program Files\Git\bin\bash.exe" "C:\Path\To\vm.sh"
```
Replace C:\Path\To\vm.sh with the actual location of your script.

## 🧾 User Prompts
You will be asked to enter:

* VM Name – A name like rhel9-vm
* ISO Path – Full Windows-style path to RHEL 9 ISO file
* VDI Path – Full Windows-style path to existing VDI file
