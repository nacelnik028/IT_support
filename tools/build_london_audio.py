"""Offline asset creation only: pip install piper-tts; ffmpeg on PATH.
Model argument: en_GB-jenny_dioco-medium.onnx (see docs/LONDON_AUDIO.md).
Runtime exports need neither Python, model, Internet nor a TTS engine.
"""
import argparse, hashlib, json, subprocess, wave
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
LINES=[
 ("LON01","customer","What ticket options are available for this afternoon?"),
 ("LON01","Sam","Of course. What tickets would you like?"),
 ("LON02","customer","Is there a family option for our group, and which ages qualify for child tickets?"),
 ("LON02","customer","Could you clarify that once more, please?"),
 ("LON03","customer","Before I decide, could you compare the total cost of Standard and Flex for me?"),
 ("LON03","Sam","Would Standard or Flex suit your plans better? Please consider the conditions as well as the price."),
 ("LON04","Sam","I'm sorry, that time is sold out. Would you like a later time?"),
 ("LON04","customer","What is the next available time?"),
 ("LON05","customer","Let me change that before I pay."),
 ("LON05","Sam","Of course. What time would you prefer?"),
 ("LON06","Alex","Hello! Do you need directions?"),
 ("LON06","customer","Excuse me, I'm trying to reach Elizabeth Tower on foot. Could you explain the route using landmarks?"),
]
def main():
 from piper import PiperVoice, SynthesisConfig
 parser=argparse.ArgumentParser(description=__doc__); parser.add_argument('--model',required=True,type=Path); args=parser.parse_args()
 output=ROOT/'assets/audio/london'; output.mkdir(parents=True,exist_ok=True)
 work=ROOT/'test-output/tts'; work.mkdir(parents=True,exist_ok=True)
 voice=PiperVoice.load(str(args.model))
 rows=[]
 for i,(scenario,speaker,text) in enumerate(LINES):
  row=dict(id='LONA%02d'%(i+1),scenario=scenario,speaker=speaker,text=text)
  for variant,rate in [('normal',1.0),('slow',1.6)]:
   wav=work/(row['id']+'-'+variant+'.wav')
   with wave.open(str(wav),'wb') as stream: voice.synthesize_wav(text,stream,SynthesisConfig(length_scale=rate))
   target=output/(row['id']+'-'+variant+'.mp3')
   subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(wav),'-ac','1','-ar','16000','-c:a','libmp3lame','-b:a','16k',str(target)],check=True)
   row[variant]='res://'+target.relative_to(ROOT).as_posix()
   row[variant+'_sha256']=hashlib.sha256(target.read_bytes()).hexdigest()
  rows.append(row)
 (ROOT/'data/english/audio.json').write_text(json.dumps(dict(voice='Jenny (Dioco)',source='https://github.com/dioco-group/jenny-tts-dataset',model_sha256=hashlib.sha256(args.model.read_bytes()).hexdigest(),lines=rows),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print('Audio bytes:',sum(p.stat().st_size for p in output.glob('*.mp3')))
if __name__=='__main__': main()
