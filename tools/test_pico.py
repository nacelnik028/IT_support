"""Run desktop regressions against the actual Godot resources inside the PICO APK.

Android libraries, headset startup, tracking and FPS still require a real PICO.
Only native Android extension discovery is disabled in the temporary desktop pack.
"""
import argparse
import hashlib
import json
from pathlib import Path
import platform
import tempfile
import zipfile

from test_windows import ROOT, run


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True, type=Path)
    parser.add_argument('--apk', type=Path, default=ROOT / 'build/pico4/ITSupportSimulator-PICO4.apk')
    args = parser.parse_args()
    engine = args.godot.resolve(strict=True)
    apk = args.apk.resolve(strict=True)
    info = json.loads((apk.parent / 'BUILD_INFO.json').read_text(encoding='utf-8'))
    with apk.open('rb') as source:
        digest = hashlib.file_digest(source, 'sha256').hexdigest()
    if digest != info['artifact']['sha256']:
        raise RuntimeError('APK differs from its build record')
    for item in info['sources']:
        with (ROOT / item['file']).open('rb') as source:
            if hashlib.file_digest(source, 'sha256').hexdigest() != item['sha256']:
                raise RuntimeError('APK source snapshot is outdated: ' + item['file'])
    logs = ROOT / 'test-output/pico-package'
    logs.mkdir(parents=True, exist_ok=True)
    results = {'current_source_snapshot': True}
    with tempfile.TemporaryDirectory(prefix='academy-pico-pack-') as folder:
        temporary = Path(folder)
        pack = temporary / 'apk-resources.zip'
        with zipfile.ZipFile(apk) as android, zipfile.ZipFile(pack, 'w') as desktop:
            if android.testzip() is not None:
                raise RuntimeError('APK CRC failed')
            for entry in android.infolist():
                if not entry.filename.startswith('assets/') or entry.is_dir():
                    continue
                name = entry.filename.removeprefix('assets/')
                data = android.read(entry)
                if name == '.godot/extension_list.cfg':
                    data = b''
                desktop.writestr(name, data)
            # These are raw packaged JSON files, not files from the checkout.
            for name in ['data/missions/campaign.json', 'data/training/lessons.json',
                         'data/missions/legacy_campaign.json','data/english/scenarios.json']:
                if android.read('assets/' + name) != (ROOT / name).read_bytes():
                    raise RuntimeError('Outdated packaged catalog: ' + name)
        results['packaged_catalogs_match'] = True
        for graphical in [False, True]:
            name = 'desktop_resources_graphical' if graphical else 'desktop_resources_headless'
            command = [engine, '--main-pack', pack, '--audio-driver', 'Dummy']
            command += ['--rendering-method', 'gl_compatibility'] if graphical else ['--headless']
            command += ['--', '--test-world', '--export-smoke']
            log = logs / (name + '.log')
            results[name] = run(command, temporary, log)
            output = log.read_text(encoding='utf-8')
            for expected in ['menu=menu missions=65 lessons=21', 'training=true',
                             'programming=true tasks=60 lessons=28', 'python=true',
                             'web=true preview=true', 'return_main=true', 'programming_west=true',
                             'english=true scenarios=6 completed=6','english_cancelled=true']:
                if expected not in output:
                    raise RuntimeError('Missing packaged smoke evidence: ' + expected)
        for name in ['english_model', 'english_world', 'ui_workflow', 'programming_location', 'programming_integration',
                     'xr_modes', 'terminal_sessions']:
            script = temporary / (name + '.gd')
            script.write_text((ROOT / 'tests' / script.name).read_text(encoding='utf-8'), encoding='utf-8')
            command = [engine, '--headless', '--audio-driver', 'Dummy', '--main-pack', pack, '--script', script, '--']
            if name == 'terminal_sessions':
                command += ['--verify-packaged', f'--lesson-solutions={ROOT / "tests/lesson_solutions.json"}']
            results[name] = run(command, temporary, logs / (name + '.log'))
    report = {'apk_sha256': digest, 'runtime': platform.system() + ' Godot with actual APK resources',
              'android_native_runtime': 'NOT RUN: requires an authorized PICO headset', 'results': results}
    (logs / 'results.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    if not all(results.values()):
        raise SystemExit(1)
    manifest = ROOT / 'build/VERIFICATION.json'
    verification = json.loads(manifest.read_text(encoding='utf-8'))
    if not any(item.get('sha256') == digest for item in verification['artifacts']):
        raise RuntimeError('Tested APK is missing from the distribution manifest')
    verification['pico4']['desktop_resource_tests'] = report
    manifest.write_text(json.dumps(verification, indent=2) + '\n', encoding='utf-8')
    print('PICO PACKAGE RESOURCES PASS: ' + digest, flush=True)


if __name__ == '__main__':
    main()
