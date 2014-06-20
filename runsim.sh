#!/bin/bash
iverilog -o design -c filelist.txt 
vvp design
