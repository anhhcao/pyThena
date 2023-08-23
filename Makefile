# See the README.md notes on how to use this Makefile

#
SHELL = /bin/bash

#
TIME = /usr/bin/time

# use python3 or anaconda3
PYTHON = anaconda3

# git directories we should have here

GIT_DIRS = athenak

# URLs that we'll need

URL0  = https://github.com/teuben/Athena-Cversion
URL1  = https://github.com/PrincetonUniversity/athena
URL2  = https://gitlab.com/theias/hpc/jmstone/athena-parthenon/athenak
URL2  = https://gitlab.com/theias/hpc/jmstone/athena-parthenon/athena-mini-k
URL2  = https://github.com/teuben/Athena-miniK
URL3  = https://github.com/teuben/nemo

# the ATHENA executable (from athena or athenak)
# ATHENA = athena/bin/athena
ATHENA = athenak/build/src/athena

.PHONY:  help install build


install: help
	@echo "These are some make targets we advertise. See Makefile for details"

help:
## help:          This Help
help : Makefile
	@sed -n 's/^##//p' $<


## git:           Get all git repos for this install
git:  $(GIT_DIRS)
	@echo Last git: `date` >> git.log

## pull:          Update all git repos
pull:
	@echo -n "lmtoy: "; git pull
	-@for dir in $(GIT_DIRS); do\
	(echo -n "$$dir: " ;cd $$dir; git pull); done
	@echo Last pull: `date` >> git.log

status:
	@echo -n "lmtoy: "; git status -uno
	-@for dir in $(GIT_DIRS); do\
	(echo -n "$$dir: " ;cd $$dir; git status -uno); done

branch:
	@echo -n "lmtoy: "; git branch --show-current
	-@for dir in $(GIT_DIRS); do\
	(echo -n "$$dir: " ;cd $$dir; git branch --show-current); done

athenac:
	git clone $(URL0) -b teuben1 athenac
	$(MAKE) build_athenac

athena:
	git clone $(URL1)
	$(MAKE) build_athena

athenak:
	git clone --recursive $(URL2) athenak

nemo:
	git clone $(URL3)

python: nemo anaconda3

anaconda3:
	nemo/src/scripts/install_anaconda3


## build_athenak:  build athenak
build_athenak:	athenak
	(mkdir -p athenak/build; cd athenak/build; cmake ..; make -j 8)

# See also:   https://kokkos.github.io/kokkos-core-wiki/keywords.html#keywords-arch
B_ARM = -D CMAKE_CXX_COMPILER=clang++-mp-15 -D CMAKE_C_COMPILER=clang-mp-15 -D Kokkos_ARCH_ARMV81=On
arm:	athenak
	(mkdir -p athenak/build; cd athenak/build; cmake $(B_ARM) ..; make -j 8)

#PJT =  -D CMAKE_CXX_COMPILER=clang++ -D CMAKE_C_COMPILER=clang -D Kokkos_ARCH_INTEL_DG1=On
#PJT =  -D Kokkos_ARCH_INTEL_DG1=On
PJT =  -D Kokkos_ENABLE_OPENMP=On
#PJT =  -D Athena_ENABLE_MPI=ON
pjt:	athenak
	(mkdir -p athenak/build; cd athenak/build; cmake $(PJT) ..; make -j 8)

## build_athena    build athena++ for the linear_wave problem
build_athena: athena
	(cd athena; ./configure.py --prob linear_wave; make clean; make -j)

## build_athenac   build AthenaC for the linear_wave problem
build_athenac: athenac
	(cd athenac; autoconf;  ./configure; make all)

## build_nemo:     build nemo - will also build classic tkrun
build_nemo:    nemo
	(cd nemo; ./configure ; make build check)

## build_python:    build your private anaconda3
build_python:  python

# a few sample benchmark runs

##

## run1:          example 1D linear_wave_hydro (athenak)   [ < 1sec  1069 cycles]
run1:
	$(TIME) $(ATHENA) -i athenak/inputs/linear_wave_hydro.athinput -d run1
	@echo ./animate1 base=run1/tab/LinWave xcol=x1v ycol=velx

## run2:          example 2D orszag_tang (athenak) [ ~109"  1403 cycles]
run2:
	$(TIME) $(ATHENA) -i athenak/inputs/orszag_tang.athinput      -d run2
	@echo ./animate1 base=run2/tab/Advect xcol=x1v ycol=dens



## 

test0:
	./z1.sh

## test1:         old tkrun via arun1
test1:
	./arun1.py athinput.linear_wave1d > test1.sh
	tkrun test1.sh

test2:
	./arun1.py linear_wave_hydro.athinput > test2.sh
	tkrun test2.sh

test3:
	pyuic5 -x test3.ui  -o test3.py
	python test3.py

test4:
	python pysimplegui.py

## test5:         native pyqt, tkrun style
test5:
	python pyqt.py testfile

test6:
	python pyqt.py testfile2

## test7:         qooey, athena style
test7:
	./gooey_run2.py linear_wave_hydro.athinput

# will try Qt first, else fall back to tkinter
test8:
	./pysg_run.py athinput.linear_wave1d

test9: 	ran2
	./plot1d.py -d ran2

test10:
	./pysg_run.py test.athinput

test11:
	./pyqt_run.py test.athinput

# will run the plot when run is clicked
## test12:        pyqt native, athena style
test12:
	./pyqt_run.py athinput.linear_wave1d

## test13:        pysg, athena style
test13: athena_problems.json
	./pysg_menu.py

## test14:        pyqt, athena style
test14: athena_problems.json
	./pyqt_menu.py

## test15:        mini-k version
test15:
	./pythena.py

