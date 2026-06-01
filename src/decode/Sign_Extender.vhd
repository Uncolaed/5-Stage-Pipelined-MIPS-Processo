--------------------------------------------------------------------------------
-- Entity: Sign_Extend
-- Description:
-- A generic sign-extension module that extends an input signal to a larger size.
-- The sizes of the input and output are configurable using generics.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.std_logic_1164.all; -- Standard library for std_logic types
use IEEE.numeric_std.all;    -- Supports signed and unsigned numeric operations

--===========================================
-- Entity Declaration
--===========================================
entity Sign_Extend is
  generic(
    INPUT_SIZE  : natural := 16; -- Size of the input signal (default is 16 bits)
    OUTPUT_SIZE : natural := 32  -- Size of the output signal (default is 32 bits)
  );
  port(
    a : in  std_logic_vector(INPUT_SIZE-1 downto 0); -- Input signal to be sign-extended
    y : out std_logic_vector(OUTPUT_SIZE-1 downto 0) -- Sign-extended output signal
  );
end Sign_Extend;

--===========================================
-- Architecture Definition
--===========================================
architecture behavioral of Sign_Extend is
begin

  -- Sign-Extension Logic
  -- The 'resize' function extends the signed input signal 'a' to match the output size.
  y <= std_logic_vector(resize(signed(a), OUTPUT_SIZE));

end behavioral;
