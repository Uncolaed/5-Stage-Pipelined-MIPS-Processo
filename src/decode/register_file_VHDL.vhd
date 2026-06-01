--------------------------------------------------------------------------------
-- Entity: register_file_VHDL
-- Description:
-- Synchronous register file for the MIPS processor.
-- Supports asynchronous read and synchronous write operations.
-- Includes reset functionality with predefined register values.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- Standard logic library
use IEEE.numeric_std.ALL;    -- Numeric operations

--===========================================
-- Entity Declaration
--===========================================
entity register_file_VHDL is
    generic (
        DATA_WIDTH : integer := 32; -- Data width per register
        NUM_REGS   : integer := 32  -- Number of registers
    );
    port (
        -- Control Signals
        clk             : in  std_logic; -- Clock signal
        rst             : in  std_logic; -- Reset signal
        reg_write_en    : in  std_logic; -- Write enable signal

        -- Write Port
        reg_write_dest  : in  std_logic_vector(4 downto 0); -- Write register address
        reg_write_data  : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- Data to write

        -- Read Ports
        reg_read_addr_1 : in  std_logic_vector(4 downto 0); -- Read address 1
        reg_read_data_1 : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Data from read address 1
        reg_read_addr_2 : in  std_logic_vector(4 downto 0); -- Read address 2
        reg_read_data_2 : out std_logic_vector(DATA_WIDTH-1 downto 0) -- Data from read address 2
    );
end register_file_VHDL;

architecture Behavioral of register_file_VHDL is

    -- Define Register Array
    type reg_type is array (0 to NUM_REGS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg_array : reg_type := (
        -- First 16: Meaningful Initial Values
        0  => (others => '0'), -- $zero is always zero
        1  => x"00000001",
        2  => x"00000002",
        3  => x"00000003",
        4  => x"00000004",
        5  => x"00000005",
        6  => x"00000006",
        7  => x"00000007",
        8  => x"00000008",
        9  => x"00000009",
        10 => x"0000000A",
        11 => x"0000000B",
        12 => x"0000000C",
        13 => x"0000000D",
        14 => x"0000000E",
        15 => x"0000000F",

        -- Last 16: Sequential Numbers
        16 => x"00000010",
        17 => x"00000011",
        18 => x"00000012",
        19 => x"00000013",
        20 => x"00000014",
        21 => x"00000015",
        22 => x"00000016",
        23 => x"00000017",
        24 => x"00000018",
        25 => x"00000019",
        26 => x"0000001A",
        27 => x"0000001B",
        28 => x"0000001C",
        29 => x"0000001D",
        30 => x"0000001E",
        31 => x"0000001F"
    );

begin

    --===========================================
    -- Synchronous Write Process
    --===========================================
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset Registers
            reg_array(0) <= (others => '0'); -- Protect $zero register
            reg_array(1) <= x"00000001";
            reg_array(2) <= x"00000002";
            reg_array(3) <= x"00000003";
            reg_array(4) <= x"00000004";
            reg_array(5) <= x"00000005";
            reg_array(6) <= x"00000006";
            reg_array(7) <= x"00000007";
            reg_array(8) <= x"00000008";
            reg_array(9) <= x"00000009";
            reg_array(10) <= x"0000000A";
            reg_array(11) <= x"0000000B";
            reg_array(12) <= x"0000000C";
            reg_array(13) <= x"0000000D";
            reg_array(14) <= x"0000000E";
            reg_array(15) <= x"0000000F";
            reg_array(16) <= x"00000010";
            reg_array(17) <= x"00000011";
            reg_array(18) <= x"00000012";
            reg_array(19) <= x"00000013";
            reg_array(20) <= x"00000014";
            reg_array(21) <= x"00000015";
            reg_array(22) <= x"00000016";
            reg_array(23) <= x"00000017";
            reg_array(24) <= x"00000018";
            reg_array(25) <= x"00000019";
            reg_array(26) <= x"0000001A";
            reg_array(27) <= x"0000001B";
            reg_array(28) <= x"0000001C";
            reg_array(29) <= x"0000001D";
            reg_array(30) <= x"0000001E";
            reg_array(31) <= x"0000001F";

        elsif rising_edge(clk) then
            -- Write Operation with Write Enable and Protection for $zero
            if reg_write_en = '1' and reg_write_dest /= "00000" then
                reg_array(to_integer(unsigned(reg_write_dest))) <= reg_write_data;
            end if;
        end if;
    end process;

    --===========================================
    -- Asynchronous Read Process
    --===========================================
    -- Read Register 1
    reg_read_data_1 <= (others => '0')
        when reg_read_addr_1 = "00000"
        else reg_array(to_integer(unsigned(reg_read_addr_1)));

    -- Read Register 2
    reg_read_data_2 <= (others => '0')
        when reg_read_addr_2 = "00000"
        else reg_array(to_integer(unsigned(reg_read_addr_2)));

end Behavioral;
