#!/bin/bash

echo "[+] Checking if Terraform is installed..."

# Define paths
TERRAFORM_VERSION="1.12.1"
TERRAFORM_ZIP="terraform_${TERRAFORM_VERSION}_windows_amd64.zip"
TERRAFORM_BASH_PATH="/c/terraform"
TERRAFORM_WIN_PATH="C:\\terraform"
DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP}"

# Check and install Terraform
if ! command -v terraform &> /dev/null; then
  echo "[+] Terraform not found. Installing Terraform..."

  mkdir -p "$TERRAFORM_BASH_PATH"
  cd "$TERRAFORM_BASH_PATH" || exit 1
  curl -O "$DOWNLOAD_URL"
  unzip -o "$TERRAFORM_ZIP"

  # Get current paths
  USER_PATH=$(powershell.exe -Command "[Environment]::GetEnvironmentVariable('Path', 'User')" | tr -d '\r')
  SYSTEM_PATH=$(powershell.exe -Command "[Environment]::GetEnvironmentVariable('Path', 'Machine')" | tr -d '\r')

  # Clean up any duplicate semicolons and whitespace
  USER_PATH=$(echo "$USER_PATH" | sed 's/;;*/;/g' | sed 's/ *$//g')
  SYSTEM_PATH=$(echo "$SYSTEM_PATH" | sed 's/;;*/;/g' | sed 's/ *$//g')

  # Append C:\terraform if it's not already there (for USER)
  if [[ "$USER_PATH" != *"C:\\terraform"* ]]; then
    echo "[+] Adding C:\\terraform to USER PATH..."
    powershell.exe -Command "[Environment]::SetEnvironmentVariable('Path', '$USER_PATH;C:\\terraform', 'User')"
  else
    echo "[=] C:\\terraform already in USER PATH."
  fi

  # Append C:\terraform to SYSTEM PATH (if running as admin)
  if [[ "$SYSTEM_PATH" != *"C:\\terraform"* ]]; then
    echo "[+] Adding C:\\terraform to SYSTEM PATH..."
    powershell.exe -Command "[Environment]::SetEnvironmentVariable('Path', '$SYSTEM_PATH;C:\\terraform', 'Machine')"
  else
    echo "[=] C:\\terraform already in SYSTEM PATH."
  fi


  echo "[+] Terraform installed successfully."
else
  echo "[+] Terraform is already installed."
  export PATH=$PATH:$TERRAFORM_BASH_PATH
fi

# Confirm installation
echo "[+] Verifying Terraform installation:"
terraform -v || echo "[!] Terraform not found. Try restarting the terminal."

# Prompt user input
read -p "Enter VM Name: " VM_NAME
read -p "Enter Full Path to ISO file : " ISO_PATH
read -p "Enter Full Path to VDI file : " VDI_PATH

# VirtualBox settings
VBOXMANAGE="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
RAM_MB=2048
CPUS=2

echo "[+] Creating VM: $VM_NAME"
"$VBOXMANAGE" createvm --name "$VM_NAME" --ostype "RedHat_64" --register

echo "[+] Configuring VM memory, CPUs, and boot order"
"$VBOXMANAGE" modifyvm "$VM_NAME" \
  --memory "$RAM_MB" \
  --cpus "$CPUS" \
  --boot1 disk \
  --boot2 dvd \
  --boot3 none \
  --boot4 none \
  --nic1 nat \
  --graphicscontroller vmsvga

echo "[+] Adding SATA Controller"
"$VBOXMANAGE" storagectl "$VM_NAME" \
  --name "SATA Controller" \
  --add sata \
  --controller IntelAhci

echo "[+] Attaching VDI to SATA Controller"
"$VBOXMANAGE" storageattach "$VM_NAME" \
  --storagectl "SATA Controller" \
  --port 0 \
  --device 0 \
  --type hdd \
  --medium "$VDI_PATH"

echo "[+] Adding IDE Controller"
"$VBOXMANAGE" storagectl "$VM_NAME" \
  --name "IDE Controller" \
  --add ide

echo "[+] Attaching ISO to IDE Controller"
"$VBOXMANAGE" storageattach "$VM_NAME" \
  --storagectl "IDE Controller" \
  --port 0 \
  --device 0 \
  --type dvddrive \
  --medium "$ISO_PATH"

echo "[+] Launching the VM"
"$VBOXMANAGE" startvm "$VM_NAME" --type gui
