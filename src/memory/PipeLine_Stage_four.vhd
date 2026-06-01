--------------------------------------------------------------------------------
-- Entity: PipeLine_Stage_four
-- Description:
-- Pipeline register between the memory access and write-back stages.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; -- Standard library for std_logic data type
use IEEE.numeric_std.all; -- Provides arithmetic operations for numeric types

entity PipeLine_Stage_four is
  port (
    clk               : in std_logic; -- System clock signal
    resetPL           : in std_logic; -- Pipeline reset signal
    -- Store control unit signals
    -- Write-back stage signals:
    storedMemToReg    : in std_logic; -- Determines if data comes from memory or ALU
    storedRegWrite    : in std_logic; -- Enables register writing
    -- Data from memory stage:
    storedReadDataMem : in std_logic_vector(31 downto 0); -- Data read from memory
    -- ALU stage signals:
    storedAluResult   : in std_logic_vector(31 downto 0); -- ALU computation result
    -- Register write signals:
    storedWriteReg    : in std_logic_vector(4 downto 0); -- Destination register for write-back
    -- OUTPUT
    getMemToReg       : out std_logic; -- Pass-through for MemToReg control signal
    getRegWrite       : out std_logic; -- Pass-through for RegWrite control signal
    getReadDataMem    : out std_logic_vector(31 downto 0); -- Pass-through for data from memory
    getAluResult      : out std_logic_vector(31 downto 0); -- Pass-through for ALU result
    getWriteReg       : out std_logic_vector(4 downto 0) -- Pass-through for destination register
  );
end PipeLine_Stage_four;

architecture behavioral of PipeLine_Stage_four is

  -- Internal signals to store intermediate values between pipeline stages
  signal sMemToReg, sRegWrite : std_logic; -- Internal control signals for write-back stage
  signal sAluresult, sReadDataMem : std_logic_vector(31 downto 0); -- Internal data signals
  signal sWriteReg : std_logic_vector(4 downto 0); -- Internal register write address

begin

    loadAddress : process(clk, resetPL) -- Process triggered by clock or reset signals
    begin
        if resetPL = '1' then -- Check if reset is active
            -- Reset all signals to default values
            sMemToReg     <= '0'; -- Default: Memory-to-Register disabled
            sRegWrite     <= '0'; -- Default: Register writing disabled
            sReadDataMem  <= "00000000000000000000000000000000"; -- Reset memory data to zero
            sAluResult    <= "00000000000000000000000000000000"; -- Reset ALU result to zero
            sWriteReg     <= "00000"; -- Reset write register address to zero
        elsif rising_edge(clk) then -- On rising edge of clock
            -- Store input signals into internal signals
            sMemToReg     <= storedMemToReg;
            sRegWrite     <= storedRegWrite;
            sReadDataMem  <= storedReadDataMem;
            sAluResult    <= storedAluResult;
            sWriteReg     <= storedWriteReg;
        end if;
    end process loadAddress;

    -- Output assignments: Pass the stored values to the output ports
    getMemToReg     <= sMemToReg;
    getRegWrite     <= sRegWrite;
    getReadDataMem  <= sReadDataMem;
    getAluResult    <= sAluResult;
    getWriteReg     <= sWriteReg;

end behavioral;
