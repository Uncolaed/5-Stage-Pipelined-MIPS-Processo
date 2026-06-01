--------------------------------------------------------------------------------
-- Entity: ALU_VHDL
-- Description:
-- Arithmetic Logic Unit (ALU) for MIPS Processor.
-- Supports ADD, SUB, AND, OR, and SLT operations.
-- Outputs the result and a Zero flag.
-- Now supports configurable DATA_WIDTH using generics.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

--===========================================
-- Entity Declaration
--===========================================
entity ALU_VHDL is
    generic (
        DATA_WIDTH : integer := 32 -- Default data width is 32 bits
    );
    port(
        a           : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- Operand 1 (src1)
        b           : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- Operand 2 (src2)
        alu_control : in  std_logic_vector(2 downto 0); -- ALU operation selector
        alu_result  : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Result of ALU operation
        zero        : out std_logic -- Zero flag
    );
end ALU_VHDL;

--===========================================
-- Architecture Definition
--===========================================
architecture Behavioral of ALU_VHDL is
    signal result : std_logic_vector(DATA_WIDTH-1 downto 0); -- Internal ALU result
begin

    --===========================================
    -- ALU Operation Selection Process
    --===========================================
    process(alu_control, a, b)
    begin
        case alu_control is
            when "010" =>
                -- ADD: Perform addition of two operands
                result <= std_logic_vector(signed(a) + signed(b));

            when "110" =>
                -- SUB: Perform subtraction of two operands
                result <= std_logic_vector(signed(a) - signed(b));

            when "000" =>
                -- AND: Perform bitwise AND operation
                result <= a and b;

            when "001" =>
                -- OR: Perform bitwise OR operation
                result <= a or b;

            when "111" =>
                -- SLT (Set on Less Than): Check if a < b
                if signed(a) < signed(b) then
                    result <= std_logic_vector(to_unsigned(1, DATA_WIDTH)); -- Set result to 1 if a < b
                else
                    result <= std_logic_vector(to_unsigned(0, DATA_WIDTH)); -- Set result to 0 otherwise
                end if;

            when "011" =>
                -- NOP: Drive zero for the no-operation encoding.
                result <= (others => '0');

            when others =>
                -- Default Case: Drive zero for unsupported operations.
                result <= (others => '0');
        end case;
    end process;

    --===========================================
    -- Zero Flag Logic
    --===========================================
    -- Set the Zero flag if result is zero
    zero <= '1' when result = std_logic_vector(to_unsigned(0, DATA_WIDTH)) else '0';

    -- Pass the result to the output port
    alu_result <= result;

end Behavioral;
