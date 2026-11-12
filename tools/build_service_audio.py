"""Own procedural PCM sounds. No downloaded samples, models or runtime tools."""
import hashlib
import json
import math
from pathlib import Path
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1]
RATE = 16000

def build():
    target = ROOT / 'assets/audio/service'
    target.mkdir(parents=True, exist_ok=True)
    manifest = dict(version=1, generator='tools/build_service_audio.py', seed=42051,
                    origin='Original procedural synthesis for IT Support Simulator',
                    license='CC0-1.0', sample_rate=RATE, clips=[])
    for key, duration in [('rack', 1.0), ('step', .16), ('door', .5),
                          ('cable_on', .11), ('cable_off', .09), ('disk', .23), ('tester', .09)]:
        rng = random.Random(42051)
        frames = []
        for index in range(round(duration * RATE)):
            t = index / RATE
            noise = rng.uniform(-1, 1)
            if key == 'rack':
                # Integer frequencies close the loop at precisely one second.
                value = .13*math.sin(math.tau*80*t)+.07*math.sin(math.tau*120*t)+.025*math.sin(math.tau*337*t)
            elif key == 'door':
                value = (.12*math.sin(math.tau*140*t)+.04*noise)*math.sin(math.pi*t/duration)**.5
            elif key == 'step':
                value = (.18*noise+.24*math.sin(math.tau*95*t))*math.exp(-t*30)
            elif key == 'disk':
                value = .22*noise*math.exp(-t*16)+.12*math.sin(math.tau*430*t)*math.exp(-t*35)
            elif key == 'tester':
                value = .12*math.sin(math.tau*1000*t)
            else:
                value = .35*noise*math.exp(-t*80)+.12*math.sin(math.tau*(700 if key=='cable_on' else 420)*t)*math.exp(-t*50)
            if key != 'rack': value *= min(1, t/.004, (duration-t)/.012)
            frames.append(round(max(-1, min(1, value))*32767))
        path = target / (key+'.wav')
        with wave.open(str(path), 'wb') as output:
            output.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
            output.writeframes(struct.pack('<'+'h'*len(frames), *frames))
        manifest['clips'].append(dict(id=key, path='res://'+path.relative_to(ROOT).as_posix(),
                                      duration=duration, frames=len(frames),
                                      sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
    (ROOT/'data/service_audio.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('Service audio: 7 original deterministic PCM clips')

if __name__ == '__main__': build()
