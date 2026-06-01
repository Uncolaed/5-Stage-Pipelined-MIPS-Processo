--------------------------------------------------------------------------------
-- Entity: Program_Counter
-- Description:
-- A Program Counter (PC) module that manages the current instruction address.
-- Supports reset functionality and updates on each clock cycle.
-- Includes configurable PC size using a generic parameter.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.std_logic_1164.all; -- Standard library for std_logic types
use IEEE.numeric_std.all;    -- Supports numeric operations

--===========================================
-- Entity Declaration
--===========================================
entity Program_Counter is
  generic(
    PC_SIZE : natural := 32 -- Generic parameter to set PC size (default is 32 bits)
  );
  port (
    clk            : in  std_logic; -- Clock signal
    resetPC        : in  std_logic; -- Reset signal
    nextAddress    : in  std_logic_vector(PC_SIZE-1 downto 0); -- Next address input
    currentAddress : out std_logic_vector(PC_SIZE-1 downto 0) -- Current address output
  );
end Program_Counter;

--===========================================
-- Architecture Definition
--===========================================
architecture behavioral of Program_Counter is

  -- Internal signal to hold the current address
  signal address : std_logic_vector(PC_SIZE-1 downto 0) := (others => '0');

begin

  --===========================================
  -- Address Update Process
  --===========================================
  loadAddress : process(clk, resetPC)
  begin
    -- Reset Behavior
    if resetPC = '1' then
      address <= (others => '0'); -- Reset address to 0

    -- Clock Edge Behavior (Rising Edge Detection)
    elsif rising_edge(clk) then
      address <= nextAddress; -- Update address with nextAddress
    end if;
  end process loadAddress;

  -- Output the current address
  currentAddress <= address;

end behavioral;
