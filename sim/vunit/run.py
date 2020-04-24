#!/usr/bin/python3

from vunit import VUnit

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()

# Create library 'lib'
lib = vu.add_library("lib")

# Add all files ending in .vhd in current working directory to library
lib.add_source_files("../../vhdl/*.vhd")
lib.add_source_files("*.vhd")


vu.set_sim_option("modelsim.init_file.gui", "wave.do")
# Run vunit function
vu.main()
