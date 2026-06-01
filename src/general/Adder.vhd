--------------------------------------------------------------------------------
-- Entity: Adder
-- Description:
-- A generic adder module that performs the addition of two vectors of configurable
-- dimensions. The dimension is defined using a generic parameter for flexibility.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.std_logic_1164.all; -- Standard logic library for std_logic_vector
use IEEE.numeric_std.all; -- Provides numeric operations for signed and unsigned types

--===========================================
-- Entity Declaration
--===========================================
entity adder is
  generic(
    dimension : natural := 32 -- Generic parameter to set vector size (default is 32 bits)
  );
  port(
    a   : in std_logic_vector(dimension - 1 downto 0); -- First operand for addition
    b   : in std_logic_vector(dimension - 1 downto 0); -- Second operand for addition
    sum : out std_logic_vector(dimension - 1 downto 0) -- Output: Result of the addition
  );
end adder;

--===========================================
-- Architecture Definition
--===========================================
architecture behavioral of adder is
begin
  -- Simple unsigned addition operation.
  sum <= std_logic_vector(unsigned(a) + unsigned(b));
end behavioral;
