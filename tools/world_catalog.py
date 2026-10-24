"""Additive 3D infrastructure and practical tickets. No legacy definitions change."""
from build_extension import action, f, c, b, n


def extend(actions, defaults, missions, solutions):
    names = ['PVE-01', 'PVE-02', 'HV-01', 'HV-02', 'NAS-01', 'BACKUP-01']
    defaults['world'] = dict(
        devices={name: dict(power_connected=True, cable_connected=True, port=i+1,
                            expected_port=i+1, hot_swap=True) for i, name in enumerate(names)},
        inspected={}, removed={}, replaced={}, restarted={}, data_loss={},
        stock={
            'SPARE-2T': dict(serial='SP-SAS-2000', capacity=2000, interface='SAS', available=True),
            'SPARE-1T': dict(serial='SP-SAS-1000', capacity=1000, interface='SAS', available=True),
            'SPARE-SATA': dict(serial='SP-SATA-2000', capacity=2000, interface='SATA', available=True),
        }, held='', monitor_checked=False, commissioned=False,
        player=dict(x=0, z=3, yaw=0, pitch=0), tutorial_arrived=False,
    )
    device = lambda: c('device', 'Zařízení', names)
    pool = lambda: c('pool', 'Řadič / pole', ['RAID', 'ZFS'])
    definitions = [
        action('physical_inspect', 'Fyzická diagnostika zařízení', [device()]),
        action('physical_power', 'Napájení zařízení', [device(), c('operation', 'Operace', ['Start', 'Shutdown', 'Restart'])]),
        action('physical_cable', 'Zapojení do SW-CORE', [device(), b('connected', 'Kabel připojen'), n('port', 'Port switche', 1, min=1, max=12)]),
        action('physical_supply', 'Napájecí přívod', [device(), b('connected', 'Napájení připojeno')]),
        action('physical_spare', 'Vzít náhradní disk', [c('spare', 'Náhradní disk', list(defaults['world']['stock']))]),
        action('physical_return_spare', 'Vrátit náhradní disk', []),
        action('physical_remove', 'Vyjmout konkrétní disk', [pool(), f('slot', 'Slot', default='2'), f('serial', 'Sériové číslo', default='DC-002'), b('backup_checked', 'Záloha ověřena'), b('confirmed', 'Identita potvrzena')], danger=True, warning='Vytažení zdravého člena může způsobit selhání pole.'),
        action('physical_insert', 'Vložit nesený náhradní disk', [pool(), f('slot', 'Slot', default='2'), b('backup_checked', 'Záloha ověřena')]),
        action('physical_monitor', 'Přečíst monitorovací konzoli', []),
        action('physical_commission', 'Předat fyzickou a softwarovou kontrolu', []),
    ]
    for definition in definitions:
        definition.update(console='Storage', panel='Fyzický servis')
    actions.extend(definitions)
