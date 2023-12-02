vsim -gui work.alu
# vsim -gui work.alu 
# Start time: 16:27:47 on Dec 02,2023
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.alu(archalu)
add wave -position insertpoint  \
sim:/alu/R1 \
sim:/alu/R2 \
sim:/alu/op \
sim:/alu/CCR \
sim:/alu/result \
sim:/alu/Bitset \
sim:/alu/Bitset_mask \
sim:/alu/Rcl \
sim:/alu/Rcr
force -freeze sim:/alu/CCR 111 0
force -freeze sim:/alu/R1 10#110 0
force -freeze sim:/alu/R2 10#30 0
force -freeze sim:/alu/op 0000 0
run
force -freeze sim:/alu/op 0000 0
run
force -freeze sim:/alu/op 0001 0
run
force -freeze sim:/alu/op 0010 0
run
force -freeze sim:/alu/op 0011 0
run
force -freeze sim:/alu/op 0100 0
run
force -freeze sim:/alu/op 0101 0
run
force -freeze sim:/alu/op 0110 0
run
force -freeze sim:/alu/op 0111 0
run
force -freeze sim:/alu/op 1000 0
run
force -freeze sim:/alu/op 1001 0
run
force -freeze sim:/alu/op 1010 0
run
force -freeze sim:/alu/op 1011 0
run
force -freeze sim:/alu/op 1100 0
run
force -freeze sim:/alu/op 1101 0
run
force -freeze sim:/alu/op 1110 0
run
force -freeze sim:/alu/op 1111 0
run