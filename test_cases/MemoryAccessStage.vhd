library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity MEM_Stage is
    Port (
        clk                  : in  std_logic;
        reset                : in  std_logic;
        EX_MEM_ALUResult     : in  std_logic_vector(31 downto 0); -- Address for memory access
        EX_MEM_ReadData2     : in  std_logic_vector(31 downto 0); -- Data to write to memory
        EX_MEM_ControlSignals: in  std_logic_vector(9 downto 0); -- Control signals from EX stage
        EX_MEM_ZeroFlag      : in  std_logic; -- Zero flag for branch decision
        EX_MEM_BranchAddr    : in  std_logic_vector(31 downto 0); -- Branch target address
        MEM_WB_ReadData      : out std_logic_vector(31 downto 0); -- Data read from memory
        MEM_WB_ALUResult     : out std_logic_vector(31 downto 0); -- Forwarded ALU result
        MEM_WB_ControlSignals: out std_logic_vector(9 downto 0); -- Forwarded control signals
        branch_taken         : out std_logic; -- Signal to indicate branch is taken
        pc_update_addr       : out std_logic_vector(31 downto 0) -- Address for PC update
    );
end MEM_Stage;

architecture Behavioral of MEM_Stage is

    -- Control Signal Breakout
    signal mem_read, mem_write, branch : std_logic;

    -- Internal Signals
    signal read_data : std_logic_vector(31 downto 0);

begin

    --===========================================
    -- Control Signal Decoding
    --===========================================
    mem_read  <= EX_MEM_ControlSignals(7);
    mem_write <= EX_MEM_ControlSignals(8);
    branch    <= EX_MEM_ControlSignals(6);

    --===========================================
    -- Data Memory Access
    --===========================================
    Data_Memory : entity work.Data_Memory_VHDL
        generic map (
            DATA_WIDTH => 32,
            MEM_SIZE   => 256
        )
        port map (
            clk            => clk,
            mem_access_addr=> EX_MEM_ALUResult(15 downto 0),
            mem_write_data => EX_MEM_ReadData2,
            mem_write_en   => mem_write,
            mem_read       => mem_read,
            mem_read_data  => read_data
        );

    --===========================================
    -- Branch Decision Logic
    --===========================================
    branch_taken <= branch and EX_MEM_ZeroFlag;
    pc_update_addr <= EX_MEM_BranchAddr when branch_taken = '1' else EX_MEM_ALUResult;

    --===========================================
    -- Forward Results to MEM/WB Pipeline
    --===========================================
    MEM_WB_ReadData <= read_data;
    MEM_WB_ALUResult <= EX_MEM_ALUResult;
    MEM_WB_ControlSignals <= EX_MEM_ControlSignals;

end Behavioral;
