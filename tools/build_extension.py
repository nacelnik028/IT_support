"""Append academy data without rewriting the original 24 mission definitions."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p): return json.loads((ROOT/p).read_text(encoding='utf-8'))
def write(p,d): (ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def g(path,value,label='',op='eq'): return dict(path=path,value=value,label=label or path,op=op)
def f(key,label,type='text',default='',options=None,**kw):
    d=dict(key=key,label=label,type=type,default=default,**kw)
    if options is not None: d['options']=options
    return d
def n(key,label,value,**kw): return f(key,label,'number',value,**kw)
def c(key,label,options,default=None): return f(key,label,'choice',default or options[0],options)
def b(key,label,value=True): return f(key,label,'bool',value)
def vm(value='101'): return c('vm','VMID',['100','200','900','101'],value)
def action(id,label,fields,console='Proxmox',panel='Průvodce VM',**kw): return dict(id=id,label=label,fields=fields,console=console,panel=panel,description=kw.pop('description','Změna upravuje skutečnou konfiguraci simulátoru.'),**kw)
def step(title,text,why,target,checks=None,event=None,page='Proxmox',tab='Průvodce VM',**kw):
    return dict(title=title,text=text,why=why,more=why+' Všechny kroky probíhají v bezpečné offline laboratoři.',hint=text,target=target,checks=checks or [],event=event or {},page=page,tab=tab,**kw)
def build():
    actions=read('data/actions_base.json')
    actions += [
      action('vm_identity','Rezervovat VMID a název',[f('id','VMID',default='101'),f('name','Název VM',default='NOVY-SERVER')]),
      action('vm_media','Vybrat instalační ISO',[vm(),c('iso','ISO image (Directory storage)',['debian.iso','windows-server.iso'])]),
      action('vm_resources','Nastavit CPU a RAM',[vm(),n('cpu','vCPU',1,min=1,max=16),n('ram_mib','RAM (MiB)',1024,min=512,max=61440,step=512)]),
      action('vm_disk','Vytvořit virtuální disk',[vm(),n('size','Disk (GiB)',16,min=8,max=1000),c('storage','Storage',['local-lvm','local-zfs','PBS'])]),
      action('vm_network','Připojit bridge a VLAN',[vm(),c('bridge','Linux bridge',['vmbr0','LAB']),n('vlan','VLAN',20,min=1,max=4094),f('ip','IPv4 /24',default='192.168.20.101')]),
      action('vm_install','Nainstalovat OS a Guest Agent',[vm()]),
    ]
    steps=[
      step('Otevři Proxmox','Klikni v serverovně na PVE-01.','Hypervisor spravuje virtuální stroje fyzického hostitele.','rack:PVE-01',event={'type':'server_selected','host':'PVE-01'},page='Serverovna',tab=''),
      step('Vyber uzel','Ve stromu Datacenter vyber PVE-01.','Nastavení uzlu a nastavení konkrétní VM jsou různé úrovně.','tree:PVE-01',event={'type':'node_selected','host':'PVE-01'},tab='Podle ticketu'),
      step('Otevři Create VM','Klikni na Create VM — průvodce.','Průvodce bude zapisovat skutečné konfigurační hodnoty VM.','wizard:create_vm',event={'type':'action_opened','action':'create_vm'},tab='Podle ticketu'),
      step('VMID a název','Zadej VMID101 a název WEB01 a rezervuj konfiguraci.','VMID je jedinečný číselný identifikátor v PVE. Existující VM nikdy nepřepisuj.','field:vm_identity:name',[g('vms.101.name','WEB01'),g('vms.101.exists',True)],{'type':'action_applied','action':'vm_identity'}),
      step('Instalační ISO','Pro VM101 vyber debian.iso a ulož jej.','ISO je obraz instalačního média. Directory storage dovoluje ISO; PBS je zálohovací cíl.','field:vm_media:iso',[g('vms.101.iso','debian.iso')],{'type':'action_applied','action':'vm_media'}),
      step('CPU a paměť','VM101 přiděl2 vCPU a4096 MiB RAM a ulož.','4096 MiB =4 GiB. Hostitel a storage potřebují vlastní paměťovou rezervu.','field:vm_resources:ram_mib',[g('vms.101.cpu',2),g('vms.101.ram',4),g('vms.101.ram_mib',4096)],{'type':'action_applied','action':'vm_resources'}),
      step('Virtuální disk','Vytvoř32GiB disk na local-lvm pro VM101.','Thin disk má logickou kapacitu; fyzické místo se spotřebovává až zápisem a musí se sledovat zvlášť.','field:vm_disk:size',[g('vms.101.disk',32),g('vms.101.storage','local-lvm')],{'type':'action_applied','action':'vm_disk'}),
      step('Virtuální síť','VM101 připoj na vmbr0, VLAN20, IP192.168.20.101.','Linux bridge propojuje virtuální síťovou kartu s fyzickým uplinkem. Samotný bridge neposkytuje DHCP ani NAT.','field:vm_network:bridge',[g('vms.101.bridge','vmbr0'),g('vms.101.vlan',20),g('vms.101.ip','192.168.20.101')],{'type':'action_applied','action':'vm_network'}),
      step('Instaluj, spusť a ověř','Dokonči instalaci OS, spusť VM101 a použij Ověřit infrastrukturu.','Start nestačí. Ověření kontroluje síťovou cestu, HTTPS a aplikační data.','action:vm_install',[g('vms.101.os_installed',True),g('vms.101.status','Running'),g('verified.vms.101',True)],targets=[{'checks':[g('vms.101.os_installed',True)],'target':'action:vm_install'},{'checks':[g('vms.101.status','Running')],'target':'action:power'},{'checks':[g('verified.vms.101',True)],'target':'action:verify'}]),
    ]
    lesson=dict(id=1002,key='pve_vm',title='Vytvoření Linux VM',category='Proxmox VE',module='Proxmox',tags=['Proxmox','Sítě'],server='PVE-01',difficulty='Začátečník',priority='Výuka',topic='VM',description='Vytvoř WEB01 / VMID101: Debian,2 vCPU,4096 MiB,32GiB local-lvm,vmbr0 VLAN20 aIP192.168.20.101. Nainstaluj OS, spusť a ověř službu.',symptoms='Nová VM ještě neexistuje.',initial_state={},available_actions=['inspect','vm_identity','vm_media','vm_resources','vm_disk','vm_network','vm_install','power','verify'],objectives=[g('vms.101.name','WEB01','WEB01 vytvořen'),g('vms.101.cpu',2,'2 vCPU'),g('vms.101.ram_mib',4096,'4096 MiB RAM'),g('vms.101.disk',32,'32GiB disk'),g('vms.101.bridge','vmbr0','Správný bridge'),g('verified.vms.101',True,'Aplikace ověřena')],steps=steps,hints=['Začni konfigurací VM na uzlu PVE-01.','Každý blok průvodce je třeba uložit do konfigurace.','ID101 / WEB01,Debian,2vCPU,4096MiB,32GiB,vmbr0 VLAN20. Pak instalace, Start a Ověření.'],explanations='Vytvořil jsi skutečnou konfiguraci VM, instaloval OS a ověřil službu. VM má vlastní kernel a čerpá prostředky hostitele.',rewards={'xp':0})
    write('data/actions.json',actions)
    write('data/training/lessons.json',[lesson])
    write('data/infrastructure/academy_defaults.json',{})
    from extension_catalog import catalog
    catalog(actions,[lesson])
if __name__=='__main__': build()
