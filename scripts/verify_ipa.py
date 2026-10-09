"""Verify package structure/provenance, never claim successful call injection."""
import argparse
import json
import plistlib
import struct
import zipfile
from pathlib import Path


def verify(path, source_sha=None):
    with zipfile.ZipFile(path) as archive:
        assert archive.testzip() is None, "IPA contains corrupted ZIP entries"
        names = archive.namelist()
        plists = [n for n in names if n.startswith("Payload/") and n.endswith(".app/Info.plist") and n.count("/") == 2]
        assert len(plists) == 1, "Expected exactly one top-level iPhone app"
        info = plistlib.loads(archive.read(plists[0]))
        root = plists[0].rsplit("/", 1)[0]
        executable = info.get("CFBundleExecutable")
        assert executable and "$" not in executable, "Missing or unresolved CFBundleExecutable"
        binary = archive.read(f"{root}/{executable}")
        assert len(binary) >= 32, "Executable is empty or truncated"
        magic, cpu, _, file_type, n_commands, command_bytes, _, _ = struct.unpack_from("<8I", binary)
        assert magic == 0xFEEDFACF and cpu == 0x0100000C, "Expected a thin 64-bit ARM64 Mach-O executable"
        assert file_type == 2 and n_commands > 0, "Not a Mach-O app executable"
        assert 32 + command_bytes <= len(binary), "Truncated Mach-O load commands"
        offset = 32
        for _ in range(n_commands):
            assert offset + 8 <= 32 + command_bytes, "Missing Mach-O load command"
            _, command_size = struct.unpack_from("<II", binary, offset)
            assert command_size >= 8 and offset + command_size <= 32 + command_bytes, "Invalid load command size"
            offset += command_size
        assert offset == 32 + command_bytes, "Mach-O load command size mismatch"
        assert info.get("CFBundlePackageType") == "APPL", "Incorrect bundle package type"
        assert info.get("NSMicrophoneInjectionUsageDescription"), "Missing injection permission description"
        minimum = tuple(int(p) for p in info.get("MinimumOSVersion", "0").split(".")[:2])
        assert minimum >= (18, 2), "Deployment target must be at least iOS 18.2"
        assert 2 in info.get("UIDeviceFamily", []) or 1 in info.get("UIDeviceFamily", []), "Missing iOS device family"
        assert info.get("DTPlatformName") == "iphoneos", "Not built for an iPhone device"
        if source_sha:
            assert info.get("MOQGOBuildSourceSHA") == source_sha, "Source SHA mismatch"
        assert b"setPreferredMicrophoneInjectionMode:error:" in binary, "Executable does not reference injection mode setter"
        assert b"requestMicrophoneInjectionPermissionWithCompletionHandler:" in binary, "Executable does not reference injection permission request"
        return {
            "ipa_structure": "PASS", "arm64_executable_bytes": len(binary),
            "bundle_id": info.get("CFBundleIdentifier"), "version": info.get("CFBundleShortVersionString"),
            "source_sha": info.get("MOQGOBuildSourceSHA"), "minimum_ios": info.get("MinimumOSVersion"),
            "injection_api_references": "PRESENT", "signing": "NOT_VERIFIED",
            "iphone_install": "NOT_TESTED", "whatsapp_injection": "NOT_TESTED",
        }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("ipa", type=Path)
    parser.add_argument("--source-sha")
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    report = verify(args.ipa, args.source_sha)
    output = json.dumps(report, indent=2, ensure_ascii=False)
    print(output)
    if args.report:
        args.report.write_text(output + "\n", encoding="utf-8")
