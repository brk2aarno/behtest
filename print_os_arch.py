import platform

# examples:
# "Darwin-arm64"
# "Linux-x86_64"
os_arch = f"{platform.system()}-{platform.machine()}"
print(os_arch)
