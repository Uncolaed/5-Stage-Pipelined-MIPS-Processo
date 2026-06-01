--------------------------------------------------------------------------------
-- Entity: ALU_Control_VHDL
-- Description:
-- ALU Control Unit for the MIPS processor reference design.
-- Determines the ALU operation based on ALUOp and ALU_Funct signals.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--===========================================
-- Entity Declaration
--===========================================
entity ALU_Control_VHDL is
    port(
        ALU_Control : out std_logic_vector(2 downto 0); -- ALU operation selector
        ALUOp       : in  std_logic_vector(1 downto 0); -- Instruction type selector
        ALU_Funct   : in  std_logic_vector(5 downto 0)  -- Function code for R-type instructions
    );
end ALU_Control_VHDL;

--===========================================
-- Architecture Definition
--===========================================
architecture Behavioral of ALU_Control_VHDL is
begin

    --===========================================
    -- ALU Control Process
    --===========================================
    process(ALUOp, ALU_Funct)
    begin
        case ALUOp is
            -- Case 1: Memory access instructions use ADD (ALUOp = 00)
            when "00" =>
                ALU_Control <= "010"; -- ADD

            -- Case 2: Branch comparison uses SUB (ALUOp = 01)
            when "01" =>
                ALU_Control <= "110"; -- SUB

            -- Case 3: R-type instruction (ALUOp = 10)
            when "10" =>
                case ALU_Funct is
                    when "100000" => ALU_Control <= "010"; -- ADD
                    when "100010" => ALU_Control <= "110"; -- SUB
                    when "100100" => ALU_Control <= "000"; -- AND
                    when "100101" => ALU_Control <= "001"; -- OR
                    when "101010" => ALU_Control <= "111"; -- SLT
                    when "000000" => ALU_Control <= "011"; -- NOP
                    when others   => ALU_Control <= "011"; -- Treat unsupported funct as NOP
                end case;

            -- Case 4: ADDI uses ADD (ALUOp = 11)
            when "11" =>
                ALU_Control <= "010"; -- ADD

            -- Default Case (safety fallback)
            when others =>
                ALU_Control <= "011"; -- NOP
        end case;
    end process;

end Behavioral;
