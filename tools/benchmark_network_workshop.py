"""Compare the exact same classroom camera against pre-workshop source."""
from pathlib import Path
import argparse
import io
import shutil
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/ui-review/2026-11-11-network-workshop'

def run(args, log):
    result = subprocess.run([str(x) for x in args], cwd=ROOT, capture_output=True, timeout=240)
    log.write_bytes(result.stdout + result.stderr)
    if result.returncode:
        raise RuntimeError(log)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--godot', required=True)
    parser.add_argument('--baseline', default='37d30ff^')
    args = parser.parse_args()
    engine = Path(args.godot).resolve()
    with tempfile.TemporaryDirectory(prefix='network-workshop-baseline-') as tmp:
        baseline = Path(tmp)
        archive = subprocess.check_output(['git', 'archive', '--format=zip', args.baseline,
                                          'project.godot', 'assets', 'data', 'scenes', 'scripts'], cwd=ROOT)
        zipfile.ZipFile(io.BytesIO(archive)).extractall(baseline)
        shutil.copy2(ROOT/'tests/workshop_benchmark.gd', baseline/'benchmark.gd')
        run([engine, '--headless', '--editor', '--import', '--quit', '--path', baseline], OUT/'verification/benchmark-import.log')
        for renderer in ['gl_compatibility', 'forward_plus']:
            for label, project, script in [('before', baseline, 'benchmark.gd'),
                                            ('after', ROOT, 'tests/workshop_benchmark.gd')]:
                run([engine, '--path', project, '--rendering-method', renderer, '--script', script,
                     '--', OUT/label/f'benchmark-{renderer}.png'], OUT/'verification'/f'benchmark-{label}-{renderer}.log')
    print('Both renderers compared at the same camera')

if __name__ == '__main__': main()
