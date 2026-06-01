--------------------------------------------------------------------------------
-- Entity: control_unit_new
-- Description:
-- Control Unit for the pipelined MIPS processor.
-- Generates control signals based on the opcode and funct field.
-- ALU control logic is integrated directly within the control unit.
-- Includes generic parameters for signal sizes.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

--===========================================
-- Entity Declaration
--===========================================
entity control_unit_new is
    generic (
        OPCODE_SIZE : natural := 6; -- Size of the opcode
        FUNCT_SIZE  : natural := 6; -- Size of the funct field
        ALU_OP_SIZE : natural := 3  -- Size of the ALU operation signal
    );
    port (
        opcode         : in  std_logic_vector(OPCODE_SIZE-1 downto 0); -- Opcode for instruction decoding
        funct          : in  std_logic_vector(FUNCT_SIZE-1 downto 0); -- Function field for R-type instructions
        reset          : in  std_logic; -- Reset signal

        -- Control Signals
        reg_dst        : out std_logic; -- Select register destination
        mem_to_reg     : out std_logic; -- Select memory or ALU result
        alu_op         : out std_logic_vector(ALU_OP_SIZE-1 downto 0); -- ALU operation type
        jump           : out std_logic; -- Jump control signal
        branch         : out std_logic; -- Branch control signal
        mem_read       : out std_logic; -- Memory read signal
        mem_write      : out std_logic; -- Memory write signal
        alu_src        : out std_logic; -- ALU source (immediate or register)
        reg_write      : out std_logic  -- Register write enable
    );
end control_unit_new;

--===========================================
-- Architecture Definition
--===========================================
architecture Behavioral of control_unit_new is
begin

    --===========================================
    -- Control Signals Generation
    --===========================================
    process(reset, opcode, funct)
    begin
        if reset = '1' then
            -- Default reset values
            reg_dst      <= '0';
            mem_to_reg   <= '0';
            alu_op       <= (others => '0');
            jump         <= '0';
            branch       <= '0';
            mem_read     <= '0';
            mem_write    <= '0';
            alu_src      <= '0';
            reg_write    <= '0';
        else
            case opcode is
                -- R-type Instructions (opcode = 000000)
                when "000000" =>
                    reg_dst      <= '1';
                    mem_to_reg   <= '0';
                    jump         <= '0';
                    branch       <= '0';
                    mem_read     <= '0';
                    mem_write    <= '0';
                    alu_src      <= '0';
                    reg_write    <= '1';

                    -- ALU Control Based on `funct`
                    case funct is
                        when "100000" => alu_op <= "010"; -- ADD
                        when "100010" => alu_op <= "110"; -- SUB
                        when "100100" => alu_op <= "000"; -- AND
                        when "100101" => alu_op <= "001"; -- OR
                        when "101010" => alu_op <= "111"; -- SLT
                        when "000000" => alu_op <= "011"; -- NOP
                        when others   => alu_op <= "011"; -- Treat unsupported R-type funct as NOP
                    end case;

                -- Load Word (LW, opcode = 100011)
                when "100011" =>
                    reg_dst      <= '0';
                    mem_to_reg   <= '1';
                    alu_op       <= "010";
                    jump         <= '0';
                    branch       <= '0';
                    mem_read     <= '1';
                    mem_write    <= '0';
                    alu_src      <= '1';
                    reg_write    <= '1';

                -- Store Word (SW, opcode = 101011)
                when "101011" =>
                    reg_dst      <= '0';
                    mem_to_reg   <= '0';
                    alu_op       <= "010";
                    jump         <= '0';
                    branch       <= '0';
                    mem_read     <= '0';
                    mem_write    <= '1';
                    alu_src      <= '1';
                    reg_write    <= '0';

                -- Branch Equal (BEQ, opcode = 000100)
                when "000100" =>
                    reg_dst      <= '0';
                    mem_to_reg   <= '0';
                    alu_op       <= "110";
                    jump         <= '0';
                    branch       <= '1';
                    mem_read     <= '0';
                    mem_write    <= '0';
                    alu_src      <= '0';
                    reg_write    <= '0';

                -- Jump (J, opcode = 000010)
                when "000010" =>
                    reg_dst      <= '0';
                    mem_to_reg   <= '0';
                    alu_op       <= "000";
                    jump         <= '1';
                    branch       <= '0';
                    mem_read     <= '0';
                    mem_write    <= '0';
                    alu_src      <= '0';
                    reg_write    <= '0';

                -- Add Immediate (ADDI, opcode = 001000)
                when "001000" =>
                    reg_dst      <= '0'; -- Destination is rt
                    mem_to_reg   <= '0'; -- Result comes from ALU
                    alu_op       <= "010"; -- ADD operation
                    jump         <= '0'; -- Not a jump instruction
                    branch       <= '0'; -- Not a branch instruction
                    mem_read     <= '0'; -- No memory read
                    mem_write    <= '0'; -- No memory write
                    alu_src      <= '1'; -- Use immediate value as ALU operand
                    reg_write    <= '1'; -- Write to destination register

                -- Default Case
                when others =>
                    reg_dst      <= '0';
                    mem_to_reg   <= '0';
                    alu_op       <= (others => '0');
                    jump         <= '0';
                    branch       <= '0';
                    mem_read     <= '0';
                    mem_write    <= '0';
                    alu_src      <= '0';
                    reg_write    <= '0';
            end case;
        end if;
    end process;

end Behavioral;
