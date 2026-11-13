"""Verify the primary portable download, or an explicit EXE/PCK folder build."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT=Path(__file__).resolve().parents[1]


def run(args, cwd, log):
    flags={'creationflags':subprocess.CREATE_NO_WINDOW} if hasattr(subprocess,'CREATE_NO_WINDOW') else {}
    with log.open('w',encoding='utf-8') as output:
        result=subprocess.run([str(x) for x in args],cwd=cwd,stdout=output,
                              stderr=subprocess.STDOUT,timeout=300,**flags)
    text=log.read_text(encoding='utf-8',errors='replace')
    ok=result.returncode==0 and not re.search(r'(?m)^(?:SCRIPT ERROR:|ERROR:|WARNING:)',text)
    print(f'{log.stem}: exit={result.returncode}, clean={ok}',flush=True)
    for line in text.splitlines():
        if re.search(r'(checks|actions|missions).*failures',line): print(line,flush=True)
    return ok


def isolate_test(text, kind):
    # Namespace fixture names, including backup-name filters. Keep user://
    # itself valid for directory enumeration and paths assembled from filenames.
    # One substitution pass handles overlapping fixture prefixes exactly once.
    stems=set(re.findall(r'user://([A-Za-z0-9_-]+)',text))
    if not stems: return text
    pattern='|'.join(re.escape(stem) for stem in sorted(stems,key=len,reverse=True))
    return re.sub(pattern,lambda match:f'package_{kind}_{os.getpid()}_'+match[0],text)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot',required=True,type=Path,help='Full Godot editor executable')
    parser.add_argument('--exe',type=Path,default=ROOT/'build/ITSupportSimulator.exe')
    parser.add_argument('--runner',type=Path,help='Wine executable for Linux; native Windows is otherwise required')
    parser.add_argument('--headless',action='store_true',help='Skip graphical checks')
    args=parser.parse_args()
    runner=[args.runner.resolve(strict=True)] if args.runner else []
    engine=args.godot.resolve(strict=True)
    source=args.exe.resolve(strict=True)
    logs=ROOT/'test-output/windows-package'
    logs.mkdir(parents=True,exist_ok=True)
    screenshots=logs/'screenshots'
    screenshots.mkdir(exist_ok=True)
    results={}
    digest=hashlib.sha256(source.read_bytes()).hexdigest()
    with tempfile.TemporaryDirectory(prefix='academy-windows-verify-') as tmp:
        isolated=Path(tmp)
        exe=isolated/'ITSupportSimulator.exe'
        shutil.copy2(source,exe)
        pack=source.with_suffix('.pck')
        if pack.exists(): shutil.copy2(pack,exe.with_suffix('.pck'))
        main_pack=exe.with_suffix('.pck') if pack.exists() else exe
        # Copy any native dependencies that accompany the supplied export.
        for library in source.parent.glob('*.dll'): shutil.copy2(library,isolated/library.name)
        # Export templates disable --script/--path. Boot the real main scene
        # using its existing opt-in save/config isolation before Game.new().
        results['native_headless']=run(runner+[exe,'--headless','--audio-driver','Dummy','--','--test-world','--export-smoke'],
                                       isolated,logs/'native-headless.log')
        if not args.headless:
            results['native_graphical']=run(runner+[exe,'--audio-driver','Dummy','--rendering-method','gl_compatibility','--disable-vsync','--','--test-world','--export-smoke'],
                                            isolated,logs/'native-graphical.log')
        # The editor runs external tests against precisely the distributed pack.
        # Only screenshot destinations in the temporary test copies change.
        for name in ['continuation_review','unified_profile','london_listening','attempt_review','advanced_shifts','shift_scoring','work_persistence','shifts','gameplay','gameplay_review','package_content','academy_hub','london_quiz','english_model','english_world','ui_workflow','programming_runtime','programming_catalog','programming_academy','programming_integration','programming_polish','programming_location','xr_modes','terminal_sessions','ui_design','world_ui','world_playthrough']:
            script=isolated/f'{name}.gd'
            text=isolate_test((ROOT/f'tests/{name}.gd').read_text(encoding='utf-8'), 'windows')
            script.write_text(text.replace('res://test-output',screenshots.as_posix()).replace('res://docs/ui-review/2026-11-03-gameplay',(screenshots/'gameplay').as_posix()).replace('res://docs/ui-review/2026-11-03-continuation',(screenshots/'continuation').as_posix()),encoding='utf-8')
            command=[engine,'--audio-driver','Dummy','--main-pack',main_pack,'--script',script]
            if not args.headless: command+=['--rendering-method','gl_compatibility','--disable-vsync']
            if args.headless: command+=['--headless']
            command+=['--']
            if not args.headless: command+=['--screenshots']
            if name in ['terminal_sessions','work_persistence']:
                command+=['--verify-packaged',f'--lesson-solutions={ROOT/"tests/lesson_solutions.json"}']
            if name=='package_content':
                command += [f'--reference={ROOT.as_posix()}', f'--inventory-out={(logs/"inventory.json").as_posix()}']
            results[name]=run(command,isolated,logs/f'{name}.log')
    report={'native_checks_runtime':'Wine' if runner else 'Windows','editor_pack_checks_runtime':'Linux' if __import__('os').name!='nt' else 'Windows','sha256':digest,'bytes':source.stat().st_size,'results':results}
    if pack.exists(): report['pck_sha256']=hashlib.sha256(pack.read_bytes()).hexdigest()
    (logs/'results.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    if not all(results.values()): raise SystemExit(1)
    manifest=ROOT/'build/VERIFICATION.json'
    if manifest.exists():
        verification=json.loads(manifest.read_text(encoding='utf-8'))
        if any(item.get('sha256')==digest for item in verification.get('artifacts',[])):
            if pack.exists() and not any(item.get('sha256')==report['pck_sha256'] for item in verification.get('artifacts',[])):
                raise RuntimeError('The tested PCK does not match the distribution manifest')
            variant='windows' if pack.exists() else 'portable_windows'
            verification.setdefault(variant,{})['packaged_tests']=results
            manifest.write_text(json.dumps(verification,indent=2),encoding='utf-8')
    print('WINDOWS PACKAGE PASS: '+digest,flush=True)


if __name__=='__main__':
    main()
