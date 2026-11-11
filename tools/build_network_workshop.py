"""Deterministic standalone workshop catalogue; legacy/classroom data stay intact."""
import json
from pathlib import Path

ROWS = [
    ('A', 'PC 04 bez linky', 1, 'základní', 'linka a brána',
     'Po údržbě je PC 04 bez linky. PC 02 musí zůstat v provozu.',
     'PC 04 vede ze Z04 přes PP04 na vadný port 08.',
     ['link', 'gateway', 'control'], ['link'], ['cable'],
     'Porovnej linku PC 04 a PC 02; projdi Z04 → PP04 → switch.',
     'Přepoj PP04 do volného funkčního portu VLAN 10. Port 08 je vadný.'),
    ('B', 'Zásuvka ve špatné VLAN', 2, 'základní', 'DHCP ve VLAN 10',
     'PC 04 svítí linka, ale po údržbě nezíská pronájem. Hostovská větev VLAN 20 musí zůstat oddělená.',
     'Klientský port 04 je ve VLAN 20.',
     ['dhcp', 'link', 'control'], ['dhcp'], ['vlan', 'cable'],
     'Porovnej linku, obsazený port a jeho VLAN; zachyť DHCP Discover.',
     'Přiřaď port PC 04 do VLAN 10 nebo přepoj na volný port VLAN 10; port 05 zůstává VLAN 20.'),
    ('C', 'DHCP po změně rozsahu', 2, 'střední', 'úplný pronájem DHCP',
     'Linka a VLAN fungují. Po změně rozsahu PC 04 nedostane nabídku DHCP. Požadujeme dynamickou adresu, masku, bránu a DNS.',
     'Rozsah .20–.49 je vyčerpaný.',
     ['dhcp', 'link', 'gateway', 'control'], ['dhcp'], ['pool', 'static'],
     'Zachyť výměnu DHCP a zjisti, zda přichází Offer.',
     'Uvolni laboratorní rozsah .20–.49 a obnov pronájem. Statická adresa DHCP neopravuje.'),
    ('D', 'Stará ARP položka po výměně brány', 2, 'střední', 'místní a vzdálená cesta',
     'Brána byla vyměněna: nová MAC 02:00:00:00:10:11. Tiskárna funguje, vzdálený cíl ne. Porovnej cache se štítkem.',
     'Cache PC 04 stále uvádí starou MAC brány 02:00:00:00:10:01.',
     ['arp', 'printer', 'gateway', 'control'], ['gateway', 'arp'], ['arp'],
     'Porovnej cache 192.168.10.1 s MAC na štítku nové brány; tiskárnu měř zvlášť.',
     'Vymaž pouze souseda 192.168.10.1. Zachyť novou ARP odpověď a ověř tiskárnu i vzdálený cíl.'),
    ('E', 'Portál se přestěhoval', 1, 'střední', 'HTTPS podle jména',
     'Portál se přesunul na 203.0.113.20. DNS správce uvádí nový záznam, PC 04 stále otevírá starou adresu.',
     'Cache klienta drží 203.0.113.19, autoritativní záznam už je 203.0.113.20.',
     ['dns', 'https', 'control'], ['dns'], ['dns', 'flush'],
     'Porovnej DNS záznam a cache klienta při stejném dotazu.',
     'Obnov cache PC 04 a otevři portal.example.com přes HTTPS.'),
    ('F', 'DNS odpovídá, HTTPS selže', 2, 'střední', 'TCP 443 a HTTPS',
     'Portál má správný DNS záznam, ale HTTPS neodpovídá. Ostatní laboratorní pravidla musí zůstat zachována.',
     'Služba TCP/HTTPS na portu 443 je vypnutá.',
     ['gateway', 'dns', 'tcp', 'https', 'control'], ['dns', 'tcp'], ['tcp', 'https_rule', 'management'],
     'Porovnej dosažitelnost brány, DNS odpověď a TCP SYN na port 443.',
     'Spusť službu HTTPS. Povolení správy ani změna všech pravidel není opravou.'),
    ('G', 'Wi-Fi v zadní části dílny', 2, 'střední', 'pokrytí, DHCP a HTTPS',
     'Kabelová kontrolní stanice funguje. U W2 v zadní části vypadává Wi-Fi. Porovnej W1 a W2 a uprav polohu AP.',
     'AP je na předním úchytu; W2 má −84 dBm.',
     ['near', 'far', 'control'], ['near', 'far'], ['ap'],
     'Změř W1 i W2; rozliš signál, připojení, přidělení IP a dostupnost služby.',
     'Přesuň AP na středový úchyt. Nově změř oba body a kabelové PC 02.'),
    ('H', 'Závěrečná servisní směna', 2, 'pokročilá', 'síťová cesta a portál',
     'Po údržbě PC 04 nezíská síť a portál se přestěhoval na 203.0.113.20. Obnov HTTPS podle jména. Tiskárna i PC 02 musí zůstat funkční. Ticket zakonči příčinami a důkazy.',
     'Port PC 04 je ve VLAN 20 a autoritativní DNS stále vrací 203.0.113.19.',
     ['dhcp', 'link', 'dns', 'tcp', 'https', 'printer', 'control'], ['dhcp', 'dns'], ['vlan', 'cable', 'dns', 'flush'],
     'Začni linkou, VLAN a DHCP. Po zprovoznění cesty změř překlad jména.',
     'Oprav VLAN PC 04, obnov DHCP, oprav záznam A a cache; dolož HTTPS, tiskárnu a kontrolní PC.'),
]

def catalogue():
    tasks = []
    for key, title, year, difficulty, service, ticket, cause, goals, before, actions, hint, review in ROWS:
        initial = dict(scenario=key, seed=0, socket='Z04', patch='PP04',
                       ports=dict(router=1, resolver=2, pc02=3, pc04=4, printer=7),
                       vlans={str(port): (20 if port == 5 else 10) for port in range(1, 9)},
                       dhcp_pool=True, dns_record='203.0.113.20', dns_cache='',
                       gateway_mac='02:00:00:00:10:01', arp_cache={}, tcp_enabled=True,
                       ap_position='center')
        if key == 'A': initial['ports']['pc04'] = 8
        if key in ['B', 'H']: initial['vlans']['4'] = 20
        if key == 'C': initial['dhcp_pool'] = False
        if key == 'D':
            initial['gateway_mac'] = '02:00:00:00:10:11'
            initial['arp_cache']['192.168.10.1'] = '02:00:00:00:10:01'
        if key == 'E': initial['dns_cache'] = '203.0.113.19'
        if key == 'F': initial['tcp_enabled'] = False
        if key == 'G': initial['ap_position'] = 'front'
        if key == 'H': initial['dns_record'] = '203.0.113.19'
        tasks.append(dict(id=key, title=title, year=year, difficulty=difficulty,
                          service=service, ticket=ticket, cause=cause,
                          initial=initial,
                          actions=actions, goals=goals, before=before,
                          side_services=['PC 02', 'VLAN 20 na portu 05'],
                          hint=hint, review=review))
    return dict(version=1, offline=True, tasks=tasks)

if __name__ == '__main__':
    target = Path(__file__).resolve().parents[1] / 'data/network_lab/workshop.json'
    target.write_text(json.dumps(catalogue(), ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print('Workshop: 8 deterministic tickets')
