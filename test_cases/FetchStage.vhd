library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity IF_Stage is
    Port (
        clk               : in  std_logic;
        reset             : in  std_logic;
        instruction_memory: in  mem_array;
        pc_out            : out std_logic_vector(31 downto 0); -- PC Output
        IF_ID_instruction : out std_logic_vector(31 downto 0); -- Instruction Output
        IF_ID_PC          : out std_logic_vector(31 downto 0)  -- PC passed to next stage
    );
end IF_Stage;

architecture Behavioral of IF_Stage is

    -- Program Counter Signals
    signal pc_current, pc_next, pc_plus4 : std_logic_vector(31 downto 0);

begin

    --===========================================
    -- Program Counter (PC) Logic
    --===========================================
    process(clk, reset)
    begin
        if reset = '1' then
            pc_current <= (others => '0');
        elsif rising_edge(clk) then
            pc_current <= pc_next;
        end if;
    end process;

    -- Increment PC by 4
    pc_plus4 <= std_logic_vector(unsigned(pc_current) + 4);

    -- Update PC (for now, no branch or jump logic)
    pc_next <= pc_plus4;

    --===========================================
    -- Instruction Fetch (IF) Stage
    --===========================================
    process(clk, reset)
    begin
        if reset = '1' then
            IF_ID_instruction <= (others => '0');
            IF_ID_PC <= (others => '0');
        elsif rising_edge(clk) then
            -- Fetch instruction from memory
            IF_ID_instruction <= instruction_memory(to_integer(unsigned(pc_current(15 downto 2))));
            IF_ID_PC <= pc_current;
        end if;
    end process;

    -- PC Output
    pc_out <= pc_current;

end Behavioral;
