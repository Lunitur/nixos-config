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

Potvrđena dostava briše sadržaj prijave iz reda, uz SQLite `secure_delete`.
Sažetak prijave i HMAC adrese klijenta ostaju za provjeru duplikata i ograničenje učestalosti;
zapisi dostavljenih prijava stariji od sedam dana uklanjaju se pri idućoj predaji.
Neuspjele dostave čuvaju sadržaj i ponavljaju se s rastućom odgodom do jednog sata.
Red ima najviše 1000 nedostavljenih prijava; isti klijent može predati pet prijava na sat.
Ograničenje koristi adresu koju PHP dobije od Nginxa, bez povjerenja u zaglavlja klijenta.

Sadržaj prijava ne zapisuje se u servisne logove i ne pripada Git repozitoriju.
Ne briši bazu dok postoje nedostavljene prijave. Za trajnu kopiju identiteta i baze treba
koristiti zaštićenu sigurnosnu kopiju; ovaj modul ne dodaje nešifrirane arhive osobnih podataka.

## Provjera

`test_membership.py` provjerava red, duplikate, validaciju, autentikaciju, ponovnu dostavu
i odabir šifriranog slanja. Testovi koriste lokalne lažne Matrix klijente.
Za provjeru cijelog toka koristi testni Matrix endpoint i zasebne vjerodajnice.
Stvarnu dostavu i ovlasti ciljane sobe treba provjeriti nakon aktivacije.
