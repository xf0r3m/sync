# Sync
Skrypt synchronizacji katalogu zdalnego oparty na systemie kontroli wersji Git.

## Instalacja
1. git clone https://github.com/xf0r3m/sync.git
2. sudo cp sync/sync.sh /usr/local/bin
3. mkdir ~/.sync.d
4. cp sync/sync.d/sync.conf ~/.sync.d
5. vim ~/.sync.d/sync.conf

## Konfiguracja
```
LDIR="bezwzględna_scieżka_katalogu_lokalnego";
RDIR="bezwzględna_scieżka_katalogu_zdalnego";
RUSER="zdalny_użytkownik";
RSERVER="adres_serwera";
KEYFILE="bezwzględna_sciezka_do_klucza_prywatnego";
SSHOPTS="dodatkowe_opcje_SSH -i ${KEYFILE}";
export GIT_SSH_COMMAND="ssh ${SSHOPTS}";
```

## Użytkowanie
1. ./sync.sh
Dobry pomysłem jest uruchamienie polecenia przez `cron` lub poprzez polecenie
`watch`, aby synchronizacja odbywała się regularnie, co jakiś czas. 

## Uwaga
1. Przed użyciem należy uzupełnić plik konfiguracyjny.
2. Wymagane jest użycie PKI do uwierzytelnia.
