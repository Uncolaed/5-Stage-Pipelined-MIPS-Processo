
library IEEE;
use IEEE.std_logic_1164.all; -- Standard library for std_logic data type
use IEEE.numeric_std.all; -- Provides arithmetic operations for numeric types

entity PipeLine_Stage_Three is
  port (
    clk             : in std_logic; -- System clock signal
    resetPL         : in std_logic; -- Pipeline reset signal
    -- Store control unit signals
    -- Write-back stage signals:
    storedMemToReg  : in std_logic; -- Determines if data comes from memory or ALU
    storedRegWrite  : in std_logic; -- Enables register writing
    -- Memory stage signals:
    storedJump      : in std_logic; -- Jump control signal
    storedBranch    : in std_logic; -- Branch control signal
    storedMemRead   : in std_logic; -- Enables memory read
    storedMemWrite  : in std_logic; -- Enables memory write
    -- Branch address signals:
    storedJumpAddr  : in std_logic_vector(31 downto 0); -- Address for jump instruction
    storedBranchAddr: in std_logic_vector(31 downto 0); -- Address for branch instruction
    -- ALU signals:
    storedZero      : in std_logic; -- Zero flag from ALU
    storedAluResult : in std_logic_vector(31 downto 0); -- ALU computation result
    -- Data signals from registers:
    storedReadData2 : in std_logic_vector(31 downto 0); -- Data from register 2
    -- Register write signals:
    storedWriteReg  : in std_logic_vector(4 downto 0); -- Destination register for write-back
    -- OUTPUT
    getMemToReg     : out std_logic; -- Pass-through for MemToReg control signal
    getRegWrite     : out std_logic; -- Pass-through for RegWrite control signal
    getJump         : out std_logic; -- Pass-through for Jump control signal
    getBranch       : out std_logic; -- Pass-through for Branch control signal
    getMemRead      : out std_logic; -- Pass-through for MemRead control signal
    getMemWrite     : out std_logic; -- Pass-through for MemWrite control signal
    getJumpAddr     : out std_logic_vector(31 downto 0); -- Pass-through for jump address
    getBranchAddr   : out std_logic_vector(31 downto 0); -- Pass-through for branch address
    getZero         : out std_logic; -- Pass-through for Zero flag
    getAluResult    : out std_logic_vector(31 downto 0); -- Pass-through for ALU result
    getReadData2    : out std_logic_vector(31 downto 0); -- Pass-through for data from register 2
    getWriteReg     : out std_logic_vector(4 downto 0) -- Pass-through for destination register
  );
end PipeLine_Stage_Three;

architecture behavioral of PipeLine_Stage_Three is

  -- Internal signals to store intermediate values between pipeline stages
  signal sMemToReg, sRegWrite, sJump, sBranch, sMemRead, sMemWrite, sZero : std_logic;
  signal sJumpAddr, sBranchAddr, sAluresult, sReadData2 : std_logic_vector(31 downto 0);
  signal sWriteReg : std_logic_vector(4 downto 0);

begin

    loadAddress : process(clk, resetPL) -- Process triggered by clock or reset signals
    begin
        if resetPL = '1' then -- Check if reset is active
            -- Reset all signals to default values
            sMemToReg   <= '0';
            sRegWrite   <= '0';
            sJump       <= '0';
            sBranch     <= '0';
            sMemRead    <= '0';
            sMemWrite   <= '0';
            sJumpAddr   <= "00000000000000000000000000000000";
            sBranchAddr <= "00000000000000000000000000000000";
            sZero       <= '0';
            sAluResult  <= "00000000000000000000000000000000";
            sReadData2  <= "00000000000000000000000000000000";
            sWriteReg   <= "00000";
        elsif rising_edge(clk) then -- On rising edge of clock
            -- Store input signals into internal signals
            sMemToReg   <= storedMemToReg;
            sRegWrite   <= storedRegWrite;
            sJump       <= storedJump;
            sBranch     <= storedBranch;
            sMemRead    <= storedMemRead;
            sMemWrite   <= storedMemWrite;
            sJumpAddr   <= storedJumpAddr;
            sBranchAddr <= storedBranchAddr;
            sZero       <= storedZero;
            sAluResult  <= storedAluResult;
            sReadData2  <= storedReadData2;
            sWriteReg   <= storedWriteReg;
        end if;
    end process loadAddress;

    -- Output assignments: Pass the stored values to the output ports
    getMemToReg   <= sMemToReg;
    getRegWrite   <= sRegWrite;
    getJump       <= sJump;
    getBranch     <= sBranch;
    getMemRead    <= sMemRead;
    getMemWrite   <= sMemWrite;
    getJumpAddr   <= sJumpAddr;
    getBranchAddr <= sBranchAddr;
    getZero       <= sZero;
    getAluResult  <= sAluResult;
    getReadData2  <= sReadData2;
    getWriteReg   <= sWriteReg;

end behavioral;
