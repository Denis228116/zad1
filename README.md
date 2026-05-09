                                            Temat: Konfiguracja łańcucha CI/CD w usłudze GitHub Actions

1.	Cel zadania
Celem zadania było opracowanie zautomatyzowanego łańcucha (pipeline) w usłudze GitHub Actions. Łańcuch ten ma za zadanie budować obraz kontenera na podstawie kodu źródłowego aplikacji pogodowej, przeprowadzać testy bezpieczeństwa oraz przesyłać gotowy obraz do zewnętrznych rejestrów (GitHub Packages oraz Docker Hub).

2.	Konfiguracja środowiska i sekretów

Przed uruchomieniem workflow, w ustawieniach repozytorium GitHub (Settings > Secrets and variables > Actions) skonfigurowano niezbędne poświadczenia. Wykorzystano Personal Access Token z Docker Hub, aby umożliwić bezpieczne przesyłanie danych cache.
•	DOCKERHUB_USERNAME: Nazwa użytkownika w serwisie Docker Hub.
•	DOCKERHUB_TOKEN: Token dostępu (Access Token) generowany w celach bezpieczeństwa.
<img width="1280" height="631" alt="зображення" src="https://github.com/user-attachments/assets/66d22980-8705-4f38-ae09-6cb234c6b94b" />
<img width="1280" height="621" alt="зображення" src="https://github.com/user-attachments/assets/d9aecdf9-a62f-4bb0-bc0d-6a9975098cc3" />

3.	Plik konfiguracyjny Workflow (ci.yml)
Zdefiniowany plik .github/workflows/ci.yml zawiera instrukcje dla GitHub Actions. Kluczowe elementy to:
•	Buildx & QEMU: Narzędzia umożliwiające budowanie obrazów Multi-arch.
•	Trivy: Skaner podatności CVE.
•	Cache Registry: Przechowywanie warstw budowania na Docker Hub w celu optymalizacji czasu pracy.
<img width="1263" height="1280" alt="зображення" src="https://github.com/user-attachments/assets/6d70109f-d89b-42f0-ba78-327cade999c1" />
<img width="1188" height="1280" alt="зображення" src="https://github.com/user-attachments/assets/a50ff164-3890-43a6-b6c4-2c108e5830f9" />
<img width="1280" height="725" alt="зображення" src="https://github.com/user-attachments/assets/a5fd556c-f7b6-4457-acab-02f31d71cb19" />
Opis działania łańcucha CI/CD (ci.yml)

Plik konfiguracyjny automatyzuje cały proces budowania i wysyłania obrazu. Działa on w oparciu o następujące kroki:

    Wyzwalacze (Triggers): Pipeline uruchamia się automatycznie po wypchnięciu zmian (push) na gałąź main lub można go wywołać ręcznie (workflow_dispatch).

    Przygotowanie (Kroki 1-2): Akcja pobiera kod źródłowy repozytorium oraz konfiguruje środowisko Buildx i emulator QEMU. Jest to niezbędne, aby móc zbudować obraz na dwie różne architektury sprzętowe (ARM i AMD).

    Logowanie (Kroki 3-4): Skrypt uwierzytelnia się w dwóch miejscach: w rejestrze GitHub (ghcr.io), dokąd trafi gotowy obraz, oraz w DockerHub, który służy wyłącznie do przechowywania pamięci podręcznej (cache).

    Metadane i Tagi (Krok 5): Automatycznie generuje tagi dla obrazów. Wykorzystano bezpieczne tagowanie oparte na skrótach commitów (SHA) oraz standardowy tag latest.

    Skanowanie bezpieczeństwa (Kroki 6-7): Najpierw budowany jest lokalny, testowy obraz, który następnie jest analizowany przez skaner Trivy. Narzędzie sprawdza biblioteki pod kątem podatności typu HIGH i CRITICAL.

    Budowa Multi-arch i Push (Krok 8): Finalny etap, w którym Docker buduje docelowy obraz na platformy linux/amd64 i linux/arm64. Gotowy obraz zostaje wypchnięty na GitHub Packages, a pliki tymczasowe (cache) lądują na DockerHub (w trybie mode=max, co znacznie przyspieszy kolejne uruchomienia).

4.	Skanowanie bezpieczeństwa (Trivy)
Zgodnie z wymaganiami, zaimplementowano krok skanowania obrazu pod kątem luk
bezpieczeństwa. Skaner Trivy sprawdza biblioteki systemowe oraz aplikacyjne. W przypadku wykrycia błędów o priorytecie CRITICAL lub HIGH, proces może zostać przerwany, co gwarantuje bezpieczeństwo końcowego produktu.

<img width="1907" height="847" alt="зображення" src="https://github.com/user-attachments/assets/b0c184d6-84f0-43c8-baae-6f5f11d41d43" />
<img width="1280" height="744" alt="зображення" src="https://github.com/user-attachments/assets/8cdbe63d-758a-48fc-9b14-28cc44d8ed63" />

5.	Rezultat: Obrazy Multi-arch

Wynikiem działania łańcucha jest obraz przesłany do GitHub Container Registry (ghcr.io). Obraz został zbudowany dla dwóch architektur procesorowych jednocześnie:
•	linux/amd64 (standardowe serwery/PC)
•	linux/arm64 (np. urządzenia z procesorami Apple Silicon lub Raspberry Pi)
  <img width="1024" height="495" alt="зображення" src="https://github.com/user-attachments/assets/eb07a8d7-60de-4f23-b85c-12c495792b37" />

6.	Pamięć podręczna (Docker Hub Cache)
W celu przyspieszenia kolejnych wywołań pipeline'u, wykorzystano zewnętrzny cache przechowywany w dedykowanym repozytorium na Docker Hub. Dzięki trybowi max, wszystkie warstwy pośrednie są buforowane.
<img width="1280" height="736" alt="зображення" src="https://github.com/user-attachments/assets/8198dbab-1ead-4ee3-ad3d-01a62a5cdde7" />
<img width="1280" height="668" alt="зображення" src="https://github.com/user-attachments/assets/4079d5f7-72cd-4aba-a1dc-e39fc12cbbad" />

7.	Podsumowanie i wnioski

Zadanie zostało wykonane pomyślnie. Udało się zintegrować aplikację z Zadania 1 z nowoczesnym systemem CI/CD. Wykorzystanie GitHub Actions pozwala na pełną automatyzację procesu dostarczania oprogramowania, dbając jednocześnie o optymalizację (cache) i bezpieczeństwo (skanowanie CVE). Wybrany schemat tagowania oparty na SHA commitu zapewnia pełną identyfikowalność obrazów w środowisku produkcyjnym.


