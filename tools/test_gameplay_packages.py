"""Focused final gameplay checks against the exact EXE and APK resources."""
import argparse,hashlib,json,tempfile,zipfile
from pathlib import Path
from test_windows import ROOT,run,isolate_test

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--godot',type=Path,required=True);args=parser.parse_args()
 engine=args.godot.resolve(strict=True); logs=ROOT/'test-output/gameplay-packages-final'; logs.mkdir(exist_ok=True)
 results={}
 for kind,path in [('windows',ROOT/'build/ITSupportSimulator.exe'),('pico',ROOT/'build/pico4/ITSupportSimulator-PICO4.apk')]:
  record={'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'results':{}}
  with tempfile.TemporaryDirectory(prefix='academy-final-pack-') as folder:
   temp=Path(folder);pack=path
   if kind=='pico':
    pack=temp/'apk-resources.zip'
    with zipfile.ZipFile(path) as apk,zipfile.ZipFile(pack,'w') as out:
     for entry in apk.infolist():
      if entry.filename.startswith('assets/') and not entry.is_dir():
       name=entry.filename.removeprefix('assets/');out.writestr(name,b'' if name=='.godot/extension_list.cfg' else apk.read(entry))
   for name in ['continuation_review','unified_profile','london_listening','attempt_review','advanced_shifts','shift_scoring','work_persistence','shifts','gameplay','xr_modes']:
    script=temp/(name+'.gd');script.write_text(isolate_test((ROOT/'tests'/script.name).read_text(encoding='utf-8'),'focused_'+kind),encoding='utf-8')
    record['results'][name]=run([engine,'--headless','--audio-driver','Dummy','--main-pack',pack,'--script',script,'--',f'--lesson-solutions={ROOT / "tests/lesson_solutions.json"}'],temp,logs/(kind+'-'+name+'.log'))
  results[kind]=record
 (logs/'results.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
 if not all(all(record['results'].values()) for record in results.values()):raise SystemExit(1)
 print('FINAL GAMEPLAY PACKAGES PASS')
if __name__=='__main__':main()
