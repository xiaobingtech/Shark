# Device Installation Guide

Complete guide for building, packaging, and installing HarmonyOS applications to physical devices.

## Prerequisites

- **hdc**: HarmonyOS Device Connector (included in HarmonyOS SDK)
- **Device**: HarmonyOS device with USB debugging enabled
- **Build Output**: Signed HAP/HSP files

## Complete Workflow

### Step 1: Check Device Connection

```bash
hdc list targets
# Output: device UDID (e.g., 1234567890ABCDEF)
```

If no device found:
1. Check USB connection
2. Enable Developer Options on device
3. Enable USB debugging
4. Run `hdc kill && hdc start` to restart hdc server

### Step 2: Build Project

```bash
# Incremental build (default, use for normal development)
hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon
```

Only perform clean build when encountering issues or first time setup:

```bash
# Clean build (only when needed)
hvigorw clean --no-daemon
ohpm clean && ohpm cache clean
ohpm install --all
hvigorw --sync -p product=default -p buildMode=release --no-daemon
hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon
```

Build outputs location:
- APP bundle: `outputs/{product}/{project}-{product}-signed.app`
- Signed modules: `outputs/{product}/signed/`

### Step 3: Verify Build Outputs

All HAP/HSP modules must have the **same versionCode**. Check for mismatches:

```bash
# Using Python (cross-platform)
python3 -c "
import zipfile, json, glob
for f in glob.glob('outputs/default/signed/*.hsp'):
    z = zipfile.ZipFile(f)
    data = json.loads(z.read('module.json'))
    print(f\"{f.split('/')[-1]}: versionCode = {data['app']['versionCode']}\")
"

# Using unzip + grep (Linux/macOS)
for f in outputs/default/signed/*.hsp; do
    echo -n "$(basename $f): "
    unzip -p "$f" module.json | grep -o '"versionCode":[0-9]*'
done
```

**How to identify problematic modules:**

1. Module directory has no `src/` folder (precompiled binary only)
2. Module not listed in `build-profile.json5` modules array
3. Module versionCode differs from `AppScope/app.json5`

If any module has a different versionCode, remove it before installation:

```bash
rm outputs/default/signed/problematic-module-default-signed.hsp
```

### Step 4: Push Files to Device

```bash
# Clear and create installation directory on device
hdc -t <UDID> shell "rm -rf /data/local/tmp/app_install && mkdir -p /data/local/tmp/app_install"

# Push signed HAP/HSP files
hdc -t <UDID> file send outputs/default/signed /data/local/tmp/app_install
```

### Step 5: Install Application

```bash
# Install all HAP/HSP from directory
hdc -t <UDID> shell "bm install -p /data/local/tmp/app_install/signed"

# Expected output: "install bundle successfully."
```

### Step 6: Verify and Launch

```bash
# Check package info
hdc -t <UDID> shell "bm dump -n <bundleName>"

# Launch application
hdc -t <UDID> shell "aa start -a EntryAbility -b <bundleName>"
```

### Uninstall Application

```bash
hdc -t <UDID> shell "bm uninstall -n <bundleName>"
```

## Quick Installation Script

Save as `install.sh` (Linux/macOS) or run with Git Bash on Windows:

```bash
#!/bin/bash

# === Configuration ===
DEVICE_ID="${1:-$(hdc list targets | head -1)}"
SIGNED_PATH="${2:-outputs/default/signed}"
BUNDLE_NAME="${3:-}"
REMOTE_PATH="/data/local/tmp/app_install"

if [ -z "$DEVICE_ID" ]; then
    echo "Error: No device found. Connect a device or specify UDID as first argument."
    exit 1
fi

echo "Device: $DEVICE_ID"
echo "Source: $SIGNED_PATH"

# === Clear remote directory ===
hdc -t "$DEVICE_ID" shell "rm -rf $REMOTE_PATH && mkdir -p $REMOTE_PATH"

# === Push signed files ===
hdc -t "$DEVICE_ID" file send "$SIGNED_PATH" "$REMOTE_PATH"

# === Install ===
hdc -t "$DEVICE_ID" shell "bm install -p $REMOTE_PATH/$(basename $SIGNED_PATH)"

echo ""
echo "Installation complete!"

# === Optional: Launch app ===
if [ -n "$BUNDLE_NAME" ]; then
    echo "Launching $BUNDLE_NAME..."
    hdc -t "$DEVICE_ID" shell "aa start -a EntryAbility -b $BUNDLE_NAME"
fi
```

