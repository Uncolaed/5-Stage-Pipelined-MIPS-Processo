--------------------------------------------------------------------------------
-- Entity: Instruction_Memory_VHDL
-- Description:
-- Instruction Memory module for the MIPS processor reference design.
-- Fetches instructions based on the Program Counter (PC).
-- Preloaded with sample instructions for testing.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

--===========================================
-- Entity Declaration
--===========================================
entity Instruction_Memory_VHDL is
    generic (
        DATA_WIDTH : integer := 32; -- Instruction size (32 bits for MIPS)
        MEM_SIZE   : integer := 256 -- Number of instructions (256 for testing)
    );
    port (
        pc          : in  std_logic_vector(15 downto 0); -- Program Counter Address
        instruction : out std_logic_vector(DATA_WIDTH-1 downto 0) -- Fetched instruction
    );
end Instruction_Memory_VHDL;

--===========================================
-- Architecture Definition
--===========================================
architecture Behavioral of Instruction_Memory_VHDL is

    -- Memory Array: Array to hold instructions
    type rom_type is array (0 to MEM_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rom_data : rom_type := (
       -- Preloaded Example Instructions
        0  => x"8C130000", -- LW $19, 0($0)
        1  => x"2011000A", -- ADDI $17, $0, 10
        2  => x"00221820", -- ADD $3, $1, $2
        3  => x"20420001", -- ADDI $2, $2, 1
        4  => x"AC130004", -- SW $19, 4($0)
        5  => x"00000000", -- NOP
        6  => x"00231822", -- SUB $3, $1, $2
        7  => x"00000000", -- NOP
        8  => x"20080005", -- ADDI $8, $0, 5
        9  => x"AC08000C", -- SW $8, 12($0)
        10 => x"8C09000C", -- LW $9, 12($0)
        11 => x"00000000", -- NOP
        others => (others => '0') -- Fill unused memory with NOP
    );

begin

    --===========================================
    -- Instruction Fetch
    --===========================================
    -- Directly use pc as the memory address
    instruction <= rom_data(to_integer(unsigned(pc(15 downto 2))))
        when to_integer(unsigned(pc(15 downto 2))) < MEM_SIZE
        else (others => '0'); -- Return NOP for out-of-range addresses

end Behavioral;
