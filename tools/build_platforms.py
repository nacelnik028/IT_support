"""Export the existing game with official Godot templates and verify deliverables."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BUILDS = ROOT / "builds"
LOGS = ROOT / "test-output" / "platform-build"


def run(command, name, *, cwd=ROOT, env=None, timeout=900, clean=True):
    log = LOGS / (name + ".log")
    flags = {"creationflags": subprocess.CREATE_NO_WINDOW} if os.name == "nt" else {}
    with log.open("w", encoding="utf-8") as output:
        result = subprocess.run([str(x) for x in command], cwd=cwd, env=env,
                                stdout=output, stderr=subprocess.STDOUT, timeout=timeout, **flags)
    content = log.read_text(encoding="utf-8", errors="replace")
    if result.returncode or (clean and re.search(r"(?m)^(SCRIPT ERROR:|ERROR:|WARNING:)", content)):
        raise RuntimeError(f"{name}: exit {result.returncode}\n{content[-6000:]}")
    print(f"{name}: PASS", flush=True)
    return content


def configure_android(sdk, jdk, templates):
    for required in [sdk / "platform-tools/adb.exe", jdk / "bin/java.exe", templates / "android_source.zip"]:
        if not required.exists():
            raise FileNotFoundError(f"Required Android tool: {required}")
    settings = Path(os.environ["APPDATA"]) / "Godot/editor_settings-4.7.tres"
    content = settings.read_text(encoding="utf-8-sig")
    for key, value in {"export/android/java_sdk_path": jdk, "export/android/android_sdk_path": sdk}.items():
        line = key + " = " + json.dumps(value.as_posix())
        pattern = r"^" + re.escape(key) + r" = .*$"
        content = re.sub(pattern, lambda _: line, content, flags=re.M) if re.search(pattern, content, re.M) else content + "\n" + line + "\n"
    settings.write_text(content, encoding="utf-8")
    android = ROOT / "android"
    build = android / "build"
    if not (build / "build.gradle").exists():
        build.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(templates / "android_source.zip") as archive:
            archive.extractall(build)
        (android / ".build_version").write_text(templates.name, encoding="utf-8")
    (android / ".gdignore").touch()
    environment = os.environ.copy()
    environment.update(JAVA_HOME=str(jdk), ANDROID_HOME=str(sdk))
    environment["PATH"] = str(jdk / "bin") + os.pathsep + environment["PATH"]
    return environment


def checksum(path):
    return {"file": path.relative_to(ROOT).as_posix(), "bytes": path.stat().st_size,
            "sha256": hashlib.file_digest(path.open("rb"), "sha256").hexdigest()}


def verify_windows(exe):
    # Run the actual release executable from an unrelated folder, with all DLLs.
    results = {}
    with tempfile.TemporaryDirectory(prefix="academy-standalone-") as folder:
        isolated = Path(folder)
        for source in exe.parent.iterdir():
            if source.is_file(): shutil.copy2(source, isolated / source.name)
        for graphical in [False, True]:
            name = "native-graphical" if graphical else "native-headless"
            game_log = LOGS / (name + "-game.log")
            command = [isolated / exe.name, "--log-file", game_log]
            if not graphical: command += ["--headless"]
            command += ["--", "--test-world", "--export-smoke"]
            run(command, name, cwd=isolated, timeout=60)
            content = game_log.read_text(encoding="utf-8")
            for expected in ["menu=menu missions=65 lessons=21", "world=world objects=90", "training=true", "programming=true tasks=60 lessons=28", "python=true", "web=true preview=true", "limits=true", "programming_cancelled=true", "return_main=true"]:
                if expected not in content: raise RuntimeError(f"Missing native evidence: {expected}")
            if re.search(r"(?m)^(SCRIPT ERROR:|ERROR:|WARNING:)", content): raise RuntimeError(content)
            results[name] = "PASS"
    return results


def export_windows(engine, exe, environment):
    # PC VR uses Godot's built-in OpenXR. The vendor GDExtension is needed by
    # the Android exporter/runtime only. Stage the same sources without this
    # Android dependency, including its early desktop hand-tracking warning.
    with tempfile.TemporaryDirectory(prefix="academy-pc-export-") as folder:
        project=Path(folder)
        for name in ["assets","data","scenes","scripts"]: shutil.copytree(ROOT/name,project/name)
        shutil.copy2(ROOT/"project.godot",project/"project.godot")
        preset=(ROOT/"export_presets.cfg").read_text(encoding="utf-8").split("[preset.1]",1)[0]
        (project/"export_presets.cfg").write_text(preset,encoding="utf-8")
        run([engine,"--headless","--editor","--path",project,"--import"],"windows-import",env=environment)
        run([engine,"--headless","--path",project,"--export-release","Windows Desktop",exe,"--quit"],"windows-export",env=environment)
    stale=exe.parent/"libgodotopenxrvendors.dll"
    if stale.exists(): stale.unlink()


def verify_apk(apk, sdk, environment):
    tools = sdk / "build-tools/36.1.0"
    run([tools / "apksigner.bat", "verify", "--verbose", apk], "apk-signature", env=environment)
    # aapt on Windows cannot reliably decode a Unicode absolute argv path.
    badging = run([tools / "aapt.exe", "dump", "badging", apk.name], "apk-badging", cwd=apk.parent)
    if "native-code: 'arm64-v8a'" not in badging: raise RuntimeError("APK must be ARM64 only")
    with zipfile.ZipFile(apk) as archive:
        names = archive.namelist()
        for suffix in ["libgodot_android.so", "libopenxr_loader.so", "libgodotopenxrvendors.so"]:
            if not any(name.endswith(suffix) for name in names): raise RuntimeError("Missing " + suffix)
    manifest = ROOT / "android/build/build/intermediates/merged_manifests/standardDebug/processStandardDebugManifest/AndroidManifest.xml"
    text = manifest.read_text(encoding="utf-8")
    for expected in ["IMMERSIVE_HMD", "pvr.app.type", 'android:value="vr"', 'android:value="OpenXR"']:
        if expected not in text: raise RuntimeError("Missing PICO manifest entry: " + expected)
    for forbidden in ["EYE_TRACKING", "FACE_TRACKING", "Enterprise"]:
        if forbidden in text: raise RuntimeError("Unexpected hardware requirement: " + forbidden)
    shutil.copy2(manifest, LOGS / "PICO4-AndroidManifest.xml")
    devices = run([sdk / "platform-tools/adb.exe", "devices", "-l"], "adb-devices", clean=False)
    serials = [line.split()[0] for line in devices.splitlines() if re.match(r"^\S+\s+device\s", line)]
    device_result = "NOT RUN: no authorized ADB device"
    # Only deploy to a headset identified as PICO; never to an unrelated phone.
    for serial in serials:
        model = run([sdk / "platform-tools/adb.exe", "-s", serial, "shell", "getprop", "ro.product.model"], "adb-model", clean=False)
        if "pico" not in model.lower() and "a8110" not in model.lower(): continue
        run([sdk / "platform-tools/adb.exe", "-s", serial, "install", "-r", apk], "adb-install", timeout=180)
        run([sdk / "platform-tools/adb.exe", "-s", serial, "shell", "am", "start", "-n", "cz.academy.itsupport/com.godot.game.GodotAppLauncher"], "adb-launch")
        device_result = "Installed/launched; manual tracking and 72 FPS validation still required"
    return {"signature": "PASS", "arm64_and_openxr_manifest": "PASS", "device": device_result}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", required=True, type=Path)
    parser.add_argument("--sdk", type=Path, default=Path(os.environ.get("LOCALAPPDATA", "")) / "Android/Sdk")
    parser.add_argument("--jdk", type=Path, default=Path("C:/Program Files/Eclipse Adoptium/jdk-17.0.19.10-hotspot"))
    parser.add_argument("--verify-only", action="store_true", help="Verify and package the already exported binaries")
    args = parser.parse_args()
    engine = args.godot.resolve(strict=True)
    LOGS.mkdir(parents=True, exist_ok=True)
    for platform in ["windows", "pico4"]: (BUILDS / platform).mkdir(parents=True, exist_ok=True)
    (BUILDS / ".gdignore").touch()
    version = run([engine, "--version"], "engine-version").strip()
    templates = Path(os.environ["APPDATA"]) / "Godot/export_templates" / ".".join(version.split(".")[:4])
    environment = configure_android(args.sdk.resolve(), args.jdk.resolve(), templates)
    if not args.verify_only:
        run([engine, "--headless", "--editor", "--path", ROOT, "--import"], "import", env=environment)
    exe = BUILDS / "windows/ITSupportSimulator.exe"
    apk = BUILDS / "pico4/ITSupportSimulator-PICO4.apk"
    if not args.verify_only: export_windows(engine,exe,environment)
    windows = verify_windows(exe)
    # The Windows console launcher can keep waiting for pipes inherited by
    # Gradle's daemon after the actual editor has exited. Run the editor binary
    # directly with explicit log handles for this subprocess.
    android_engine=engine.with_name(engine.name.replace("_console.exe",".exe"))
    if not android_engine.exists(): android_engine=engine
    if not args.verify_only:
        run([android_engine, "--headless", "--path", ROOT, "--export-debug", "PICO 4", apk, "--quit"], "pico4-export", env=environment)
    android = verify_apk(apk, args.sdk.resolve(), environment)
    for source in [ROOT / "README.md", ROOT / "GODOT-LICENSE.txt", ROOT / "NAVOD_PICO4.md"]: shutil.copy2(source, exe.parent / source.name)
    shutil.copytree(ROOT / "docs", exe.parent / "docs", dirs_exist_ok=True)
    limits = exe.parent / "data/programming/LIMITS.txt"
    limits.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(ROOT / "data/programming/LIMITS.txt", limits)
    shutil.copytree(ROOT / "addons/godotopenxrvendors", exe.parent / "licenses/OpenXR-Vendors",
                    ignore=shutil.ignore_patterns(".bin", ".gitignore", "*.gdextension*", "*CHANGES*"), dirs_exist_ok=True)
    archive = BUILDS / "ITSupportSimulator-Windows.zip"
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as output:
        for source in exe.parent.rglob("*"):
            if source.is_file(): output.write(source, source.relative_to(exe.parent))
    report = {"engine": version, "windows": windows, "pico4": android,
              "hardware_tracking": "NOT TESTED", "pico_72_fps": "NOT MEASURED",
              "artifacts": [checksum(exe), checksum(archive), checksum(apk)]}
    previous_path=BUILDS/"VERIFICATION.json"
    if previous_path.exists():
        previous=json.loads(previous_path.read_text(encoding="utf-8"))
        if any(item.get("sha256")==report["artifacts"][0]["sha256"] for item in previous.get("artifacts",[])):
            packaged=previous.get("windows",{}).get("packaged_tests")
            if packaged: report["windows"]["packaged_tests"]=packaged
    (BUILDS / "VERIFICATION.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
