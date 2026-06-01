--------------------------------------------------------------------------------
-- Entity: register_file_VHDL
-- Description:
-- Register File module for the MIPS processor reference design.
-- Supports register read and write operations.
-- Preloaded with initial values for testing.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

--===========================================
-- Entity Declaration
--===========================================
entity register_file_VHDL is
    generic (
        DATA_WIDTH : integer := 32; -- Default data width is 32 bits
        NUM_REGS   : integer := 32   -- Number of registers
    );
    port (
        clk             : in  std_logic; -- System clock signal
        rst             : in  std_logic; -- Reset signal
        reg_write_en    : in  std_logic; -- Write enable signal
        reg_write_dest  : in  std_logic_vector(4 downto 0); -- Write register address
        reg_write_data  : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- Write data
        reg_read_addr_1 : in  std_logic_vector(4 downto 0); -- Read address 1
        reg_read_data_1 : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Read data 1
        reg_read_addr_2 : in  std_logic_vector(4 downto 0); -- Read address 2
        reg_read_data_2 : out std_logic_vector(DATA_WIDTH-1 downto 0) -- Read data 2
    );
end register_file_VHDL;

--===========================================
-- Architecture Definition
--===========================================
architecture Behavioral of register_file_VHDL is

    -- Register Array: Holds NUM_REGS registers, each of size DATA_WIDTH
    type reg_type is array (0 to NUM_REGS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg_array : reg_type := (
        0  => (others => '0'), -- $zero (constant zero)
        1  => x"00000001", -- $1: Example Integer
        2  => x"00000010", -- $2: Example Integer
        3  => x"00000020", -- $3: Example Integer
        4  => x"0000AAAA", -- $4: Test Pattern
        5  => x"00005555", -- $5: Test Pattern
        6  => x"0000FFFF", -- $6: Max Value
        7  => x"12345678", -- $7: Example Data
        others => (others => '0')
    );

begin

    --===========================================
    -- Synchronous Write Process
    --===========================================
    process(clk, rst)
    begin
        if rst = '1' then
            -- Initialize Registers with Default Values on Reset
            reg_array(0) <= (others => '0'); -- $zero remains zero
            reg_array(1) <= x"00000001";
            reg_array(2) <= x"00000010";
            reg_array(3) <= x"00000020";
            reg_array(4) <= x"0000AAAA";
            reg_array(5) <= x"00005555";
            reg_array(6) <= x"0000FFFF";
            reg_array(7) <= x"12345678";
        elsif rising_edge(clk) then
            if reg_write_en = '1' and reg_write_dest /= "00000" then
                -- Write data to the specified register (except $zero)
                reg_array(to_integer(unsigned(reg_write_dest))) <= reg_write_data;
            end if;
        end if;
    end process;

    --===========================================
    -- Asynchronous Read Process
    --===========================================
    -- Read from Register 1
    reg_read_data_1 <= (others => '0')
        when reg_read_addr_1 = "00000"
        else reg_array(to_integer(unsigned(reg_read_addr_1)));

    -- Read from Register 2
    reg_read_data_2 <= (others => '0')
        when reg_read_addr_2 = "00000"
        else reg_array(to_integer(unsigned(reg_read_addr_2)));

end Behavioral;
