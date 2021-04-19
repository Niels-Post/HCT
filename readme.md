HWLIB-Cmake-Tools
========
HCT is een CMake project waarmee je CLion's autocomplete features kan gebruiken met projecten gemaakt met HWLIB en BMPTK


Installatie
---
Installeer de omgeving met het python script van de docent. 
Zorg dat je het script voor de path-variable ook uitvoert. 

Stel in CLion je toolchain in op de Mingw map in je buildomgeving. Deze heet als het goed is "i686-7.3.0-release-posix-dwarf-rt_v5-rev0\mingw32"

Kopiëer Voorbeeld_CMakeLists.txt naar je eigen project en noem deze CMakeLists.txt. 
Open de map met CLion. Wanneer je de CMakeLists.txt laadt (rightclick->Load CMake Project), gaat HCT op zoek naar HWLIB makefiles en laadt deze. 
