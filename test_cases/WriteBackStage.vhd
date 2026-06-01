library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity WB_Stage is
    Port (
        clk                  : in  std_logic;
        reset                : in  std_logic;
        MEM_WB_ReadData      : in  std_logic_vector(31 downto 0); -- Data read from memory
        MEM_WB_ALUResult     : in  std_logic_vector(31 downto 0); -- ALU result from MEM stage
        MEM_WB_ControlSignals: in  std_logic_vector(9 downto 0); -- Control signals from MEM stage
        reg_write_en         : out std_logic; -- Enable signal for register write
        reg_write_dest       : out std_logic_vector(4 downto 0); -- Destination register
        reg_write_data       : out std_logic_vector(31 downto 0) -- Data to write into register
    );
end WB_Stage;

architecture Behavioral of WB_Stage is

    -- Control Signal Breakout
    signal mem_to_reg, reg_write : std_logic;

begin

    --===========================================
    -- Control Signal Decoding
    --===========================================
    mem_to_reg <= MEM_WB_ControlSignals(1);
    reg_write  <= MEM_WB_ControlSignals(0);

    --===========================================
    -- Write Back Data Selection
    --===========================================
    reg_write_data <= MEM_WB_ReadData when mem_to_reg = '1' else MEM_WB_ALUResult;

    --===========================================
    -- Forward Control Signals
    --===========================================
    reg_write_en <= reg_write;
    reg_write_dest <= MEM_WB_ControlSignals(8 downto 4); -- Assuming control signals include destination register

end Behavioral;
