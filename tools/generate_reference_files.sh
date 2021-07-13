#!/bin/bash


if grep "OCTOTIGER_WITH_GRIDDIM=8" build-octotiger.sh
then
  echo "build-octotiger.sh with correct griddim found! Proceeding..."
else
  echo "ERROR: build-octotiger.sh not found in current directory or does not include -DOCTOTIGER_WITH_GRIDDIM=8"
  exit 1
fi

echo ""
echo "NOTE:"
echo " --> This script regenerates all reference silo data used for the tests and stores them in $(pwd)/new-testdata!"
echo " --> It will further generate some useful cmake snippets to update the analytics ctests in test_problems/*/CMakeLists.txt"
echo " --> It is up to YOU to verify the new test data, move them the testing submodule and to insert the cmake snippets in the test_problems/*/CMakeLists.txt files."
echo " --> The script assumes to be run in the root directory of the octotiger buildscripts (found here https://github.com/STEllAR-GROUP/OctoTigerBuildChain) "
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 0
fi
echo ""
echo "WARNING:"
echo "--> This script will now delete all old .log .silo files and cmake_snippets.txt in the current directory!"
echo "--> It will delete the new-testdata directory if it already exists!"
echo "--> It will delete the build/octotiger/build directory to create a fresh build using the current octotiger commit/changes in src/octotiger!"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 0
fi

echo "Deleting any old logs, silo files and snippets..."
rm cmake_snippets
rm *.log
rm *.silo
rm -rf new-testdata
rm -rf build/octotiger/build

echo "Building with griddim=8..."
./build-all.sh RelWithDebInfo without-cuda with-mpi without-papi without-apex

echo "Creating rotating_star reference data with and without am correction..."
./build/octotiger/build/tools/gen_rotating_star_init > /dev/null
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/rotating_star/rotating_star.ini --correct_am_hydro=1 --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > rotating_star_with_am.log
cp final.silo.data/0.silo rotating_star_with_am.silo
rm -rf final.silo final.silo.data
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/rotating_star/rotating_star.ini --correct_am_hydro=0 --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > rotating_star_without_am.log
cp final.silo.data/0.silo rotating_star_without_am.silo
rm -rf final.silo final.silo.data

echo "Creating blast reference data with and without am correction..."
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/blast/blast.ini --correct_am_hydro=1 --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > blast_with_am.log
cp final.silo.data/0.silo blast_with_am.silo
rm -rf final.silo final.silo.data
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/blast/blast.ini --correct_am_hydro=0 --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > blast_without_am.log
cp final.silo.data/0.silo blast_without_am.silo
rm -rf final.silo final.silo.data

echo "Creating sod reference data  without am correction..."
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/sod/sod.ini --correct_am_hydro=0 --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > sod_without_am.log
cp final.silo.data/0.silo sod_without_am.silo
rm -rf final.silo final.silo.data

echo "Creating solid sphere reference data..."
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/sphere/sphere.ini --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > sphere.log
cp final.silo.data/0.silo sphere.silo
rm -rf final.silo final.silo.data

echo "Creating marshak sphere reference data..."
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/marshak/marshak.ini --correct_am_hydro=0 --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > marshak.log
cp final.silo.data/0.silo marshak.silo
rm -rf final.silo final.silo.data

echo "Copying reference files..."
mkdir -p new-testdata
cp blast_with_am.silo new-testdata/blast_with_am.silo
cp blast_without_am.silo new-testdata/blast_without_am.silo
cp rotating_star_with_am.silo new-testdata/rotating_star_with_am.silo
cp rotating_star_without_am.silo new-testdata/rotating_star_without_am.silo
cp sod_without_am.silo new-testdata/sod_without_am.silo
cp sphere.silo new-testdata/sphere.silo
cp marshak.silo new-testdata/marshak.silo


sed -i 's/GRIDDIM=8/GRIDDIM=16/' build-octotiger.sh
echo "Building with griddim=16..."
./build-all.sh RelWithDebInfo without-cuda with-mpi without-papi without-apex octotiger
sed -i 's/GRIDDIM=16/GRIDDIM=8/' build-octotiger.sh

echo "Creating rotating_star reference data griddim=16 with and without am correction..."
./build/octotiger/build/tools/gen_rotating_star_init > /dev/null
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/rotating_star/rotating_star.ini --correct_am_hydro=1 --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > rotating_star16_with_am.log
cp final.silo.data/0.silo rotating_star16_with_am.silo
rm -rf final.silo final.silo.data
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/rotating_star/rotating_star.ini --correct_am_hydro=0 --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > rotating_star16_without_am.log
cp final.silo.data/0.silo rotating_star16_without_am.silo
rm -rf final.silo final.silo.data

