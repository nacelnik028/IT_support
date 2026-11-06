"""Check the current usability workflows against the exact embedded Windows pack."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import tempfile

from test_windows import ROOT, run, isolate_test


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True, type=Path)
    args = parser.parse_args()
    engine = args.godot.resolve(strict=True)
    exe = ROOT / 'build/ITSupportSimulator.exe'
    output = ROOT / 'docs/ui-review/2026-11-06-usability/verification/package'
    output.mkdir(parents=True, exist_ok=True)
    results = {}
    with tempfile.TemporaryDirectory(prefix='academy-usability-package-') as folder:
        temporary = Path(folder)
        packaged = temporary / 'EXE only' / exe.name
        packaged.parent.mkdir()
        shutil.copy2(exe, packaged)
        results['native_graphical'] = run([packaged, '--audio-driver', 'Dummy', '--rendering-method',
            'gl_compatibility', '--', '--test-world', '--export-smoke'], temporary, output / 'native-graphical.log')
        smoke = (output / 'native-graphical.log').read_text(encoding='utf-8')
        if not all(marker in smoke for marker in ['usability_menu=true', 'sidebar_preserved=true']):
            raise RuntimeError('The actual EXE does not contain the new interface evidence')
        for name in ['pause_repair', 'usability', 'editor_repair', 'package_content']:
            text = isolate_test((ROOT / f'tests/{name}.gd').read_text(encoding='utf-8'), 'usability_pack')
            text = text.replace('res://tests/pause_repair.gd', (temporary / 'pause_repair.gd').as_posix())
            text = text.replace('res://docs/ui-review/2026-11-06-usability', (output / 'screenshots').as_posix())
            (temporary / f'{name}.gd').write_text(text, encoding='utf-8')
        for name in ['usability', 'editor_repair', 'package_content']:
            command = [engine, '--headless', '--audio-driver', 'Dummy', '--main-pack', packaged,
                       '--script', temporary / f'{name}.gd', '--', '--review-usability']
            if name == 'package_content':
                command += [f'--reference={ROOT.as_posix()}', f'--inventory-out={(output / "inventory.json").as_posix()}']
            results[name] = run(command, temporary, output / f'{name}.log')
    report = {'exe_sha256': hashlib.sha256(exe.read_bytes()).hexdigest(), 'bytes': exe.stat().st_size,
              'runtime': 'Native Windows EXE + external tests against the same embedded pack', 'results': results}
    (output / 'results.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    if not all(results.values()):
        raise SystemExit(1)
    print('USABILITY WINDOWS PACKAGE PASS', flush=True)


if __name__ == '__main__':
    main()
