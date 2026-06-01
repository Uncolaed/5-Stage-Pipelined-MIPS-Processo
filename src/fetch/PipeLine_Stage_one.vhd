--------------------------------------------------------------------------------
-- Entity: PipeLine_Stage_One
-- Description:
-- This module represents the first stage of the MIPS pipeline.
-- It stores the Program Counter (PC) + 4 and the fetched instruction
-- during each clock cycle.
-- Supports reset functionality to initialize pipeline registers.
-- Includes a configurable PC size for debugging purposes.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.std_logic_1164.all; -- Standard library for std_logic types
use IEEE.numeric_std.all;    -- Supports numeric operations

--===========================================
-- Entity Declaration
--===========================================
entity PipeLine_Stage_One is
  generic(
    PC_SIZE : natural := 32; -- Generic parameter for Program Counter size
    INSTR_SIZE : natural := 32 -- Generic parameter for Instruction size (default is 32 bits)
  );
  port (
    clk               : in  std_logic; -- Clock signal
    resetPL1          : in  std_logic; -- Reset signal
    storedPC          : in  std_logic_vector(PC_SIZE-1 downto 0); -- Input: Next PC address
    storedInstruction : in  std_logic_vector(INSTR_SIZE-1 downto 0); -- Input: Fetched instruction

    -- OUTPUT
    getPC             : out std_logic_vector(PC_SIZE-1 downto 0); -- Output: Stored PC address
    getInstruction    : out std_logic_vector(INSTR_SIZE-1 downto 0) -- Output: Stored instruction
  );
end PipeLine_Stage_One;

--===========================================
-- Architecture Definition
--===========================================
architecture behavioral of PipeLine_Stage_One is

  -- Internal signals for pipeline registers
  signal sInstruction : std_logic_vector(INSTR_SIZE-1 downto 0) := (others => '0');
  signal sPC          : std_logic_vector(PC_SIZE-1 downto 0) := (others => '0');

begin

  --===========================================
  -- Pipeline Register Process
  --===========================================
  -- Updates the pipeline registers on every rising edge of the clock.
  loadAddress : process(clk, resetPL1)
  begin
    if resetPL1 = '1' then
      -- Reset pipeline registers to zero
      sInstruction <= (others => '0');
      sPC <= (others => '0');

    elsif rising_edge(clk) then
      -- Update pipeline registers with new instruction and PC
      sInstruction <= storedInstruction;
      sPC <= storedPC;
    end if;
  end process loadAddress;

  -- Output assignment
  getInstruction <= sInstruction; -- Pass stored instruction to output
  getPC <= sPC; -- Pass stored PC to output

end behavioral;