echo "Creating blast reference data griddim=16 with and without am correction..."
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/blast/blast.ini --correct_am_hydro=1 --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > blast16_with_am.log
cp final.silo.data/0.silo blast16_with_am.silo
rm -rf final.silo final.silo.data
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/blast/blast.ini --correct_am_hydro=0 --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > blast16_without_am.log
cp final.silo.data/0.silo blast16_without_am.silo
rm -rf final.silo final.silo.data

echo "Creating sod reference data griddim=16  without am correction..."
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/sod/sod.ini --correct_am_hydro=0 --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > sod16_without_am.log
cp final.silo.data/0.silo sod16_without_am.silo
rm -rf final.silo final.silo.data

echo "Creating solid sphere reference data griddim=16..."
./build/octotiger/build/octotiger --config_file=src/octotiger/test_problems/sphere/sphere.ini --p2p_kernel_type=OLD --p2m_kernel_type=OLD --multipole_kernel_type=OLD > sphere16.log
cp final.silo.data/0.silo sphere16.silo
rm -rf final.silo final.silo.data

echo "Creating cmake snippets and writing to cmake_snippets.txt..."
echo "" | tee cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "For file test_problems/rotating_star/CMakeLists.txt" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "Subgridsize 8, with correct_am_hydro=1" | tee -a cmake_snippets.txt
echo "Snippet:" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt
echo "if (OCTOTIGER_WITH_GRIDDIM EQUAL 8)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat rotating_star_with_am.log | grep "rho " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat rotating_star_with_am.log | grep "egas " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat rotating_star_with_am.log | grep "tau " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat rotating_star_with_am.log | grep "pot " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat rotating_star_with_am.log | grep "sx " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sy_regex \"$(cat rotating_star_with_am.log | grep "sy " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sz_regex \"$(cat rotating_star_with_am.log | grep "sz " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zx_regex \"$(cat rotating_star_with_am.log | grep "zx " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat rotating_star_with_am.log | grep "zy " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat rotating_star_with_am.log | grep "zz " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat rotating_star_with_am.log | grep "spc_1 " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat rotating_star_with_am.log | grep "spc_2 " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat rotating_star_with_am.log | grep "spc_3 " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat rotating_star_with_am.log | grep "spc_4 " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat rotating_star_with_am.log | grep "spc_5 " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"rotating_star_with_am.silo\")" | tee -a cmake_snippets.txt
echo "elseif (OCTOTIGER_WITH_GRIDDIM EQUAL 16)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat rotating_star16_with_am.log | grep "rho " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat rotating_star16_with_am.log | grep "egas " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat rotating_star16_with_am.log | grep "tau " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat rotating_star16_with_am.log | grep "pot " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat rotating_star16_with_am.log | grep "sx " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sy_regex \"$(cat rotating_star16_with_am.log | grep "sy " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sz_regex \"$(cat rotating_star16_with_am.log | grep "sz " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zx_regex \"$(cat rotating_star16_with_am.log | grep "zx " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat rotating_star16_with_am.log | grep "zy " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat rotating_star16_with_am.log | grep "zz " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat rotating_star16_with_am.log | grep "spc_1 " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat rotating_star16_with_am.log | grep "spc_2 " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat rotating_star16_with_am.log | grep "spc_3 " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat rotating_star16_with_am.log | grep "spc_4 " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat rotating_star16_with_am.log | grep "spc_5 " | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"none\")" | tee -a cmake_snippets.txt
echo "else()" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "Subgridsize 8, with correct_am_hydro=0" | tee -a cmake_snippets.txt
echo "Snippet:" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt
echo "if (OCTOTIGER_WITH_GRIDDIM EQUAL 8)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat rotating_star_without_am.log | grep "rho " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat rotating_star_without_am.log | grep "egas " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat rotating_star_without_am.log | grep "tau " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat rotating_star_without_am.log | grep "pot " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat rotating_star_without_am.log | grep "sx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sy_regex \"$(cat rotating_star_without_am.log | grep "sy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sz_regex \"$(cat rotating_star_without_am.log | grep "sz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zx_regex \"$(cat rotating_star_without_am.log | grep "zx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat rotating_star_without_am.log | grep "zy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat rotating_star_without_am.log | grep "zz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat rotating_star_without_am.log | grep "spc_1 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat rotating_star_without_am.log | grep "spc_2 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat rotating_star_without_am.log | grep "spc_3 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat rotating_star_without_am.log | grep "spc_4 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat rotating_star_without_am.log | grep "spc_5 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"rotating_star_without_am.silo\")" | tee -a cmake_snippets.txt
echo "elseif (OCTOTIGER_WITH_GRIDDIM EQUAL 16)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat rotating_star16_without_am.log | grep "rho " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat rotating_star16_without_am.log | grep "egas " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat rotating_star16_without_am.log | grep "tau " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat rotating_star16_without_am.log | grep "pot " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat rotating_star16_without_am.log | grep "sx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sy_regex \"$(cat rotating_star16_without_am.log | grep "sy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sz_regex \"$(cat rotating_star16_without_am.log | grep "sz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zx_regex \"$(cat rotating_star16_without_am.log | grep "zx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat rotating_star16_without_am.log | grep "zy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat rotating_star16_without_am.log | grep "zz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat rotating_star16_without_am.log | grep "spc_1 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat rotating_star16_without_am.log | grep "spc_2 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat rotating_star16_without_am.log | grep "spc_3 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat rotating_star16_without_am.log | grep "spc_4 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat rotating_star16_without_am.log | grep "spc_5 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"none\")" | tee -a cmake_snippets.txt
echo "else()" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "For file test_problems/blast/CMakeLists.txt" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "Subgridsize 8, with correct_am_hydro=1" | tee -a cmake_snippets.txt
echo "Snippet:" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt
echo "if (OCTOTIGER_WITH_GRIDDIM EQUAL 8)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat blast_with_am.log | grep "rho " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat blast_with_am.log | grep "egas " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat blast_with_am.log | grep "tau " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat blast_with_am.log | grep "pot " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat blast_with_am.log | grep "sx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sy_regex \"$(cat blast_with_am.log | grep "sy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sz_regex \"$(cat blast_with_am.log | grep "sz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zx_regex \"$(cat blast_with_am.log | grep "zx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat blast_with_am.log | grep "zy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat blast_with_am.log | grep "zz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat blast_with_am.log | grep "spc_1 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat blast_with_am.log | grep "spc_2 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat blast_with_am.log | grep "spc_3 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat blast_with_am.log | grep "spc_4 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat blast_with_am.log | grep "spc_5 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"blast_with_am.silo\")" | tee -a cmake_snippets.txt
echo "elseif (OCTOTIGER_WITH_GRIDDIM EQUAL 16)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat blast16_with_am.log | grep "rho " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat blast16_with_am.log | grep "egas " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat blast16_with_am.log | grep "tau " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat blast16_with_am.log | grep "pot " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat blast16_with_am.log | grep "sx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sy_regex \"$(cat blast16_with_am.log | grep "sy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sz_regex \"$(cat blast16_with_am.log | grep "sz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zx_regex \"$(cat blast16_with_am.log | grep "zx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat blast16_with_am.log | grep "zy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat blast16_with_am.log | grep "zz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat blast16_with_am.log | grep "spc_1 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat blast16_with_am.log | grep "spc_2 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat blast16_with_am.log | grep "spc_3 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat blast16_with_am.log | grep "spc_4 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat blast16_with_am.log | grep "spc_5 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"none\")" | tee -a cmake_snippets.txt
echo "else()" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "Subgridsize 8, with correct_am_hydro=0" | tee -a cmake_snippets.txt
echo "Snippet:" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt
echo "if (OCTOTIGER_WITH_GRIDDIM EQUAL 8)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat blast_without_am.log | grep "rho " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat blast_without_am.log | grep "egas " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat blast_without_am.log | grep "tau " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat blast_without_am.log | grep "pot " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat blast_without_am.log | grep "sx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sy_regex \"$(cat blast_without_am.log | grep "sy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sz_regex \"$(cat blast_without_am.log | grep "sz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zx_regex \"$(cat blast_without_am.log | grep "zx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat blast_without_am.log | grep "zy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat blast_without_am.log | grep "zz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat blast_without_am.log | grep "spc_1 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat blast_without_am.log | grep "spc_2 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat blast_without_am.log | grep "spc_3 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat blast_without_am.log | grep "spc_4 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat blast_without_am.log | grep "spc_5 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"blast_without_am.silo\")" | tee -a cmake_snippets.txt
echo "elseif (OCTOTIGER_WITH_GRIDDIM EQUAL 16)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat blast16_without_am.log | grep "rho " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat blast16_without_am.log | grep "egas " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat blast16_without_am.log | grep "tau " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat blast16_without_am.log | grep "pot " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat blast16_without_am.log | grep "sx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sy_regex \"$(cat blast16_without_am.log | grep "sy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sz_regex \"$(cat blast16_without_am.log | grep "sz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zx_regex \"$(cat blast16_without_am.log | grep "zx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat blast16_without_am.log | grep "zy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat blast16_without_am.log | grep "zz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat blast16_without_am.log | grep "spc_1 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat blast16_without_am.log | grep "spc_2 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat blast16_without_am.log | grep "spc_3 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat blast16_without_am.log | grep "spc_4 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat blast16_without_am.log | grep "spc_5 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"none\")" | tee -a cmake_snippets.txt
echo "else()" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "For file test_problems/sphere/CMakeLists.txt" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "Subgridsize 8" | tee -a cmake_snippets.txt
echo "Snippet:" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt
echo "if (OCTOTIGER_WITH_GRIDDIM EQUAL 8)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat sphere.log | grep "rho " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat sphere.log | grep "egas " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat sphere.log | grep "tau " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat sphere.log | grep "pot " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat sphere.log | grep "sx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sy_regex \"$(cat sphere.log | grep "sy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sz_regex \"$(cat sphere.log | grep "sz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zx_regex \"$(cat sphere.log | grep "zx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat sphere.log | grep "zy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat sphere.log | grep "zz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat sphere.log | grep "spc_1 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat sphere.log | grep "spc_2 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat sphere.log | grep "spc_3 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat sphere.log | grep "spc_4 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat sphere.log | grep "spc_5 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"sphere.silo\")" | tee -a cmake_snippets.txt
echo "elseif (OCTOTIGER_WITH_GRIDDIM EQUAL 16)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat sphere16.log | grep "rho " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat sphere16.log | grep "egas " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat sphere16.log | grep "tau " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat sphere16.log | grep "pot " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat sphere16.log | grep "sx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sy_regex \"$(cat sphere16.log | grep "sy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sz_regex \"$(cat sphere16.log | grep "sz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zx_regex \"$(cat sphere16.log | grep "zx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat sphere16.log | grep "zy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat sphere16.log | grep "zz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat sphere16.log | grep "spc_1 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat sphere16.log | grep "spc_2 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat sphere16.log | grep "spc_3 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat sphere16.log | grep "spc_4 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat sphere16.log | grep "spc_5 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"none\")" | tee -a cmake_snippets.txt
echo "else()" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "For file test_problems/sod/CMakeLists.txt" | tee -a cmake_snippets.txt
echo "########################################################" | tee -a cmake_snippets.txt
echo "Subgridsize 8" | tee -a cmake_snippets.txt
echo "Snippet:" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt
echo "if (OCTOTIGER_WITH_GRIDDIM EQUAL 8)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat sod_without_am.log | grep "rho " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat sod_without_am.log | grep "egas " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat sod_without_am.log | grep "tau " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat sod_without_am.log | grep "pot " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat sod_without_am.log | grep "sx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat sod_without_am.log | grep "zy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat sod_without_am.log | grep "zz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat sod_without_am.log | grep "spc_1 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat sod_without_am.log | grep "spc_2 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat sod_without_am.log | grep "spc_3 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat sod_without_am.log | grep "spc_4 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat sod_without_am.log | grep "spc_5 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"sod_without_am.silo\")" | tee -a cmake_snippets.txt
echo "elseif (OCTOTIGER_WITH_GRIDDIM EQUAL 16)" | tee -a cmake_snippets.txt
echo "  set(rho_regex \"$(cat sod16_without_am.log | grep "rho " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(egas_regex \"$(cat sod16_without_am.log | grep "egas " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(tau_regex \"$(cat sod16_without_am.log | grep "tau " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(pot_regex \"$(cat sod16_without_am.log | grep "pot " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(sx_regex \"$(cat sod16_without_am.log | grep "sx " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zy_regex \"$(cat sod16_without_am.log | grep "zy " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(zz_regex \"$(cat sod16_without_am.log | grep "zz " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc1_regex \"$(cat sod16_without_am.log | grep "spc_1 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc2_regex \"$(cat sod16_without_am.log | grep "spc_2 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc3_regex \"$(cat sod16_without_am.log | grep "spc_3 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc4_regex \"$(cat sod16_without_am.log | grep "spc_4 " | sed 's/\+/./g'| sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(spc5_regex \"$(cat sod16_without_am.log | grep "spc_5 " | sed 's/\+/./g' | sed 's/^ *//g')\")" | tee -a cmake_snippets.txt
echo "  set(silo_scenario_filename \"none\")" | tee -a cmake_snippets.txt
echo "else()" | tee -a cmake_snippets.txt
echo "" | tee -a cmake_snippets.txt

cp cmake_snippets.txt new-testdata/cmake_snippets.txt

