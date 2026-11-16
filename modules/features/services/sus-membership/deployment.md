# SUS prijave na Nanou

`services.sus-membership.enable` pokreće namjenski maubot u samostalnom načinu rada.
HTTP sučelje sluša samo na `127.0.0.1:29317`; ne treba javni virtualni host ni otvoreni port.
Grav koristi vlastiti dodatak `user/plugins/sus-membership` iz repozitorija sajta.

## Prvo pokretanje

Nove datoteke modula moraju biti vidljive Git flakeu. Na Nanou, iz pripremljene radne kopije:

```sh
cd ~/nixos
nix eval --raw .#nixosConfigurations.nano.config.system.build.toplevel.drvPath
sudo nixos-rebuild switch --flake .#nano
sudo sus-membership-setup
```

Postavljanje registrira `@sus-prijave:autonomija.net` preko lokalne registracijske tajne,
stvara njegovu vlastitu sesiju i razrješava `#zahtjevi-za-clanstvo:autonomija.net` u ID sobe.
Lozinka i tokeni ne ispisuju se. Ponovno pokretanje iste naredbe čuva identitet i sesiju.
Ako je potreban poziv, pozovi bota iz Elementa; servis će prihvatiti poziv samo za konfiguriranu sobu.
Bot odbija slanje u javnu sobu ili sobu s javno čitljivom poviješću.

```sh
systemctl status sus-membership.service
sudo journalctl -u sus-membership.service -n 30 --no-pager
```

Prije postavljanja identiteta servis se preskače, a formular prikazuje da nije dostupan.
Potvrda zaprimanja znači da je prijava trajno spremljena za dostavu, ne da je osoba učlanjena.

## Nextcloud Tables

Nano uključuje aplikaciju Tables. Za botov Nextcloud račun `sus-prijave`:

```sh
sudo nextcloud-occ user:add --display-name "SUS prijave" sus-prijave
```

Iz ažurirane radne kopije na Nanou pokreni postavljanje tablice; ova naredba ne
zahtijeva prethodni rebuild:

```sh
cd ~/nixos
sudo nix run path:.#nixosConfigurations.nano.config.system.build.sus-membership-tables-setup -- --share-user root --share-user k
```

Postavljanje stvara aplikacijsku lozinku bez pristupa prijavnoj lozinci te sprema
vjerodajnice, ID tablice i ID-eve stupaca u
`/var/lib/sus-membership-secrets/nextcloud.json` (samo root, način `0600`).
Token se ne ispisuje. Račun mora postojati, kao i svi primatelji dijeljenja.

Bot je vlasnik tablice `SUS · prijave za članstvo`. Samo navedeni korisnici dobivaju
ovlasti čitanja, dodavanja i uređivanja redaka; ne mogu brisati retke ni upravljati
tablicom. Pripremljeni su stupci prijave, status (`Novo`), zadužena osoba i bilješke.
ID prijave ima ograničenje jedinstvenosti.

Ponovljeno postavljanje koristi iste vjerodajnice, tablicu i stupce te može nastaviti
nakon prekida. Postojeće dijeljenje s drugim korisnicima zaustavlja postavljanje
umjesto automatskog mijenjanja ovlasti. Nestala tablica ili neusklađen račun ne
uzrokuju automatsko stvaranje zamjenskog odredišta.

Automatsku dostavu uključuje `services.sus-membership.tables.enable = true`;
na Nanou je uključena. Prije aktivacije mora postojati prethodno pripremljena
datoteka `nextcloud.json`, koju systemd prenosi servisu kao vjerodajnicu. Nakon
postavljanja tablice aktiviraj novu konfiguraciju:

```sh
sudo nixos-rebuild switch --flake path:.#nano
```

Svaka nova prijava ide u tablicu i u postojeću Matrix sobu. Datum koristi
vremensku zonu `Europe/Zagreb`; početni status je `Novo`. Poruka se u stupac
bogatog teksta upisuje uz HTML escaping kako se korisnički unos ne bi tumačio kao
HTML. Ponovni pokušaj traži postojeći ID prijave i ne mijenja redak, uključujući
ručno uređene podatke, status, zaduženu osobu i bilješke.

Dostava ima zasebno praćenje i odgodu ponovnog pokušaja za Matrix i Tables.
Nedostupnost jednog odredišta ne sprječava dostavu drugome. Sadržaj se briše iz
reda tek kada oba odredišta potvrde primitak. Postojeće nedostavljene prijave
pri prvom pokretanju također se šalju u Tables. Ranije dostavljene prijave nemaju
sačuvan sadržaj i ne mogu se automatski popuniti u tablicu. Ne isključuj Tables
dok postoje prijave koje čekaju dostavu u to odredište.

## Enkripcija

Ciljna soba trenutačno nije šifrirana, pa je `requireEncryption = false`.
Bot se gradi bez `libolm`: trenutačni Nixpkgs tu biblioteku blokira kao nesigurnu.
Nije dodana iznimka za nesigurne pakete.

Ako se soba naknadno šifrira, prijave ostaju u redu dok bot nema kriptografsku podršku.
Bot nikad ne šalje običan tekst u sobu koju prepozna kao šifriranu.
`requireEncryption = true` zahtijeva E2EE i kriptografske ovisnosti; prije uporabe treba
riješiti navedeno ograničenje maubota. Samo uključivanje opcije na trenutačnom Nixpkgsu nije dovoljno.

## Pohrana

- `/var/lib/sus-membership-secrets/`: identitet, pristupni token i lozinka; samo root.
- `/var/lib/sus-membership-auth/token`: lokalna tajna; root i PHP korisnik `sus-grav`.
- `/var/lib/sus-membership/`: trajna baza maubota i `outbox.sqlite`; samo servisni korisnik.
- `/run/sus-membership/`: privremena konfiguracija, izrađena iz systemd vjerodajnica.

Potvrđena dostava u sva uključena odredišta briše sadržaj prijave iz reda, uz SQLite `secure_delete`.
Sažetak prijave i HMAC adrese klijenta ostaju za provjeru duplikata i ograničenje učestalosti;
zapisi dostavljenih prijava stariji od sedam dana uklanjaju se pri idućoj predaji.
Neuspjele dostave čuvaju sadržaj i ponavljaju se s rastućom odgodom do jednog sata.
Red ima najviše 1000 nedostavljenih prijava; isti klijent može predati pet prijava na sat.
Ograničenje koristi adresu koju PHP dobije od Nginxa, bez povjerenja u zaglavlja klijenta.

Sadržaj prijava ne zapisuje se u servisne logove i ne pripada Git repozitoriju.
Ne briši bazu dok postoje nedostavljene prijave. Za trajnu kopiju identiteta i baze treba
koristiti zaštićenu sigurnosnu kopiju; ovaj modul ne dodaje nešifrirane arhive osobnih podataka.

## Provjera

`test_membership.py` provjerava red, nadogradnju postojeće baze, duplikate,
validaciju, autentikaciju, neovisnu ponovnu dostavu i odabir šifriranog slanja.
Testovi koriste lokalne lažne Matrix klijente. `test_tables.py` provjerava stvarne
HTTP zahtjeve prema lokalnom testnom poslužitelju, oporavak nakon izgubljenog
odgovora, straničenje, HTML escaping i očuvanje ručnih izmjena.
Za provjeru cijelog toka koristi testni Matrix endpoint i zasebne vjerodajnice.
Stvarnu dostavu i ovlasti ciljane sobe treba provjeriti nakon aktivacije.
