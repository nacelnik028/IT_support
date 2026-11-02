"""Run the current Test-All.ps1 suite list on Linux or Windows."""
import argparse
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True)
    parser.add_argument('--suite', action='append', help='Run only this existing suite (repeatable)')
    parser.add_argument('--log-dir', type=Path, default=ROOT / 'test-output', help='Separate logs for this run')
    parser.add_argument('--graphical', action='store_true')
    parser.add_argument('--screenshots', action='store_true')
    args = parser.parse_args()
    manifest = (ROOT / 'tools/Test-All.ps1').read_text()
    names = re.findall(r"'([^']+)'", re.search(r'foreach \(\$test in @\((.*?)\)\)', manifest).group(1))
    if args.suite:
        unknown = set(args.suite) - set(names)
        if unknown: parser.error(f'Unknown suites: {sorted(unknown)}')
        names = [name for name in names if name in args.suite]
    logs = args.log_dir
    logs.mkdir(parents=True, exist_ok=True)
    failed = []
    for name in names:
        command = [args.godot, '--audio-driver', 'Dummy', '--path', str(ROOT), '--script', f'tests/{name}.gd']
        command += ['--rendering-method', 'gl_compatibility'] if args.graphical else ['--headless']
        user_args = ['--all-modes'] if name == 'training_ui' else []
        if args.screenshots: user_args += ['--screenshots']
        if user_args: command += ['--'] + user_args
        try:
            result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                    text=True, encoding='utf-8', errors='replace', timeout=600)
            output = result.stdout
            bad = result.returncode != 0 or bool(re.search(r'^(SCRIPT ERROR:|ERROR:|WARNING:)', output, re.M))
        except subprocess.TimeoutExpired as error:
            output = str(error)
            bad = True
        (logs / f'{name}-{"graphical" if args.graphical else "headless"}.log').write_text(output, encoding='utf-8')
        print(f'{name}: {"FAIL" if bad else "PASS"}', flush=True)
        if bad:
            failed.append(name)
            print(output, flush=True)
    print(f'{len(names)} suites; {len(failed)} failed: {failed}', flush=True)
    return int(bool(failed))


if __name__ == '__main__':
    sys.exit(main())
