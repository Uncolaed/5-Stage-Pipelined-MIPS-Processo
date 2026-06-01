--------------------------------------------------------------------------------
-- Entity: Instruction_Memory_VHDL
-- Description:
-- Instruction Memory module for the MIPS processor.
-- Fetches instructions based on the Program Counter (PC).
-- Preloaded with meaningful binary instructions for testing.
-- Now includes a configurable PC size for debugging purposes.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- Standard library for std_logic types
use IEEE.numeric_std.ALL;    -- Supports numeric operations

--===========================================
-- Entity Declaration
--===========================================
entity Instruction_Memory_VHDL is
    generic (
        DATA_WIDTH : integer := 32; -- Instruction size (32 bits for MIPS)
        MEM_SIZE   : integer := 256; -- Number of instructions (256 for testing)
        PC_SIZE    : integer := 32   -- Program Counter size
    );
    port (
        pc          : in  std_logic_vector(PC_SIZE-1 downto 0); -- Program Counter Address
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
        -- Preloaded Instructions (Binary Representation)
        -- ADDI $1, $0, 10 -> $1 = $0 + 10
        "00100000000000010000000000001010", -- ADDI $1, $0, 10
        -- LW $2, 4($0) -> Load memory[4] into $2
        "10001100000000100000000000000100", -- LW $2, 4($0)
        -- ADD $3, $1, $2 -> $3 = $1 + $2
        "00000000001000100001100000100000", -- ADD $3, $1, $2
        -- SW $3, 8($0) -> Store $3 into memory[8]
        "10101100000000110000000000001000", -- SW $3, 8($0)
        -- SUB $4, $1, $2 -> $4 = $1 - $2
        "00000000001000100010000000100010", -- SUB $4, $1, $2
        -- AND $5, $1, $2 -> $5 = $1 AND $2
        "00000000001000100010100000100100", -- AND $5, $1, $2
        -- OR $6, $1, $2 -> $6 = $1 OR $2
        "00000000001000100011000000100101", -- OR $6, $1, $2
        -- NOP (No Operation)
        "00000000000000000000000000000000", -- NOP
        -- Fill remaining with NOP
        others => (others => '0')
    );

begin

    --===========================================
    -- Instruction Fetch
    --===========================================
    -- Use PC as an address index into the instruction memory array
    -- The address is calculated using the upper bits of the PC to match memory size
    instruction <= rom_data(to_integer(unsigned(pc(PC_SIZE-1 downto 2))))
    when to_integer(unsigned(pc(PC_SIZE-1 downto 2))) < MEM_SIZE
    else (others => '0'); -- Return NOP for out-of-range addresses


end Behavioral;
