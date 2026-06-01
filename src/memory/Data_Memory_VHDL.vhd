--------------------------------------------------------------------------------
-- Entity: Data_Memory_VHDL
-- Description:
-- Data Memory module for the MIPS processor.
-- Supports synchronous write and asynchronous read operations.
-- Uses word-aligned addressing from the byte address supplied by the ALU.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

--===========================================
-- Entity Declaration
--===========================================
entity Data_Memory_VHDL is
    generic (
        DATA_WIDTH : integer := 32; -- Default data width is 32 bits
        MEM_SIZE   : integer := 256 -- Default memory size in 32-bit words
    );
    port (
        clk            : in  std_logic; -- System clock signal
        mem_access_addr: in  std_logic_vector(15 downto 0); -- Byte address from the ALU
        mem_write_data : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- Data to write into memory
        mem_write_en   : in  std_logic; -- Write enable signal (1 = write to memory)
        mem_read       : in  std_logic; -- Read enable signal (1 = read from memory)
        mem_read_data  : out std_logic_vector(DATA_WIDTH-1 downto 0) -- Data read from memory
    );
end Data_Memory_VHDL;

--===========================================
-- Architecture Definition
--===========================================
architecture Behavioral of Data_Memory_VHDL is

    -- Define memory array.
    type data_mem is array (0 to MEM_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal RAM : data_mem := (-- Preloaded Data Values
        0  => x"00000005", -- Address 0x0000
        1  => x"00000010", -- Address 0x0004
        2  => x"000000FF", -- Address 0x0008
        3  => x"0000AAAA", -- Address 0x000C
        4  => x"00005555", -- Address 0x0010
        others => (others => '0')); -- Remaining memory initialized to zero

    signal word_index : natural;

begin

    -- Convert the byte address to a word index.
    word_index <= to_integer(unsigned(mem_access_addr(15 downto 2)));

    --===========================================
    -- Write Operation (Synchronous Write)
    --===========================================
    process(clk)
    begin
        if rising_edge(clk) then -- Triggered on the rising edge of the clock
            if (mem_write_en = '1') and (word_index < MEM_SIZE) then -- Check if write enable is active
                RAM(word_index) <= mem_write_data;
            end if;
        end if;
    end process;

    --===========================================
    -- Read Operation (Asynchronous Read)
    --===========================================
    -- If mem_read is active, output the memory contents at mem_access_addr.
    -- Otherwise, output zero
    mem_read_data <= RAM(word_index)
        when (mem_read = '1') and (word_index < MEM_SIZE)
        else (others => '0');

end Behavioral;
