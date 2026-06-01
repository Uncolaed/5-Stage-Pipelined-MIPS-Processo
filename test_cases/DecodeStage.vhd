library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity ID_Stage is
    Port (
        clk               : in  std_logic;
        reset             : in  std_logic;
        IF_ID_instruction : in  std_logic_vector(31 downto 0); -- Instruction from IF/ID pipeline
        IF_ID_PC          : in  std_logic_vector(31 downto 0); -- PC from IF/ID pipeline
        reg_file          : inout mem_array; -- Register file for reading/writing data
        reg_write_en      : in std_logic; -- Enable signal for register write
        reg_write_dest    : in std_logic_vector(4 downto 0); -- Register destination for write-back
        reg_write_data    : in std_logic_vector(31 downto 0); -- Data to write into register
        ID_EX_ReadData1   : out std_logic_vector(31 downto 0); -- Read data 1 for EX stage
        ID_EX_ReadData2   : out std_logic_vector(31 downto 0); -- Read data 2 for EX stage
        ID_EX_SignExtend  : out std_logic_vector(31 downto 0); -- Sign-extended immediate
        ID_EX_PC          : out std_logic_vector(31 downto 0); -- PC passed to EX stage
        ID_EX_ControlSignals : out std_logic_vector(9 downto 0) -- Control signals for EX stage
    );
end ID_Stage;

architecture Behavioral of ID_Stage is

    -- Control Signals
    signal reg_dst, mem_to_reg, alu_op : std_logic_vector(1 downto 0);
    signal jump, branch, mem_read, mem_write, alu_src, reg_write, sign_or_zero : std_logic;

    -- Internal signals
    signal rs, rt, rd : std_logic_vector(4 downto 0);
    signal immediate   : std_logic_vector(15 downto 0);

begin

    --===========================================
    -- Decode Instruction
    --===========================================
    process(IF_ID_instruction)
    begin
        rs <= IF_ID_instruction(25 downto 21);
        rt <= IF_ID_instruction(20 downto 16);
        rd <= IF_ID_instruction(15 downto 11);
        immediate <= IF_ID_instruction(15 downto 0);
    end process;

    --===========================================
    -- Control Unit
    --===========================================
    Control_Unit : entity work.control_unit_VHDL
        port map (
            opcode       => IF_ID_instruction(31 downto 26),
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
    Register_File : entity work.register_file_VHDL
        generic map (
            DATA_WIDTH => 32,
            NUM_REGS   => 32
        )
        port map (
            clk             => clk,
            rst             => reset,
            reg_write_en    => reg_write_en,
            reg_write_dest  => reg_write_dest,
            reg_write_data  => reg_write_data,
            reg_read_addr_1 => rs,
            reg_read_data_1 => ID_EX_ReadData1,
            reg_read_addr_2 => rt,
            reg_read_data_2 => ID_EX_ReadData2
        );

    --===========================================
    -- Sign Extension for Immediate Value
    --===========================================
    ID_EX_SignExtend <= std_logic_vector(resize(signed(immediate), 32)) when sign_or_zero = '1' else
                        std_logic_vector(resize(unsigned(immediate), 32));

    --===========================================
    -- Pass PC to EX Stage
    --===========================================
    ID_EX_PC <= IF_ID_PC;

    --===========================================
    -- Generate Control Signals for EX Stage
    --===========================================
    ID_EX_ControlSignals <= reg_dst & mem_to_reg & alu_op & alu_src & reg_write;

end Behavioral;
