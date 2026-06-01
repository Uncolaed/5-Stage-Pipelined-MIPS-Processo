--------------------------------------------------------------------------------
-- Entity: MUX
-- Description:
-- A generic multiplexer (MUX) module that selects one of two input signals
-- based on a control signal. The dimension of the signals is configurable
-- using a generic parameter.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.std_logic_1164.all; -- Standard logic library for std_logic_vector

--===========================================
-- Entity Declaration
--===========================================
entity mux is
  generic(
    dimension : natural := 32 -- Generic parameter to set signal size (default is 32 bits)
  );
  port(
    controlSignal  : in std_logic; -- Control signal to select between two inputs
    signal1        : in std_logic_vector(dimension - 1 downto 0); -- First input signal
    signal2        : in std_logic_vector(dimension - 1 downto 0); -- Second input signal
    selectedSignal : out std_logic_vector(dimension - 1 downto 0) -- Output selected signal
  );
end mux;

--===========================================
-- Architecture Definition
--===========================================
architecture behavioral of mux is
begin
  -- Multiplexer Logic
  -- If controlSignal is '0', signal1 is selected.
  -- If controlSignal is '1', signal2 is selected.
  selectedSignal <= signal1 when (controlSignal = '0') else signal2;
end behavioral;
