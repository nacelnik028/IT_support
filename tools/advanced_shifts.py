"""Versioned advanced shifts, independent of frozen campaign definitions."""
CONTENT_VERSION = 1

def build():
    def goal(path, value, label, op='eq'):
        return dict(path=path, value=value, label=label, op=op)
    def ticket(id, title, priority, impact, depends, goals, actions):
        return dict(id=id, title=title, priority=priority, impact=impact, depends=depends,
                    description=impact, objectives=goals, available_actions=actions)
    runtime=dict(clock=0, outage_minutes=0, fired=[], events=[], fresh_backups={}, monitor_revision=0)
    recovery=[
        ticket('REC-APP', 'APP01 / obnova sítě', 'P1',
               'APP01 neobsluhuje uživatele. VM100 potřebuje vmbr0, VLAN20, 192.168.20.100/24, bránu 192.168.20.1 a DNS 192.168.20.10. Ověř HTTPS.', [],
               [goal('vms.100.vlan',20,'VM100 VLAN20'),goal('verified.service_pve',True,'Aktuální ověření APP01')],['network','probe','verify']),
        ticket('REC-FS', 'FS01 / prostředky a start', 'P1',
               'FS01 stojí a požaduje 24 GiB. VM200: 2 vCPU, startup4/min2/max8 GiB, Dynamic Memory. Spusť a ověř službu.', [],
               [goal('vms.200.cpu',2,'FS01 2 vCPU'),goal('vms.200.ram',4,'FS01 4 GiB'),goal('vms.200.minimum',2,'Minimum 2 GiB'),goal('vms.200.maximum',8,'Maximum 8 GiB'),goal('vms.200.dynamic',True,'Dynamic Memory'),goal('verified.service_hv',True,'Aktuální ověření FS01')],['memory','power','verify']),
        ticket('REC-PBS', 'Plánovaný incident / uplink PBS', 'P2',
               'Po prvním ověření obou služeb se jednou odpojí kabel BACKUP-01. Jde o plánovanou poruchu REC-PBS-LINK, nikoli reset světa. Prohlédni zařízení a připoj port6.', ['REC-APP','REC-FS'],
               [goal('shift_runtime.fired','REC-PBS-LINK','Plánovaná porucha již nastala','contains'),goal('world.inspected.BACKUP-01',True,'Prohlédnut BACKUP-01'),goal('world.devices.BACKUP-01.cable_connected',True,'PBS kabel připojen'),goal('world.devices.BACKUP-01.port',6,'PBS port6')],['physical_inspect','physical_cable']),
        ticket('REC-COPY-APP', 'Nezávislý bod APP01', 'P2',
               'Po opravě služby a PBS vytvoř nový nezávislý bod VM100, PBS Verify a aktuální kontrolu aplikace.', ['REC-APP','REC-PBS'],
               [goal('shift_runtime.fresh_backups.100',True,'Nová záloha VM100 v tomto pokusu'),goal('backup.records.100.vlan',20,'Bod obnovy má VLAN20'),goal('backup.verified',True,'PBS Verify'),goal('verified.service_pve',True,'APP01 stále ověřený')],['backup','backup_verify','verify']),
        ticket('REC-COPY-FS', 'Nezávislý bod FS01 a přejímka', 'P2',
               'Zálohuj VM200 s opravenou RAM, proveď PBS Verify a ověř obě služby. Závěrečné předání zkontroluje všechny současné podmínky znovu.', ['REC-FS','REC-PBS'],
               [goal('shift_runtime.fresh_backups.200',True,'Nová záloha VM200 v tomto pokusu'),goal('backup.records.200.ram',4,'Bod obnovy má 4 GiB'),goal('backup.verified',True,'PBS Verify'),goal('verified.service_hv',True,'FS01 stále ověřený')],['backup','backup_verify','verify'])]
    storage=[
        ticket('STO-PBS','Dostupnost nezávislé zálohy','P1',
               'BACKUP-01 má odpojený kabel. Připoj port6 a prohlédni zařízení. Starší servisní body zůstávají pro bezpečnou výměnu; nové body vzniknou až skutečnou zálohou.',[],
               [goal('world.devices.BACKUP-01.cable_connected',True,'PBS uplink připojen'),goal('world.devices.BACKUP-01.port',6,'PBS port6'),goal('world.inspected.BACKUP-01',True,'Identita PBS ověřena')],['physical_cable','physical_inspect']),
        ticket('STO-DISK','NAS-01 / bezpečná obnova redundance','P1',
               'RAID10 má vadný DC-002 ve slotu2. Identifikuj jej, ověř servisní zálohu, potvrď vytažení, přines SAS SPARE-2T a dokonči rebuild. Vytažení zdravého slotu3 vyřadí stejný pár a způsobí skutečnou ztrátu dostupnosti dat; potom použij restart směny.',[],
               [goal('world.identified.RAID:2',True,'Identifikován DC-002'),goal('world.replaced.RAID:2',True,'Skutečná kompatibilní výměna'),goal('verified.raid',True,'Pole aktuálně Healthy')],['physical_identify','physical_remove','physical_spare','physical_insert','rebuild','verify']),
        ticket('STO-VSS','FS01 / aplikační konzistence','P2',
               'FS01 stále běží, ale VSS je vypnuté. VM200 potřebuje Guest Agent, VSS, StartIfRunning a bezpečné ShutDown. Oprav aplikační konzistenci před novou zálohou.',[],
               [goal('vms.200.vss',True,'VSS připravené'),goal('vms.200.agent',True,'Guest Agent připravený'),goal('vms.200.auto_stop','ShutDown','Bezpečné ukončení')],['integration']),
        ticket('STO-CACHE','Podmíněný incident / ochrana cache','P1',
               'Při prvním dosažení 50 % rebuildu jednou selže ochrana cache (STO-CACHE-POWER). Nastav Write-through; Protected/Force write-back s vadnou ochranou jsou rizikové a odmítnuté.', ['STO-DISK'],
               [goal('shift_runtime.fired','STO-CACHE-POWER','Incident ochrany nastal','contains'),goal('raid.cache_policy','Write-through','Bezpečná Write-through politika')],['cache']),
        ticket('STO-COPIES','Nové zálohy a provozní přejímka','P2',
               'Vytvoř nové nezávislé body VM100 i VM200, proveď PBS Verify, aktuálně ověř obě služby a zkontroluj monitoring. Změna pořadí oprav nesmí vrátit spotřebovanou náhradu do skříně.', ['STO-PBS','STO-DISK','STO-VSS','STO-CACHE'],
               [goal('shift_runtime.fresh_backups.100',True,'Nový bod APP01'),goal('shift_runtime.fresh_backups.200',True,'Nový bod FS01'),goal('backup.records.200.vss',True,'Zálohované VSS'),goal('backup.verified',True,'PBS Verify'),goal('verified.service_pve',True,'APP01 dostupný'),goal('verified.service_hv',True,'FS01 dostupný'),goal('world.monitor_checked',True,'Skutečný monitoring')],['backup','backup_verify','verify','physical_monitor'])]
    definitions=[]
    for id,title,category,server,initial,tickets,triggers in [
        ('SHIFT-RECOVERY','Pokročilá / dvě služby a zajištění','Proxmox','PVE-01',
         {'vms':{'100':{'vlan':30},'200':{'status':'Off','ram':24}}},recovery,
         [dict(id='REC-PBS-LINK',title='Plánovaná porucha uplinku BACKUP-01',
               checks=[goal('verified.service_pve',True,''),goal('verified.service_hv',True,'')],
               patch={'world':{'devices':{'BACKUP-01':{'cable_connected':False}}}})]),
        ('SHIFT-RESILIENCE','Pokročilá / storage a konzistence','Storage','NAS-01',
         {'disks':{'2':{'health':'Failed'}},'raid':{'health':'Degraded'},'vms':{'200':{'vss':False}},'world':{'devices':{'BACKUP-01':{'cable_connected':False}}}},storage,
         [dict(id='STO-CACHE-POWER',title='Plánovaná porucha ochrany cache při 50 % rebuildu',
               checks=[goal('raid.progress',50,'','gte'),goal('world.replaced.RAID:2',True,'')],patch={'raid':{'cache':False}})])]:
        initial['shift_runtime']=runtime.copy()
        definitions.append(dict(id=id,version=CONTENT_VERSION,advanced=True,title=title,category=category,server=server,
                                initial_state=initial,tickets=tickets,triggers=triggers,
                                final_objectives=[g for t in tickets for g in t['objectives']]))
    return definitions
