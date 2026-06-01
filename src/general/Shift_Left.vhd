--------------------------------------------------------------------------------
-- Entity: ShifterLeft
-- Description:
-- A generic left shifter module that shifts an input signal to the left by a
-- configurable number of bits. The input and output dimensions are adjustable
-- using generic parameters.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.std_logic_1164.all; -- Standard logic library for std_logic_vector
use IEEE.numeric_std.all; -- Provides numeric operations for signed and unsigned types

--===========================================
-- Entity Declaration
--===========================================
entity shifterLeft is
  generic(
    inputDim   : natural := 32; -- Input signal width (default is 32 bits)
    outputDim  : natural := 32; -- Output signal width (default is 32 bits)
    bitToShift : natural := 2   -- Number of bits to shift left (default is 2 bits)
  );
  port(
    inputV  : in  std_logic_vector(inputDim - 1 downto 0); -- Input signal to be shifted
    outputV : out std_logic_vector(outputDim - 1 downto 0) -- Output signal after shifting
  );
end shifterLeft;

--===========================================
-- Architecture Definition
--===========================================
architecture behavioral of shifterLeft is

  -- Intermediate signal for resizing the input vector
  signal resize_input : std_logic_vector(outputDim - 1 downto 0);

begin

  -- Resize Input Signal:
  -- Ensure the input vector matches the output dimension by resizing it.
  -- The 'resize' function converts the 'inputV' to match 'outputDim'.
  resize_input <= std_logic_vector(resize(unsigned(inputV), outputDim));

  -- Shift Left Operation:
  -- The 'shift_left' function shifts the 'resize_input' left by 'bitToShift' bits.
  -- The result is assigned to the 'outputV'.
  outputV <= std_logic_vector(shift_left(unsigned(resize_input), bitToShift));

end behavioral;
