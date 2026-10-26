"""Rebuild the standalone EXE with Godot's exporter and the bundled template."""
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


def extract_template(binary, target):
    entry, raw_start, _, _ = embedded_pack(binary)
    # Keep a valid, initialized PE section for the Windows loader. Godot will
    # point this placeholder at the new pack during the official export.
    pe = struct.unpack_from('<I', binary, 0x3c)[0]
    alignment = struct.unpack_from('<I', binary, pe + 24 + 36)[0]
    sections=pe+24+struct.unpack_from('<H',binary,pe+20)[0]
    count=struct.unpack_from('<H',binary,pe+6)[0]
    engine_end=0
    for index in range(count):
        section=sections+40*index
        if section==entry: continue
        size, offset=struct.unpack_from('<II',binary,section+16)
        if size: engine_end=max(engine_end,offset+size)
    if not 0 < engine_end <= raw_start:
        raise ValueError('Engine sections overlap the embedded pack')
    placeholder=(engine_end+alignment-1)//alignment*alignment
    template=bytearray(binary[:engine_end])
    template.extend(bytes(placeholder+alignment-engine_end))
    struct.pack_into('<II', template, entry + 16, alignment, placeholder)
    target.write_bytes(template)


def run(args, log):
    flags = {'creationflags': subprocess.CREATE_NO_WINDOW} if hasattr(subprocess, 'CREATE_NO_WINDOW') else {}
    result = subprocess.run([str(x) for x in args], capture_output=True, encoding='utf-8',
                            errors='replace', timeout=300, **flags)
    output = result.stdout + result.stderr
    log.write_text(output, encoding='utf-8')
    if result.returncode or re.search(r'(?m)^(?:SCRIPT ERROR:|ERROR:|WARNING:)', output):
        raise RuntimeError(f'{log.name} failed (exit {result.returncode}):\n{output}')
    return output.strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True, type=Path)
    parser.add_argument('--template', type=Path, help='Optional official Windows x86_64 Debug template')
    args = parser.parse_args()
    engine = args.godot.resolve(strict=True)
    build = ROOT / 'build'
    build.mkdir(exist_ok=True)
    logs = ROOT / 'test-output'
    logs.mkdir(exist_ok=True)
    target = build / 'ITSupportSimulator.exe'
    with tempfile.TemporaryDirectory(prefix='academy-windows-build-') as tmp:
        temporary = Path(tmp).resolve()
        template = temporary / 'windows_debug_x86_64.exe'
        if args.template:
            original_template=args.template.resolve(strict=True)
            template_version=run([original_template, '--version'], logs / 'windows-template-version.log').split()[0]
            shutil.copy2(original_template, template)
        else:
            version=run([engine,'--version'],logs/'windows-editor-version.log').split()[0]
            installed=Path(os.environ['APPDATA'])/'Godot/export_templates'/'.'.join(version.split('.')[:4])/'windows_debug_x86_64.exe'
            if not installed.is_file(): raise FileNotFoundError('Install matching official export templates or supply --template')
            template_version=run([installed,'--version'],logs/'windows-template-version.log').split()[0]
            shutil.copy2(installed,template)
        editor_version = run([engine, '--version'], logs / 'windows-editor-version.log').split()[0]
        if editor_version != template_version:
            raise ValueError(f'Editor/template mismatch: {editor_version} / {template_version}')
        project = temporary / 'project'
        project.mkdir()
        for folder in ['assets', 'data', 'scenes', 'scripts']:
            shutil.copytree(ROOT / folder, project / folder)
        shutil.copy2(ROOT / 'project.godot', project / 'project.godot')
        preset = (ROOT / 'export_presets.cfg').read_text(encoding='utf-8-sig')
        preset = preset.replace('binary_format/embed_pck=true', 'binary_format/embed_pck=false')
        preset = preset.replace('[preset.0.options]', '[preset.0.options]\ncustom_template/debug='
                                + json.dumps(template.as_posix()) + '\ndebug/export_console_wrapper=0')
        (project / 'export_presets.cfg').write_text(preset, encoding='utf-8')
        authored=(project/'project.godot').read_bytes()
        run([engine, '--headless', '--editor', '--import', '--path', project], logs / 'windows-build-import.log')
        (project/'project.godot').write_bytes(authored)
        result = temporary / 'ITSupportSimulator.exe'
        run([engine, '--headless', '--path', project, '--export-debug', 'Windows Desktop', result],
            logs / 'windows-build-export.log')
        binary = result.read_bytes()
        pack=result.with_suffix('.pck')
        if binary[:2]!=b'MZ' or not pack.is_file() or pack.read_bytes()[:4]!=b'GDPC':
            raise ValueError('Expected an unmodified Windows runtime and an external Godot PCK')
        if binary!=template.read_bytes(): raise ValueError('The exported runtime was unexpectedly modified')
        staged_pack=target.with_suffix('.pck.tmp')
        shutil.copy2(pack,staged_pack); staged_pack.replace(target.with_suffix('.pck'))
        staged = target.with_suffix('.exe.tmp')
        shutil.copy2(result, staged)
        staged.replace(target)
        info = {'engine': editor_version, 'bytes': len(binary),
                'sha256': hashlib.sha256(binary).hexdigest(), 'embedded_pck': False,
                'pck_sha256':hashlib.sha256(pack.read_bytes()).hexdigest()}
        (logs / 'windows-build.json').write_text(json.dumps(info, indent=2), encoding='utf-8')
        print(json.dumps(info, indent=2))


if __name__ == '__main__':
    main()