Usage:

```bash
# Auto-detect device, use default path
./install.sh

# Specify device UDID
./install.sh 1234567890ABCDEF

# Specify device and path
./install.sh 1234567890ABCDEF outputs/default/signed

# Specify device, path, and bundle name (auto-launch)
./install.sh 1234567890ABCDEF outputs/default/signed com.example.app
```

## hdc Command Reference

### Device Management

| Command | Description |
|---------|-------------|
| `hdc list targets` | List connected devices (UDID) |
| `hdc -t <UDID> shell "<cmd>"` | Execute shell command on device |
| `hdc kill` | Kill hdc server |
| `hdc start` | Start hdc server |
| `hdc version` | Show hdc version |

### File Transfer

| Command | Description |
|---------|-------------|
| `hdc -t <UDID> file send <local> <remote>` | Push file/directory to device |
| `hdc -t <UDID> file recv <remote> <local>` | Pull file/directory from device |

### Bundle Manager (bm)

Execute via `hdc -t <UDID> shell "bm ..."`:

| Command | Description |
|---------|-------------|
| `bm install -p <path>` | Install from directory (all HAP/HSP) |
| `bm install -p <file.hap>` | Install single HAP file |
| `bm uninstall -n <bundleName>` | Uninstall application |
| `bm dump -n <bundleName>` | Dump package info |
| `bm dump -a` | Dump all installed packages |

### Ability Assistant (aa)

Execute via `hdc -t <UDID> shell "aa ..."`:

| Command | Description |
|---------|-------------|
| `aa start -a <ability> -b <bundle>` | Start specific ability |
| `aa force-stop <bundleName>` | Force stop application |
| `aa dump -a` | Dump all running abilities |

## Troubleshooting

### Error: "version code not same"

**Cause:** Some HAP/HSP modules have different versionCode than others.

**Solution:**
1. Use the version check commands to find modules with different versionCode
2. Remove those modules from signed directory before installation
3. Usually caused by precompiled modules not in build-profile.json5

### Error: "install parse profile prop check error"

**Cause:** Signature or profile configuration mismatch.

**Solution:**
1. Check signing config in `build-profile.json5`
2. Ensure certificate and profile match
3. Verify profile bundleName matches app.json5 bundleName
4. Check certificate is not expired

### Error: Device not found

**Cause:** Connection or hdc service issue.

**Solution:**
1. Check USB cable connection
2. Enable Developer Options: Settings → About → Tap build number 7 times
3. Enable USB debugging: Settings → Developer options → USB debugging
4. Restart hdc server: `hdc kill && hdc start`
5. Try different USB port or cable

### Error: "install failed due to older sdk version in the device"

**Cause:** Device system version is lower than app's minimum requirement.

**Solution:**
1. Update device to latest system version
2. Or lower `compatibleSdkVersion` in `build-profile.json5`

### Error: "signature verification failed"

**Cause:** Certificate issues.

**Solution:**
1. Regenerate debug/release certificate in DevEco Studio
2. Check certificate validity period
3. Ensure using correct signing config for build type

## Build Output Structure

```
outputs/
└── {product}/                              # e.g., default/
    ├── {project}-{product}-signed.app      # Complete APP bundle
    ├── signed/
    │   ├── entry-{product}-signed.hap      # Main entry HAP
    │   ├── feature-{product}-signed.hap    # Feature HAP (if any)
    │   └── *.hsp                           # Shared library modules
    └── unsigned/
        └── ...                             # Unsigned versions
```

## Key Configuration Files

| File | Description |
|------|-------------|
| `AppScope/app.json5` | App metadata: bundleName, versionCode, versionName, icon, label |
| `build-profile.json5` | Build config: modules list, products, signing configs |
| `{module}/src/main/module.json5` | Module config: abilities, permissions, pages |
| `{module}/oh-package.json5` | Module dependencies |

## Module Types

| Type | Extension | Description |
|------|-----------|-------------|
| HAP | `.hap` | Harmony Ability Package - Application entry point |
| HSP | `.hsp` | Harmony Shared Package - Dynamic shared library |
| HAR | `.har` | Harmony Archive - Static library (compiled into HAP) |
| APP | `.app` | Complete bundle containing all HAP + HSP |
