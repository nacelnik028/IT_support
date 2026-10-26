"""Verify the actual standalone EXE and its embedded game data in isolation."""
import argparse
import hashlib
import json
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


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot',required=True,type=Path,help='Full Godot editor executable')
    parser.add_argument('--exe',type=Path,default=ROOT/'builds/windows/ITSupportSimulator.exe')
    parser.add_argument('--headless',action='store_true',help='Skip graphical checks')
    args=parser.parse_args()
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
        # Copy any native dependencies that accompany the supplied export.
        for library in source.parent.glob('*.dll'): shutil.copy2(library,isolated/library.name)
        # Export templates disable --script/--path. Boot the real main scene
        # using its existing opt-in save/config isolation before Game.new().
        results['native_headless']=run([exe,'--headless','--quit-after','90','--','--test-world'],
                                       isolated,logs/'native-headless.log')
        if not args.headless:
            results['native_graphical']=run([exe,'--quit-after','120','--','--test-world'],
                                            isolated,logs/'native-graphical.log')
        # The editor runs external tests against precisely the embedded pack.
        # Only screenshot destinations in the temporary test copies change.
        for name in ['programming_runtime','programming_catalog','programming_academy','programming_integration','xr_modes','terminal_sessions','ui_design','world_ui','world_playthrough']:
            script=isolated/f'{name}.gd'
            text=(ROOT/f'tests/{name}.gd').read_text(encoding='utf-8')
            script.write_text(text.replace('res://test-output',screenshots.as_posix()),encoding='utf-8')
            command=[engine,'--main-pack',exe,'--script',script]
            if args.headless: command+=['--headless']
            command+=['--']
            if not args.headless: command+=['--screenshots']
            if name=='terminal_sessions':
                command+=['--verify-packaged',f'--lesson-solutions={ROOT/"tests/lesson_solutions.json"}']
            results[name]=run(command,isolated,logs/f'{name}.log')
    report={'sha256':digest,'bytes':source.stat().st_size,'results':results}
    (logs/'results.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    if not all(results.values()): raise SystemExit(1)
    manifest=ROOT/'builds/VERIFICATION.json'
    if manifest.exists():
        verification=json.loads(manifest.read_text(encoding='utf-8'))
        if any(item.get('sha256')==digest for item in verification.get('artifacts',[])):
            verification['windows']['packaged_tests']=results
            manifest.write_text(json.dumps(verification,indent=2),encoding='utf-8')
    print('WINDOWS PACKAGE PASS: '+digest,flush=True)


if __name__=='__main__':
    main()
