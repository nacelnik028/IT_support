"""Verify the standalone EXE and external tests against its exact embedded pack."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import tempfile

from test_windows import ROOT, run, isolate_test

OUT = ROOT / 'docs/ui-review/2026-11-11-workshop-layout/verification/package'

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True, type=Path)
    args = parser.parse_args()
    engine = args.godot.resolve(strict=True)
    source = ROOT/'build/ITSupportSimulator.exe'
    OUT.mkdir(parents=True, exist_ok=True)
    results = {}
    with tempfile.TemporaryDirectory(prefix='network-workshop-exe-') as folder:
        tmp = Path(folder)
        exe = tmp/'EXE only'/source.name
        exe.parent.mkdir()
        shutil.copy2(source, exe)
        for graphical in [False, True]:
            label = 'native-graphical' if graphical else 'native-headless'
            command = [exe, '--audio-driver', 'Dummy']
            command += ['--rendering-method', 'gl_compatibility'] if graphical else ['--headless']
            command += ['--', '--test-world', '--export-smoke', f'--workshop-shot={OUT/"native-review.png"}']
            results[label] = run(command, tmp, OUT/f'{label}.log')
            output = (OUT/f'{label}.log').read_text(encoding='utf-8')
            results[label] &= 'workshop=true tickets=8' in output and 'shift_restored=true' in output
        for name in ['pause_repair', 'network_lab', 'network_workshop', 'workshop_layout', 'package_content']:
            text = isolate_test((ROOT/f'tests/{name}.gd').read_text(encoding='utf-8'), 'workshop_pack')
            for parent in ['pause_repair', 'network_lab', 'network_workshop']:
                text = text.replace(f'res://tests/{parent}.gd', (tmp/f'{parent}.gd').as_posix())
            text = text.replace('res://docs/ui-review/2026-11-11-network-workshop/after/', (OUT/'screenshots').as_posix()+'/')
            text = text.replace('res://docs/ui-review/', (OUT/'screenshots').as_posix()+'/')
            text = text.replace('res://test-output/', (OUT/'screenshots').as_posix()+'/')
            (tmp/f'{name}.gd').write_text(text, encoding='utf-8')
        (OUT/'screenshots').mkdir(exist_ok=True)
        for name, graphical in [('network_lab', False), ('network_workshop', False),
                                ('network_workshop', True), ('workshop_layout', True), ('package_content', False)]:
            label = name+('-graphical' if graphical else '-headless')
            command = [engine, '--audio-driver', 'Dummy', '--main-pack', exe, '--script', tmp/f'{name}.gd']
            command += ['--rendering-method', 'gl_compatibility'] if graphical else ['--headless']
            command += ['--']
            if name=='workshop_layout': command += ['--compact', '--screenshots']
            # The native EXE above supplies the exported review screenshot;
            # the complete source matrix is already retained without copies.
            if name=='package_content': command += [f'--reference={ROOT.as_posix()}', f'--inventory-out={OUT/"inventory.json"}']
            results[label] = run(command, tmp, OUT/f'{label}.log')
    report = dict(exe_sha256=hashlib.sha256(source.read_bytes()).hexdigest(), bytes=source.stat().st_size,
                  runtime='Native Windows EXE alone; external tests on its embedded pack', results=results)
    (OUT/'results.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    if not all(results.values()): raise SystemExit(1)
    info = json.loads((ROOT/'build/BUILD_INFO.json').read_text(encoding='utf-8'))
    assert info['sha256']==report['exe_sha256']
    info['native_windows_graphical_verified'] = True
    info['workshop_verification'] = report
    (ROOT/'build/BUILD_INFO.json').write_text(json.dumps(info, indent=2)+'\n', encoding='utf-8')
    print('WORKSHOP WINDOWS PACKAGE PASS '+report['exe_sha256'], flush=True)

if __name__=='__main__': main()
