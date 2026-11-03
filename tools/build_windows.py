"""Build and verify the standalone Windows Debug EXE with the matching official template."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def embedded_pack(binary):
    if binary[:2] != b'MZ' or binary[-4:] != b'GDPC':
        raise ValueError('Expected a Windows executable with an embedded Godot pack')
    pe = struct.unpack_from('<I', binary, 0x3c)[0]
    if binary[pe:pe + 4] != b'PE\0\0' or struct.unpack_from('<H', binary, pe + 4)[0] != 0x8664:
        raise ValueError('Expected a Windows x86_64 PE executable')
    count = struct.unpack_from('<H', binary, pe + 6)[0]
    optional_size = struct.unpack_from('<H', binary, pe + 20)[0]
    sections = pe + 24 + optional_size
    pack_size = struct.unpack_from('<Q', binary, len(binary) - 12)[0]
    pack_start = len(binary) - 12 - pack_size
    if pack_start <= sections + 40 * count or binary[pack_start:pack_start + 4] != b'GDPC':
        raise ValueError('Invalid embedded pack footer')
    for index in range(count):
        entry = sections + 40 * index
        if binary[entry:entry + 8].rstrip(b'\0') in [b'pck', b'.pck']:
            raw_size, raw_start = struct.unpack_from('<II', binary, entry + 16)
            if not raw_start <= pack_start < raw_start + 8 or raw_start + raw_size > len(binary):
                raise ValueError('Invalid embedded pack PE section')
            return entry, raw_start, pack_start, pack_size
    raise ValueError('Embedded pack PE section not found')


def run(args, log, cwd=None):
    result = subprocess.run([str(x) for x in args], cwd=cwd, capture_output=True,
                            encoding='utf-8', errors='replace', timeout=300)
    output = result.stdout + result.stderr
    log.write_text(output, encoding='utf-8')
    if result.returncode or re.search(r'(?m)^(?:SCRIPT ERROR:|ERROR:|WARNING:)', output):
        raise RuntimeError(f'{log.name} failed (exit {result.returncode}):\n{output}')
    return output.strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True, type=Path)
    parser.add_argument('--template', type=Path, help='Official matching Windows x86_64 Debug template')
    parser.add_argument('--runner', type=Path, help='Wine executable for Linux verification')
    args = parser.parse_args()
    engine = args.godot.resolve(strict=True)
    build = ROOT / 'build'
    build.mkdir(exist_ok=True)
    logs = ROOT / 'test-output'
    logs.mkdir(exist_ok=True)
    target = build / 'ITSupportSimulator.exe'
    runner = [args.runner.resolve(strict=True)] if args.runner else []
    version = run([engine, '--headless', '--version'], logs / 'windows-editor-version.log').split()[0]
    if args.template:
        template = args.template.resolve(strict=True)
    else:
        base = Path(os.environ['APPDATA']) / 'Godot' if os.name == 'nt' else Path(os.environ.get('XDG_DATA_HOME', str(Path.home()/'.local/share'))) / 'godot'
        template = base / 'export_templates' / '.'.join(version.split('.')[:4]) / 'windows_debug_x86_64.exe'
        template = template.resolve(strict=True)
    template_version = run(runner+[template, '--headless', '--version'], logs / 'windows-template-version.log').split()[0]
    if version != template_version:
        raise ValueError(f'Editor/template mismatch: {version} / {template_version}')
    with tempfile.TemporaryDirectory(prefix='academy-windows-build-') as tmp:
        temporary = Path(tmp).resolve()
        project = temporary / 'project'
        project.mkdir()
        for folder in ['assets', 'data', 'scenes', 'scripts']:
            shutil.copytree(ROOT / folder, project / folder)
        # JSON whitespace is not game content. Compact only the isolated export
        # copy; preserve every key, ID, value and the authored source catalogues.
        # This leaves room below GitHub's 100 MiB limit without changing the PE
        # template, packaging format, fonts or available courses.
        for catalog in (project / 'data').rglob('*.json'):
            original = json.loads(catalog.read_text(encoding='utf-8-sig'))
            compact = json.dumps(original, ensure_ascii=False, separators=(',', ':'))
            if json.loads(compact) != original:
                raise ValueError('JSON export compaction changed content: ' + str(catalog))
            catalog.write_text(compact, encoding='utf-8')
        shutil.copy2(ROOT / 'project.godot', project / 'project.godot')
        preset = (ROOT / 'export_presets.cfg').read_text(encoding='utf-8-sig').split('[preset.1]',1)[0]
        preset = preset.replace('binary_format/embed_pck=false', 'binary_format/embed_pck=true')
        preset = preset.replace('[preset.0.options]', '[preset.0.options]\ncustom_template/debug='
                                + json.dumps(template.as_posix()) + '\ndebug/export_console_wrapper=0')
        (project / 'export_presets.cfg').write_text(preset, encoding='utf-8')
        authored=(project/'project.godot').read_bytes()
        run([engine, '--headless', '--editor', '--import', '--quit', '--path', project], logs / 'windows-build-import.log')
        (project/'project.godot').write_bytes(authored)
        result = temporary / 'ITSupportSimulator.exe'
        run([engine, '--headless', '--path', project, '--export-debug', 'Windows Desktop', result], logs / 'windows-build-export.log')
        binary = result.read_bytes()
        embedded_pack(binary)
        if len(binary) >= 100*1024*1024:
            raise ValueError(f'Standalone executable {len(binary)} B exceeds the 104857600 B limit by {len(binary)-104857600} B; previous distribution preserved')
        isolated=temporary/'EXE only with spaces'
        isolated.mkdir()
        renamed=isolated/'Datacenter Academy.exe'
        shutil.copy2(result,renamed)
        workdir=temporary/'unrelated working directory'
        workdir.mkdir()
        output=run(runner+[renamed,'--headless','--audio-driver','Dummy','--','--test-world','--export-smoke'], logs/'windows-build-smoke.log',cwd=workdir)
        for expected in ['menu=menu missions=65 lessons=21','training=true','programming=true tasks=60 lessons=28',
                         'python=true','web=true preview=true','programming_cancelled=true','return_main=true','programming_west=true',
                         'english=true scenarios=6 completed=6','english_cancelled=true',
                         'hub=true neutral=true','quiz=true questions=20 score=100', 'shifts=true restored_shift=true','network=true','introduction=true','speech_clips=24']:
            if expected not in output: raise RuntimeError('Missing export evidence: '+expected)
        if list(isolated.glob('*.pck')): raise RuntimeError('Unexpected external pack')
        staged=target.with_suffix('.exe.tmp'); shutil.copy2(result,staged); staged.replace(target)
        # A leftover external PCK could shadow the newly embedded project.
        legacy_pack=target.with_suffix('.pck')
        if legacy_pack.exists():
            with tempfile.NamedTemporaryFile(prefix='obsolete-pack-',suffix='.bak',dir=build,delete=False) as archive:
                archive_name=Path(archive.name)
            shutil.move(legacy_pack,archive_name)
        info={'engine':version,'export':'Windows x86_64 Debug','bytes':len(binary),
              'sha256':hashlib.sha256(binary).hexdigest(),'embedded_pck':True,
              'verification':'Wine headless EXE-only smoke' if runner else 'Native Windows headless EXE-only smoke',
              'native_windows_graphical_verified':False,'json_export':'lossless whitespace compaction in isolated build copy'}
        (build/'BUILD_INFO.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
        (build/'SHA256SUMS').write_text(info['sha256']+'  ITSupportSimulator.exe\n',encoding='utf-8')
        print(json.dumps(info,indent=2))


if __name__ == '__main__':
    main()
