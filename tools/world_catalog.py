"""Additive 3D infrastructure and practical tickets. No legacy definitions change."""
from copy import deepcopy as cp
from build_extension import action, f, c, b, n, g


def extend(actions, defaults, missions, solutions):
    names = ['PVE-01', 'PVE-02', 'HV-01', 'HV-02', 'NAS-01', 'BACKUP-01']
    defaults['world'] = dict(
        devices={name: dict(power_connected=True, cable_connected=True, port=i+1,
                            expected_port=i+1, hot_swap=True) for i, name in enumerate(names)},
        inspected={}, identified={}, removed={}, replaced={}, restarted={}, data_loss={}, observed_vms={},
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
        action('physical_identify', 'Identifikovat disk a rozsvítit LED', [pool(), f('slot', 'Slot', default='2'), f('serial', 'Sériové číslo', default='DC-002')]),
        action('physical_remove', 'Vyjmout konkrétní disk', [pool(), f('slot', 'Slot', default='2'), f('serial', 'Sériové číslo', default='DC-002'), b('backup_checked', 'Záloha ověřena'), b('confirmed', 'Identita potvrzena')], danger=True, warning='Vytažení zdravého člena může způsobit selhání pole.'),
        action('physical_insert', 'Vložit nesený náhradní disk', [pool(), f('slot', 'Slot', default='2'), b('backup_checked', 'Záloha ověřena')]),
        action('physical_monitor', 'Přečíst monitorovací konzoli', []),
        action('physical_commission', 'Předat fyzickou a softwarovou kontrolu', []),
    ]
    for definition in definitions:
        definition.update(console='Storage', panel='Fyzický servis')
    actions.extend(definitions)
    inspect = lambda device: ['physical_inspect', dict(device=device)]
    verify = lambda: ['verify', {}]
    monitor = lambda: ['physical_monitor', {}]
    cable = lambda device, port: ['physical_cable', dict(device=device, connected=True, port=port)]
    power = lambda device, operation='Start': ['physical_power', dict(device=device, operation=operation)]
    vm_start = lambda vm: ['power', dict(vm=vm, power='Start')]

    def replacement(pool='RAID', slot='2', serial='DC-002', spare='SPARE-2T'):
        return [
            ['physical_identify', dict(pool=pool, slot=slot, serial=serial)],
            ['physical_remove', dict(pool=pool, slot=slot, serial=serial, backup_checked=True, confirmed=True)],
            ['physical_spare', dict(spare=spare)],
            ['physical_insert', dict(pool=pool, slot=slot, backup_checked=True)],
            ['rebuild', dict(pool=pool)], ['rebuild', dict(pool=pool)], verify(),
        ]

    def mission(title, description, initial, goals, steps, server='PVE-01', category='Storage', difficulty='Začátečník', focus=None):
        number = len(missions)+1
        missions.append(dict(
            id=number, title=title, category=category, server=server, topic='3D provoz',
            difficulty=difficulty, priority='Praktická směna', tags=['Diagnostika', 'RAID' if category=='Storage' else category],
            description=description, symptoms=description, initial_state=initial,
            available_actions=list(dict.fromkeys(row[0] for row in steps)), objectives=goals,
            failure_conditions=[], hints=[description, 'Prohlédni štítek zařízení a fyzické konektory. Používej E; stav ticketu je na Tab.',
                'Správný zásah ověř v živém monitoringu. Před výměnou zkontroluj serial, nezávislou zálohu, kapacitu a rozhraní.'],
            explanations='Fyzická a softwarová část sdílejí jeden model. Vyřešení potvrzují stavové cíle a kontrola skutečné služby.',
            rewards=dict(xp=300), world_task=True, world_focus=focus or server,
            review=dict(question='Co potvrzuje dokončený servis?', options=['Aktuální fyzický stav a ověřená služba.', 'Pouhé stisknutí servisního tlačítka.'], correct=0,
                        explanation='Po zásahu ověř pole, síť a aplikaci; samotné zapnutí či vložení disku nestačí.'),
        ))
        solutions.append(steps)

    mission('A01: najdi správný server', 'V racku A01 najdi PVE-02 podle označení a proveď jeho fyzickou diagnostiku.', {},
            [g('world.inspected.PVE-02', True, 'Ověřen konkrétní server PVE-02')], [inspect('PVE-02')], server='PVE-02')
    mission('Vadný disk: LED a sériové číslo', 'V NAS-01 najdi vadný slot2, ověř DC-002 a rozsviť identifikační LED. Disk zatím nevytahuj.',
            dict(disks={'2': dict(health='Failed')}, raid=dict(health='Degraded')),
            [g('world.identified.RAID:2', True, 'Slot2 / DC-002 fyzicky identifikován')],
            [inspect('NAS-01'), ['physical_identify', dict(pool='RAID', slot='2', serial='DC-002')]], server='NAS-01', focus='RAID:2')
    mission('Hot-swap a dokončený rebuild', 'Vyměň vadný DC-002 ve slotu2 NAS-01 za SAS disk alespoň2000GB ze servisní skříně. Ověř backup, dokonči rebuild a ověř pole.',
            dict(disks={'2': dict(health='Failed')}, raid=dict(health='Degraded')),
            [g('world.replaced.RAID:2', True, 'Fyzická náhrada vložena'), g('verified.raid', True, 'Rebuild dokončen a pole ověřeno')],
            [inspect('NAS-01')]+replacement(), server='NAS-01', difficulty='Pokročilý', focus='RAID:2')
    mission('Přerušený fyzický uplink', 'APP01 neodpovídá. Zkontroluj PVE-01 a odnes jeho odpojený konektor k portu1 SW-CORE. Ověř aplikaci.',
            dict(world=dict(devices={'PVE-01': dict(cable_connected=False)})),
            [g('world.inspected.PVE-01', True, 'Hostitel prohlédnut'), g('verified.service_pve', True, 'Služba po fyzickém zapojení běží')],
            [inspect('PVE-01'), cable('PVE-01', 1), verify()])
    mission('Správný port podle štítku', 'HV-01 je připojen do nesprávného portu8. Na štítku je SW-CORE port3. Přepoj kabel a ověř FS01.',
            dict(world=dict(devices={'HV-01': dict(port=8)})),
            [g('world.inspected.HV-01', True, 'Identita HV-01 ověřena'), g('verified.service_hv', True, 'Správná síťová cesta FS01')],
            [inspect('HV-01'), cable('HV-01', 3), verify()], server='HV-01', focus='NIC:HV-01')
    mission('Fyzická linka funguje, VLAN ne', 'Zkontroluj PVE-01, potom na ADMIN-01 oprav APP01 z VLAN30 do VLAN20. IP192.168.20.100/24, gateway192.168.20.1, DNS192.168.20.10. Ověř službu.',
            dict(vms={'100': dict(vlan=30)}),
            [g('world.inspected.PVE-01', True, 'Fyzická linka zkontrolována'), g('verified.service_pve', True, 'VLAN i služba opraveny')],
            [inspect('PVE-01')]+cp(solutions[3][1:]), category='Proxmox', difficulty='Pokročilý')
    mission('Server se po údržbě nespustil', 'Najdi vypnutý HV-01, zkontroluj jeho přívody a zapni jej. Potom v Hyper-V spusť FS01 a ověř službu.',
            dict(hosts={'HV-01': dict(online=False)}, vms={'200': dict(status='Off')}),
            [g('world.inspected.HV-01', True, 'Hostitel identifikován'), g('verified.service_hv', True, 'Hostitel i FS01 fungují')],
            [inspect('HV-01'), power('HV-01'), vm_start('200'), verify()], server='HV-01')
    mission('Kompatibilní náhrada ZFS disku', 'PVE-B v PVE-01 je vadný. Ověř serial, vyjmi slotB a ze skříně vezmi SATA náhradu alespoň1000GB. Dokonči resilver a ověř ZFS.',
            dict(zfs=dict(health='Degraded', disks={'B': dict(health='Failed')})),
            [g('world.replaced.ZFS:B', True, 'SATA disk fyzicky vložen'), g('verified.zfs', True, 'Resilver dokončen')],
            [inspect('PVE-01')]+replacement('ZFS', 'B', 'PVE-B', 'SPARE-SATA'), difficulty='Pokročilý', focus='ZFS:B')
    mission('Obchůzka úložišť a záloh', 'Prohlédni PVE-01, NAS-01 a BACKUP-01. Zkontroluj jejich kapacitu a stav na monitorovací konzoli za racky.', {},
            [g('world.inspected.'+id, True, id+' zkontrolován') for id in ['PVE-01', 'NAS-01', 'BACKUP-01']]+[g('world.monitor_checked', True, 'Živý monitoring přečten')],
            [inspect('PVE-01'), inspect('NAS-01'), inspect('BACKUP-01'), monitor()], focus='MONITOR')
    mission('Připrav zařízení k instalaci PVE', 'Fyzicky zkontroluj PVE-01. Na ADMIN-01 nainstaluj Proxmox na prázdná SYS-A+SYS-B jako ZFS mirror; management192.168.10.10, brána192.168.10.1, DNS192.168.10.2, eno1. Otevři HTTPS:8006.',
            cp(missions[1]['initial_state']),
            [g('world.inspected.PVE-01', True, 'Fyzická příprava ověřena'), g('hosts.PVE-01.installed', True, 'Proxmox nainstalován'), g('install.web', True, 'Web konzole dostupná')],
            [inspect('PVE-01')]+cp(solutions[1][1:]), category='Proxmox', difficulty='Pokročilý')
    mission('Bezpečný restart infrastruktury', 'Po aktualizaci bezpečně restartuj PVE-01. Potom z administračního pracoviště spusť APP01 a ověř její službu.', {},
            [g('world.restarted.PVE-01', True, 'Hostitel bezpečně restartován'), g('verified.service_pve', True, 'APP01 znovu ověřena')],
            [inspect('PVE-01'), power('PVE-01', 'Restart'), vm_start('100'), verify()], category='Proxmox', difficulty='Pokročilý')
    create = cp(solutions[2][1])
    create[1].update(id='101', name='WEB-3D')
    network = cp(solutions[3][1])
    network[1].update(vm='101', ip='192.168.20.101')
    mission('Nová VM a fyzický monitoring', 'Na ADMIN-01 vytvoř VM101 / WEB-3D: Debian, UEFI,2vCPU,4GB,32GB local-lvm, VirtIO, vmbr0/VLAN20, IP192.168.20.101/24, gateway192.168.20.1, DNS192.168.20.10. Spusť ji, ověř a vrať se přečíst fyzickou monitorovací obrazovku.', {},
            [g('vms.101.name', 'WEB-3D', 'VM správně vytvořena'), g('verified.vms.101', True, 'Aplikace ověřena'), g('world.observed_vms.101', 'Running', 'Monitoring přečetl novou běžící VM')],
            [inspect('PVE-01'), create, network, vm_start('101'), verify(), monitor()], category='Proxmox', difficulty='Pokročilý', focus='ADMIN-01')
    mission('Kritická kapacita ve fyzické serverovně', 'Zkontroluj NAS-01 a monitoring. Po ověření vlastníka a záloh odstraň osiřelé snapshoty a uvolni thin metadata. Znovu ověř kapacitní rezervu.',
            cp(missions[4]['initial_state']),
            [g('world.inspected.NAS-01', True, 'NAS prohlédnut'), g('world.monitor_checked', True, 'Monitoring navštíven'), g('verified.capacity', True, 'Bezpečná rezerva obnovena')],
            [inspect('NAS-01'), monitor()]+cp(solutions[4][1:]), server='NAS-01', difficulty='Pokročilý', focus='MONITOR')
    mission('Obnova služby po výpadku napájení', 'HV-01 je bez napájení a FS01 stojí. Připoj jeho PSU, zapni hostitele, v Hyper-V spusť FS01 a ověř aplikaci.',
            dict(hosts={'HV-01': dict(online=False)}, vms={'200': dict(status='Off')}, world=dict(devices={'HV-01': dict(power_connected=False)})),
            [g('world.inspected.HV-01', True, 'Příčina diagnostikována'), g('verified.service_hv', True, 'Služba po výpadku funguje')],
            [inspect('HV-01'), ['physical_supply', dict(device='HV-01', connected=True)], power('HV-01'), vm_start('200'), verify()], server='HV-01', focus='PSU:HV-01')
    mission('Kompletní přejímka serverovny', 'Proveď fyzickou kontrolu všech6 zařízení. Oprav odpojený kabel PVE-01 do portu1 a spusť HV-01 i FS01. Ověř obě služby a na monitorovací konzoli dokonči přejímku.',
            dict(world=dict(devices={'PVE-01': dict(cable_connected=False)}), hosts={'HV-01': dict(online=False)}, vms={'200': dict(status='Off')}),
            [g('world.commissioned', True, 'Přejímka všech zařízení a služeb dokončena')],
            [inspect(name) for name in names]+[cable('PVE-01', 1), power('HV-01'), vm_start('200'), verify(), monitor(), ['physical_commission', {}]], difficulty='Expert', focus='MONITOR')
