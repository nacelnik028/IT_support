"""Exercise local signing, key reuse and Windows rejection of a tampered EXE."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import tempfile

from build_windows import ROOT, embedded_pack, run, sign_debug


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--exe', type=Path, default=ROOT / 'build/ITSupportSimulator.exe')
    args = parser.parse_args()
    logs = ROOT / 'test-output/windows-signing-test'
    logs.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='academy-signing-test-') as folder:
        temporary = Path(folder)
        exe = temporary / 'Game with spaces.exe'
        original = args.exe.read_bytes()
        shutil.copy2(args.exe, exe)
        first = sign_debug(exe, logs)
        second = sign_debug(exe, logs)
        assert first['thumbprint'] == second['thumbprint'], 'Signing identity changed'
        before = embedded_pack(original)
        signed = exe.read_bytes()
        after = embedded_pack(signed)
        assert original[before[2]:before[2] + before[3]] == signed[after[2]:after[2] + after[3]]
        assert len(signed) < 100 * 1024 * 1024
        assert second['cms_signature_verified'] and second['pe_digest_verified']
        # Mutate real game data after signing. Windows must reject its digest,
        # even though the self-signed root was never added to the trust store.
        damaged = bytearray(signed)
        damaged[after[2] + 128] ^= 1
        exe.write_bytes(damaged)
        check = temporary / 'check.ps1'
        check.write_text(
            "Import-Module (Join-Path $PSHOME 'Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1')\n"
            "(Get-AuthenticodeSignature -LiteralPath $args[0]).Status.ToString()\n",
            encoding='utf-8')
        environment = os.environ.copy()
        environment.pop('PSModulePath', None)
        status = run(['powershell.exe', '-NoProfile', '-NonInteractive', '-File', check, exe],
                     logs / 'tamper.log', env=environment)
        assert status == 'HashMismatch', 'Windows did not detect changed content: ' + status
        report = {
            'source_sha256': hashlib.sha256(original).hexdigest(),
            'key_reused': True, 'embedded_pack_unchanged': True,
            'cms_signature_verified': True, 'pe_digest_verified': True,
            'tamper_status': status, 'below_100_mib': True,
            'signature': second,
        }
        (logs / 'results.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print('WINDOWS SIGNING PASS: reusable key, unchanged pack, valid SHA256, tamper rejected')


if __name__ == '__main__':
    main()
