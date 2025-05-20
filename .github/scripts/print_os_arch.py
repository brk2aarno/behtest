import platform

# See https://stackoverflow.com/questions/45125516/possible-values-for-uname-m
# See https://gist.github.com/skyzyx/d82b7d9ba05523dd1a9301fd282b32c4
def machine_normalized() -> str:
    x: dict[str, str] = {}
    for src in "arm64 arm64v8 arm64v9 armv8b armv8l aarch64_be aarch64".split():
        x[src] = "aarch64"

    for src in "amd64 AMD64 x64 x86_64".split():
        x[src] = "x86_64"

    m = platform.machine()
    return x.get(m, m)

os_arch = f"{platform.system()}-{machine_normalized()}"
print(os_arch)
