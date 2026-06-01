--------------------------------------------------------------------------------
-- Entity: MIPS_VHDL
-- Description:
-- Top-level reference design for a single-cycle MIPS processor.
-- Integrates PC, Instruction Memory, Control Unit, Register File,
-- ALU, Data Memory, and multiplexers.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

--===========================================
-- Entity Declaration
--===========================================
entity MIPS_VHDL is
    port (
        clk          : in  std_logic; -- System Clock
        reset        : in  std_logic; -- Reset Signal
        pc_out       : out std_logic_vector(15 downto 0); -- PC Output
        alu_result   : out std_logic_vector(31 downto 0) -- ALU Result Output
    );
end MIPS_VHDL;

--===========================================
-- Architecture Definition
--===========================================
architecture Behavioral of MIPS_VHDL is

    -- Program Counter Signals
    signal pc_current, pc_next, pc_plus4 : std_logic_vector(15 downto 0);

    -- Instruction Memory Signals
    signal instr : std_logic_vector(31 downto 0);

    -- Control Unit Signals
    signal reg_dst, mem_to_reg, alu_op : std_logic_vector(1 downto 0);
    signal jump, branch, mem_read, mem_write, alu_src, reg_write, sign_or_zero : std_logic;

    -- Register File Signals
    signal reg_write_dest : std_logic_vector(4 downto 0);
    signal reg_write_data : std_logic_vector(31 downto 0);
    signal reg_read_addr_1, reg_read_addr_2 : std_logic_vector(4 downto 0);
    signal reg_read_data_1, reg_read_data_2 : std_logic_vector(31 downto 0);

    -- ALU Signals
    signal alu_control : std_logic_vector(2 downto 0);
    signal alu_out : std_logic_vector(31 downto 0);
    signal zero_flag : std_logic;

    -- Immediate Extension Signals
    signal sign_ext_im, zero_ext_im, imm_ext : std_logic_vector(31 downto 0);

    -- Data Memory Signals
    signal mem_read_data : std_logic_vector(31 downto 0);

    -- Jump and Branch Signals
    signal jump_addr : std_logic_vector(15 downto 0);
    signal branch_control : std_logic;

     signal alu_src_b : std_logic_vector(31 downto 0);

begin

    --===========================================
    -- Program Counter (PC) Logic
    --===========================================
    process(clk, reset)
    begin
        if reset = '1' then
            pc_current <= x"0000";
        elsif rising_edge(clk) then
            pc_current <= pc_next;
        end if;
    end process;

    pc_plus4 <= std_logic_vector(unsigned(pc_current) + 4);

         --===========================================
    -- PC Update Logic
    --===========================================
    branch_control <= branch and zero_flag; -- Determines if the branch is taken

    -- Calculate Jump Address (For Jump Instructions)
    jump_addr <= instr(13 downto 0) & "00"; -- Shift left by 2 for jump target address

    -- PC MUX Logic
    process(branch_control, jump, pc_plus4, imm_ext, jump_addr)
    begin
         if jump = '1' then
              -- Jump instruction
              pc_next <= jump_addr(15 downto 0);
         elsif branch_control = '1' then
              -- Branch instruction (if condition is met)
              pc_next <= std_logic_vector(unsigned(pc_plus4) + unsigned(imm_ext(15 downto 0)));
         else
              -- Default: Increment PC by 4
              pc_next <= pc_plus4;
         end if;
    end process;

    --===========================================
    -- Instruction Memory
    --===========================================
    Instruction_Memory : entity work.Instruction_Memory_VHDL
        generic map (
            DATA_WIDTH => 32,
            MEM_SIZE   => 256
        )
        port map (
            pc          => pc_current,
            instruction => instr
        );

    --===========================================
    -- Control Unit
    --===========================================
    Control_Unit : entity work.control_unit_VHDL
        port map (
            opcode       => instr(31 downto 26),
            reset        => reset,
            reg_dst      => reg_dst,
            mem_to_reg   => mem_to_reg,
            alu_op       => alu_op,
            jump         => jump,
            branch       => branch,
            mem_read     => mem_read,
            mem_write    => mem_write,
            alu_src      => alu_src,
            reg_write    => reg_write,
            sign_or_zero => sign_or_zero
        );

    --===========================================
    -- Register File
    --===========================================
    reg_read_addr_1 <= instr(25 downto 21);
    reg_read_addr_2 <= instr(20 downto 16);

    -- **MUX 1: Register Destination (reg_dst)**
    reg_write_dest <= instr(15 downto 11) when reg_dst = "01" else instr(20 downto 16);

    Register_File : entity work.register_file_VHDL
        generic map (
            DATA_WIDTH => 32,
            NUM_REGS   => 32
        )
        port map (
            clk             => clk,
            rst             => reset,
            reg_write_en    => reg_write,
            reg_write_dest  => reg_write_dest,
            reg_write_data  => reg_write_data,
            reg_read_addr_1 => reg_read_addr_1,
            reg_read_data_1 => reg_read_data_1,
            reg_read_addr_2 => reg_read_addr_2,
            reg_read_data_2 => reg_read_data_2
        );

    -- Immediate Extension
    sign_ext_im <= std_logic_vector(resize(signed(instr(15 downto 0)), 32));
    zero_ext_im <= std_logic_vector(resize(unsigned(instr(15 downto 0)), 32));
    imm_ext <= sign_ext_im when sign_or_zero = '1' else zero_ext_im;

    -- **MUX 2: ALU Source (alu_src)**
    alu_src_b <= imm_ext when alu_src = '1' else reg_read_data_2;

    -- ALU Control
    ALU_Control_Inst : entity work.ALU_Control_VHDL
        port map (
            ALUOp       => alu_op,
            ALU_Funct   => instr(5 downto 0),
            ALU_Control => alu_control
        );

    -- ALU
    ALU : entity work.ALU_VHDL
        port map (
            a           => reg_read_data_1,
            b           => alu_src_b,
            alu_control => alu_control,
            alu_result  => alu_out,
            zero        => zero_flag
        );

    -- Data Memory
    Data_Memory : entity work.Data_Memory_VHDL
        port map (
            clk            => clk,
            mem_access_addr=> alu_out(15 downto 0),
            mem_write_data => reg_read_data_2,
            mem_write_en   => mem_write,
            mem_read       => mem_read,
            mem_read_data  => mem_read_data
        );

    -- **MUX 3: Write-Back (mem_to_reg)**
    reg_write_data <= std_logic_vector(resize(unsigned(pc_plus4), 32)) when mem_to_reg = "10" else
                      mem_read_data when mem_to_reg = "01" else
                      alu_out;

    -- Outputs
    pc_out <= pc_current;
    alu_result <= alu_out;

end Behavioral;
