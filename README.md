# ARM Embedded Dev Container

Shared development container for bare-metal ARM firmware projects (STM32, etc.) using VS Code, CMake, and the ARM GNU Toolchain.

## Included ioolchain
- **OS:** Ubuntu 24.04 (via Microsoft devcontainers base)
- **Compiler:** ARM GNU Toolchain (`arm-none-eabi-gcc`)
- **Build System:** CMake & Ninja
- **Debugging & Flashing:** OpenOCD & GDB Multiarch

## Usage in projects

In consumer repositories, point `.devcontainer/devcontainer.json` to the pre-built image published in GitHub Packages:

```json
{
  "name": "arm-devcontainer-example",
  "image": "ghcr.io/senkivvadym/arm-embedded-devcontainer:latest"
}
```

## Real word devcontainer example
This example provides a good starting point for a devcontainer with USB passthrough support for debug probes like ST-LINK.

```json
{
  {
    "name": "arm-devcontainer-example",
    "image": "ghcr.io/senkivvadym/arm-embedded-devcontainer:latest", // pull base image
    "remoteUser": "vscode",
    // enable usb access for container and remote user:
    "runArgs": [
      "-v",
      "/dev/bus/usb:/dev/bus/usb", // mount usb devices to container (if present)
      "--group-add",
      "root", // allow container user to access usb devices
      "--device-cgroup-rule=c 189:* rmw" // allow usb(189) from host to container
    ],
    // add current repository to trusted ones and all included submodules:
    "postCreateCommand": "git config --global --add safe.directory '${containerWorkspaceFolder}' && git config --global --add safe.directory '${containerWorkspaceFolder}/*'",
    "customizations": {
      "vscode": {
        "settings": {
          "cortex-debug.armToolchainPath": "/opt/arm-toolchain/bin",
          "cortex-debug.openocdPath": "/usr/bin/openocd",
          "cmake.sourceDirectory": "${workspaceFolder}",
          "cmake.configurePreset": "arm-gcc-debug",
          "cmake.copyCompileCommands": "${workspaceFolder}/compile_commands.json",
          "C_Cpp.intelliSenseEngine": "disabled",
          "clangd.arguments": [
            "--query-driver=**/*arm-none-eabi-g*,**/*arm-eabi-g*",
            "--header-insertion=never",
            "--background-index",
            "-j=4"
          ],
          "editor.formatOnSave": true,
          "[cpp]": {
            "editor.defaultFormatter": "llvm-vs-code-extensions.vscode-clangd"
          },
          "[c]": {
            "editor.defaultFormatter": "llvm-vs-code-extensions.vscode-clangd"
          }
        },
        "extensions": [
          "ms-vscode.cmake-tools",
          "llvm-vs-code-extensions.vscode-clangd",
          "marus25.cortex-debug",
          "jeff-hykin.better-cpp-syntax"
        ]
      }
    }
  }
}
```