"""Native EXE-only and external regressions on that exact embedded service pack."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import tempfile

from test_windows import ROOT, run, isolate_test

OUT=ROOT/'docs/ui-review/2026-11-12-service-missions/verification/package'

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot',required=True,type=Path)
    args=parser.parse_args()
    engine=args.godot.resolve(strict=True)
    source=ROOT/'build/ITSupportSimulator.exe'
    OUT.mkdir(parents=True,exist_ok=True)
    results={}
    with tempfile.TemporaryDirectory(prefix='service-exe-verify-') as folder:
        isolated=Path(folder).resolve()
        exe=isolated/'EXE only with spaces'/source.name
        exe.parent.mkdir()
        shutil.copy2(source,exe)
        for graphical in [False,True]:
            label='native-graphical' if graphical else 'native-headless'
            command=[exe,'--audio-driver','Dummy']
            command+=['--rendering-method','gl_compatibility','--disable-vsync'] if graphical else ['--headless']
            command+=['--','--test-world','--export-smoke',f'--service-shot={OUT/"native-service-review.png"}']
            results[label]=run(command,isolated,OUT/(label+'.log'))
            text=(OUT/(label+'.log')).read_text(encoding='utf-8')
            results[label] &= 'SERVICE_SMOKE missions=2 passed=true pcm_nonzero=true clips=7' in text
            results[label] &= 'workshop=true tickets=8' in text and 'shift_restored=true' in text
        tests=isolated/'tests'
        tests.mkdir()
        # Inheritance stays external; every game resource still resolves inside
        # the exact EXE. Copy all test parents, never replace exported game code.
        for path in (ROOT/'tests').glob('*.gd'):
            text=isolate_test(path.read_text(encoding='utf-8-sig'),'service_pack')
            text=text.replace('res://tests/',tests.as_posix()+'/')
            # A shared short folder keeps evidence portable under Windows'
            # path limit, even when the user's checkout is deeply nested.
            destination=OUT.parent/'export'
            destination.mkdir(parents=True,exist_ok=True)
            # Both parent _init and the child run() must use that same folder.
            text=re.sub(r'''res://docs/ui-review/[^"']*/''',destination.as_posix()+'/',text)
            text=text.replace('res://docs/ui-review/',destination.as_posix()+'/')
            text=text.replace('res://test-output/',destination.as_posix()+'/')
            (tests/path.name).write_text(text,encoding='utf-8')
        for path in (ROOT/'tests').glob('*.json'): shutil.copy2(path,tests/path.name)
        suites=['workshop_variants','support_dialogue','service_missions','service_continuation',
                'service_missions_ui','cable_tester','service_audio','support_ui',
                'network_lab','network_workshop','session_safety','save_safety',
                'programming_runtime','english_model','xr_modes','package_content']
        for name in suites:
            command=[engine,'--headless','--audio-driver','Dummy','--main-pack',exe,'--script',tests/(name+'.gd'),'--']
            if name=='package_content': command += [f'--reference={ROOT.as_posix()}',f'--inventory-out={OUT/"inventory.json"}']
            results[name]=run(command,isolated,OUT/(name+'.log'))
        for name in ['service_missions_ui','cable_tester','service_audio']:
            command=[engine,'--audio-driver','Dummy','--main-pack',exe,'--rendering-method','gl_compatibility',
                     '--script',tests/(name+'.gd'),'--','--screenshots']
            results[name+'-graphical']=run(command,isolated,OUT/(name+'-graphical.log'))
    digest=hashlib.sha256(source.read_bytes()).hexdigest()
    report=dict(sha256=digest,bytes=source.stat().st_size,
                runtime='Native Windows EXE alone; editor regressions on its embedded pack',results=results)
    (OUT/'results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    if not all(results.values()): raise SystemExit(1)
    info_path=ROOT/'build/BUILD_INFO.json'
    info=json.loads(info_path.read_text(encoding='utf-8'))
    assert info['sha256']==digest
    info['native_windows_graphical_verified']=True
    info['service_verification']=report
    info_path.write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    print('SERVICE WINDOWS PACKAGE PASS '+digest,flush=True)

if __name__=='__main__': main()
