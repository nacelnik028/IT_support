"""Verify generated service content and the task's protected starting catalogues."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

import build_network_workshop
import build_service_audio
import build_service_missions

ROOT = Path(__file__).resolve().parents[1]

def read(path):
    return json.loads((ROOT/path).read_text(encoding='utf-8-sig'))

def original(revision, path):
    return subprocess.check_output(['git','show',f'{revision}:{path}'],cwd=ROOT)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline',default='cca2787')
    args=parser.parse_args()
    baseline=args.baseline
    protected=['data/missions/campaign.json','data/missions/legacy_campaign.json',
               'data/network_lab/catalog.json','data/programming/catalog.json',
               'data/english/audio.json','tools/build_content.py',
               'tools/build_extension.py','tools/extension_catalog.py']
    for path in protected:
        # Normalize line endings only for text files checked out under Windows.
        assert original(baseline,path).replace(b'\r\n',b'\n')==(ROOT/path).read_bytes().replace(b'\r\n',b'\n'),path
    old=json.loads(original(baseline,'data/network_lab/workshop.json'))
    new=read('data/network_lab/workshop.json')
    for previous,current in zip(old['tasks'],new['tasks'],strict=True):
        assert {key:value for key,value in current.items() if key!='variants'}==previous,previous['id']
        assert len(current['variants'])==3
    assert read('data/network_lab/workshop.json')==build_network_workshop.catalogue()
    assert read('data/service_missions.json')==build_service_missions.catalogue()
    with tempfile.TemporaryDirectory(prefix='service-audio-reproduce-') as folder:
        isolated=Path(folder).resolve()
        assert isolated.name.startswith('service-audio-reproduce-')
        (isolated/'data').mkdir()
        build_service_audio.ROOT=isolated
        build_service_audio.build()
        expected=read('data/service_audio.json')
        assert json.loads((isolated/'data/service_audio.json').read_text(encoding='utf-8'))==expected
        for clip in expected['clips']:
            path=clip['path'].removeprefix('res://')
            actual=(ROOT/path).read_bytes()
            assert actual==(isolated/path).read_bytes()
            assert hashlib.sha256(actual).hexdigest()==clip['sha256']
    lab=read('data/network_lab/catalog.json')
    assert len(lab['tasks'])==40 and len(lab['cards'])==23
    campaign=read('data/missions/campaign.json')
    assert campaign[:24]==read('data/missions/legacy_campaign.json')
    print('SERVICE CONTENT PASS: 24 protected campaign definitions, 40 tasks / 23 cards, '
          'all A-H base tickets, 24 real variants, both mission generators, 7 byte-exact audio clips')

if __name__=='__main__': main()
