vsim -gui work.processor
add wave -position insertpoint  \
sim:/processor/clk \
sim:/processor/rst \
sim:/processor/in_port \
sim:/processor/out_port \
sim:/processor/signal_vector \
sim:/processor/instruction \
sim:/processor/reg_read_data1 \
sim:/processor/reg_read_data2 \
sim:/processor/reg_write_data \
sim:/processor/alu_in1 \
sim:/processor/alu_in2 \
sim:/processor/alu_out \
sim:/processor/data_mem_in \
sim:/processor/data_mem_out \
sim:/processor/data_mem_address \
sim:/processor/pc \
sim:/processor/sp \
sim:/processor/CCR \
sim:/processor/if_id_reg \
sim:/processor/id_ex_reg \
sim:/processor/ex_mem_reg \
sim:/processor/mem_wb_reg \
sim:/processor/u1/registers \
sim:/processor/u0/instrMem \
sim:/processor/u4/Memo \

force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/processor/rst 1 0
run
force -freeze sim:/processor/rst 0 0
force -freeze sim:/processor/in_port 10#64 0
run
run
run
run
run