--------------------------------------------------------------------------------
-- Entity: control_unit_VHDL
-- Description:
-- Control Unit for the MIPS processor reference design.
-- Generates control signals based on the opcode.
-- Aligns with updated Data Memory, ALU, and Register File modules.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--===========================================
-- Entity Declaration
--===========================================
entity control_unit_VHDL is
    port (
        opcode         : in  std_logic_vector(5 downto 0); -- 6-bit opcode for instruction decoding
        reset          : in  std_logic; -- Reset signal
        reg_dst        : out std_logic_vector(1 downto 0); -- Select register destination
        mem_to_reg     : out std_logic_vector(1 downto 0); -- Select memory or ALU result
        alu_op         : out std_logic_vector(1 downto 0); -- ALU operation type
        jump           : out std_logic; -- Jump control signal
        branch         : out std_logic; -- Branch control signal
        mem_read       : out std_logic; -- Memory read signal
        mem_write      : out std_logic; -- Memory write signal
        alu_src        : out std_logic; -- ALU source (immediate or register)
        reg_write      : out std_logic; -- Register write enable
        sign_or_zero   : out std_logic -- Select signed or zero-extended immediate
    );
end control_unit_VHDL;

--===========================================
-- Architecture Definition
--===========================================
architecture Behavioral of control_unit_VHDL is
begin

    --===========================================
    -- Control Signals Generation
    --===========================================
    process(reset, opcode)
    begin
        if reset = '1' then
            -- Default values on reset
            reg_dst      <= "00";
            mem_to_reg   <= "00";
            alu_op       <= "00";
            jump         <= '0';
            branch       <= '0';
            mem_read     <= '0';
            mem_write    <= '0';
            alu_src      <= '0';
            reg_write    <= '0';
            sign_or_zero <= '1';
        else
            case opcode is
                -- R-type Instructions
                when "000000" =>  -- ADD, SUB, AND, OR, SLT
                    reg_dst      <= "01";
                    mem_to_reg   <= "00";
                    alu_op       <= "10";
                    jump         <= '0';
                    branch       <= '0';
                    mem_read     <= '0';
                    mem_write    <= '0';
                    alu_src      <= '0';
                    reg_write    <= '1';
                    sign_or_zero <= '1';

                -- Load Word (LW)
                when "100011" =>
                    reg_dst      <= "00";
                    mem_to_reg   <= "01";
                    alu_op       <= "00";
                    jump         <= '0';
                    branch       <= '0';
                    mem_read     <= '1';
                    mem_write    <= '0';
                    alu_src      <= '1';
                    reg_write    <= '1';
                    sign_or_zero <= '1';

                -- Store Word (SW)
                when "101011" =>
                    reg_dst      <= "00";
                    mem_to_reg   <= "00";
                    alu_op       <= "00";
                    jump         <= '0';
                    branch       <= '0';
                    mem_read     <= '0';
                    mem_write    <= '1';
                    alu_src      <= '1';
                    reg_write    <= '0';
                    sign_or_zero <= '1';

                -- Branch Equal (BEQ)
                when "000100" =>
                    reg_dst      <= "00";
                    mem_to_reg   <= "00";
                    alu_op       <= "01";
                    jump         <= '0';
                    branch       <= '1';
                    mem_read     <= '0';
                    mem_write    <= '0';
                    alu_src      <= '0';
                    reg_write    <= '0';
                    sign_or_zero <= '1';

                -- Jump (J)
                when "000010" =>
                    reg_dst      <= "00";
                    mem_to_reg   <= "00";
                    alu_op       <= "00";
                    jump         <= '1';
                    branch       <= '0';
                    mem_read     <= '0';
                    mem_write    <= '0';
                    alu_src      <= '0';
                    reg_write    <= '0';
                    sign_or_zero <= '1';

                -- Immediate Addition (ADDI)
                when "001000" =>
                    reg_dst      <= "00";
                    mem_to_reg   <= "00";
                    alu_op       <= "11";
                    jump         <= '0';
                    branch       <= '0';
                    mem_read     <= '0';
                    mem_write    <= '0';
                    alu_src      <= '1';
                    reg_write    <= '1';
                    sign_or_zero <= '1';

                -- Default Case
                when others =>
                    reg_dst      <= "00";
                    mem_to_reg   <= "00";
                    alu_op       <= "00";
                    jump         <= '0';
                    branch       <= '0';
                    mem_read     <= '0';
                    mem_write    <= '0';
                    alu_src      <= '0';
                    reg_write    <= '0';
                    sign_or_zero <= '1';
            end case;
        end if;
    end process;

end Behavioral;
