HWLIB-Cmake-Tools
========
CMake file that allows for smart code completion with HWLIB

**NOTE: Does not actually build using CMake, but calls the makefile instead**


Usage
---
Include HCT.cmake and set ${HCT} to this directory. 
Call add_hwlib_bmptk_target with:
- `Name` of the target to make
- `Path` to the main directory of the target
- Name of the target's `makefile`