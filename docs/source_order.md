# Source Import Order

Use this order when adding the pipelined CPU sources to Xilinx ISE:

1. `src/general/Adder.vhd`
2. `src/general/Mux.vhd`
3. `src/general/Shift_Left.vhd`
4. `src/fetch/Program_Counter.vhd`
5. `src/fetch/Instruction_Memory_VHDL.vhd`
6. `src/fetch/PipeLine_Stage_one.vhd`
7. `src/fetch/Fetch_Instruction.vhd`
8. `src/decode/control_unit_new.vhd`
9. `src/decode/register_file_VHDL.vhd`
10. `src/decode/Sign_Extender.vhd`
11. `src/decode/Pipeline_Stage_Two.vhd`
12. `src/decode/Decode_Instruction.vhd`
13. `src/execute/ALU_VHDL.vhd`
14. `src/execute/PipeLine_Stage_three.vhd`
15. `src/execute/Execute_Stage.vhd`
16. `src/memory/Data_Memory_VHDL.vhd`
17. `src/memory/PipeLine_Stage_four.vhd`
18. `src/memory/MemoryOperations_Stage.vhd`
19. `src/main_cpu/completeCPU.vhd`

The top-level entity is `completeCPU`.

