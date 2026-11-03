"""Deterministic standalone shift catalogue; legacy missions stay untouched."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def goal(path,value,label): return dict(path=path,value=value,label=label)
def build():
    definitions=[]
    def shift(id,title,category,server,initial,tickets):
        cumulative=[]; rows=[]
        for index,(name,text,goals,actions) in enumerate(tickets):
            cumulative+=goals
            rows.append(dict(id=id+"-"+str(index+1),title=name,description=text,objectives=list(cumulative),available_actions=actions))
        definitions.append(dict(id=id,version=1,title=title,category=category,server=server,initial_state=initial,tickets=rows))
    shift("SHIFT-NET","Síť a dostupnost","Proxmox","PVE-01",
      {"world":{"devices":{"PVE-01":{"cable_connected":False}}},"vms":{"100":{"vlan":30,"gateway":"192.168.20.254"}}},[
      ("Fyzický uplink","Prohlédni PVE-01. Připoj jeho konektor do portu 1 na SW-CORE. Konfigurace VM se zatím nemění.",[goal("world.inspected.PVE-01",True,"Prohlédnut PVE-01"),goal("world.devices.PVE-01.cable_connected",True,"Kabel připojen"),goal("world.devices.PVE-01.port",1,"Port 1 podle štítku")],["physical_inspect","physical_cable"]),
      ("VLAN a IP","APP01 / VM100: vmbr0, VLAN 20, IP 192.168.20.100/24, brána 192.168.20.1, DNS 192.168.20.10, ochrana zapnutá. Ověř HTTPS.",[goal("verified.service_pve",True,"Aktuálně dostupná služba APP01")],["network","probe","verify"]),
      ("Záloha dostupné služby","Zachovej funkční síť. Zálohuj VM100 do PBS a proveď Verify. Záloha ve směně vyžaduje dostupnou aplikaci.",[goal("backup.completed",True,"Dokončená záloha"),goal("backup.verified",True,"PBS Verify"),goal("backup.records.100.gateway","192.168.20.1","Záloha obsahuje opravenou bránu")],["backup","backup_verify","verify"])])
    shift("SHIFT-VM","VM a provoz","Hyper-V","HV-01",{"vms":{"200":{"status":"Off","ram":24}}},[
      ("Provozní diagnostika","Prohlédni HV-01 a události. FS01 je vypnutý a požaduje příliš mnoho paměti.",[goal("world.inspected.HV-01",True,"Identita HV-01 ověřena"),goal("diagnostic.Events",True,"Prohlédnuté události")],["inspect","physical_inspect"]),
      ("Prostředky a start","FS01 / VM200: nastav 2 vCPU, startup 4 GiB, minimum 2, maximum 8, Dynamic Memory. Spusť a ověř službu.",[goal("vms.200.cpu",2,"2 vCPU"),goal("vms.200.ram",4,"Startup 4 GiB"),goal("vms.200.minimum",2,"Minimum 2 GiB"),goal("vms.200.maximum",8,"Maximum 8 GiB"),goal("vms.200.dynamic",True,"Dynamic Memory"),goal("verified.service_hv",True,"FS01 v provozu")],["memory","power","verify"]),
      ("Nezávislá záloha","Zálohuj opravenou VM200 do PBS, proveď Verify a ověř infrastrukturu. Konfigurace ze druhého ticketu musí zůstat zachovaná.",[goal("backup.completed",True,"Záloha dokončena"),goal("backup.verified",True,"PBS Verify"),goal("backup.records.200.ram",4,"Bod obnovy zachovává 4 GiB")],["backup","backup_verify","verify"])])
    shift("SHIFT-DISK","Storage a servis","Storage","NAS-01",{"disks":{"2":{"health":"Failed"}},"raid":{"health":"Degraded"}},[
      ("LED a identita","Prohlédni NAS-01 a identifikuj vadný slot 2 / DC-002. Před servisem ověř nezávislou zálohu.",[goal("world.inspected.NAS-01",True,"Prohlédnut NAS-01"),goal("world.identified.RAID:2",True,"Identifikován DC-002")],["physical_inspect","physical_identify"]),
      ("Bezpečná fyzická náhrada","Vyjmi jen DC-002 se zálohou a potvrzením. Ze skříně přines SAS SPARE-2T a vlož jej do slotu 2. Nevytahuj zdravé členy.",[goal("world.replaced.RAID:2",True,"Fyzická náhrada vložena")],["physical_remove","physical_spare","physical_insert"]),
      ("Rebuild a provoz","Dokonči rebuild posunem času. Ověř pole i APP01 a FS01; prohlédni skutečný monitorovací přehled.",[goal("verified.raid",True,"Pole ověřeno Healthy"),goal("verified.service_pve",True,"APP01 dostupný"),goal("verified.service_hv",True,"FS01 dostupný"),goal("world.monitor_checked",True,"Monitoring zkontrolován")],["rebuild","verify","physical_monitor"])])
    from advanced_shifts import build as advanced
    return definitions + advanced()
if __name__=="__main__":
    target=ROOT/"data/shifts/catalog.json"; target.parent.mkdir(exist_ok=True)
    target.write_text(json.dumps(build(),ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
