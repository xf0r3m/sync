# Sync
Skrypt szybkiej synchronizacji katalogu zdalnego

## Instalacja
1. git clone https://git.morketsmerke.net/xf0r3m/sync.git
2. chmod +x sync/sync.sh

## Użytkowanie
1. ./sync.sh pull - pobranie danych z katalogu zdalnego do katalogu lokalnego
2. ./sync.sh push - wysłanie danych z katalogu lokalnego do katalogu zdalnego

## Uwaga
1. Przed użyciem warto spojrzeć do pliku `sync.sh`. Na jego początku znajdują się
zmienne do skonfigurowania.
2. Dla najlepszego efektu wymagane jest logowanie do SSH za pomocą klucza publicznego.
