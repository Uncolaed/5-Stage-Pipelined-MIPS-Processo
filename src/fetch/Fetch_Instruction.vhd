--------------------------------------------------------------------------------
-- Entity: Fetch_Instruction
-- Description:
-- Handles the Instruction Fetch stage of the MIPS pipeline.
-- Combines Program Counter (PC), instruction memory, and an adder with branching
-- and jumping logic. Outputs the current instruction and PC to the next stage.
-- All PC-related signals use the PC_SIZE generic for consistency.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.std_logic_1164.all; -- Standard library for std_logic types
use IEEE.numeric_std.all;    -- Supports numeric operations

--===========================================
-- Entity Declaration
--===========================================
entity Fetch_Instruction is
  generic(
    PC_SIZE    : natural := 32; -- Program Counter size
    INSTR_SIZE : natural := 32  -- Instruction size (32 bits standard for MIPS)
  );
  port(
    -- Clock and Reset Signals
    clk                 : in std_logic; -- System clock signal for synchronization
    resetProgCounter    : in std_logic; -- Reset signal for the Program Counter (PC)

    -- Pipeline Reset Signal
    resetPipeline1      : in std_logic; -- Reset signal for the Pipeline Stage One registers

    -- Branch MUX Signals
    muxBranchControlIn1 : in std_logic; -- Control signal for Branch MUX (0: PC+4, 1: Branch Target)
    muxBranchExtIn1     : in std_logic_vector(PC_SIZE-1 downto 0); -- Branch target address

    -- Jump MUX Signals
    muxJumpControlIn1   : in std_logic; -- Control signal for Jump MUX (0: Branch MUX, 1: Jump Target)
    muxJumpExtIn1       : in std_logic_vector(PC_SIZE-1 downto 0); -- Jump target address

    -- Outputs to the Next Pipeline Stage
    pcOut1              : out std_logic_vector(PC_SIZE-1 downto 0); -- Output Program Counter (PC)
    instructionOut1     : out std_logic_vector(INSTR_SIZE-1 downto 0) -- Output Instruction
  );
end Fetch_Instruction;

--===========================================
-- Architecture Definition
--===========================================
architecture behavioral of Fetch_Instruction is

  --===========================================
  -- Component Declarations
  --===========================================
  -- Program Counter Component
  component Program_Counter is
    generic (
      PC_SIZE : natural := 32 -- Size of the Program Counter
    );
    port (
      clk            : in std_logic; -- Clock signal
      resetPC        : in std_logic; -- Reset signal for PC
      nextAddress    : in std_logic_vector(PC_SIZE-1 downto 0); -- Next PC address
      currentAddress : out std_logic_vector(PC_SIZE-1 downto 0) -- Current PC address
    );
  end component;

  -- Instruction Memory Component
  component Instruction_Memory_VHDL is
    generic (
      DATA_WIDTH : integer := 32; -- Instruction size (default is 32 bits)
      MEM_SIZE   : integer := 256; -- Memory size (default is 256 instructions)
      PC_SIZE    : integer := 32 -- Size of the Program Counter
    );
    port (
      pc          : in std_logic_vector(PC_SIZE-1 downto 0); -- Program Counter address
      instruction : out std_logic_vector(DATA_WIDTH-1 downto 0) -- Fetched instruction
    );
  end component;

  -- Adder Component
  component Adder is
    generic(
      dimension : natural := 32 -- Data width matches PC_SIZE
    );
    port(
      a   : in std_logic_vector(dimension - 1 downto 0); -- First input to the adder
      b   : in std_logic_vector(dimension - 1 downto 0); -- Second input to the adder
      sum : out std_logic_vector(dimension - 1 downto 0) -- Sum output from the adder
    );
  end component;

  -- Pipeline Stage One Component
  component PipeLine_Stage_One is
    generic(
      PC_SIZE    : natural := 32; -- Program Counter size
      INSTR_SIZE : natural := 32 -- Instruction size
    );
    port (
      clk               : in std_logic; -- Clock signal
      resetPL1          : in std_logic; -- Reset signal for pipeline registers
      storedPC          : in std_logic_vector(PC_SIZE-1 downto 0); -- Input: Stored PC value
      storedInstruction : in std_logic_vector(INSTR_SIZE-1 downto 0); -- Input: Stored instruction
      getPC             : out std_logic_vector(PC_SIZE-1 downto 0); -- Output: Pipeline PC value
      getInstruction    : out std_logic_vector(INSTR_SIZE-1 downto 0) -- Output: Pipeline instruction
    );
  end component;

  -- Multiplexer Component
  component MUX is
    generic(
      dimension : natural := 32 -- Data width matches PC_SIZE
    );
    port(
      controlSignal  : in std_logic; -- Control signal for MUX
      signal1        : in std_logic_vector(dimension - 1 downto 0); -- First input
      signal2        : in std_logic_vector(dimension - 1 downto 0); -- Second input
      selectedSignal : out std_logic_vector(dimension - 1 downto 0) -- Selected output
    );
  end component;

  --===========================================
  -- Internal Signals
  --===========================================
  signal sPcIn        : std_logic_vector(PC_SIZE-1 downto 0); -- Selected PC Address
  signal sOutPC       : std_logic_vector(PC_SIZE-1 downto 0); -- Current address from PC
  signal sAddResult   : std_logic_vector(PC_SIZE-1 downto 0); -- Result of PC + 4 Adder
  signal sStoreInstr  : std_logic_vector(INSTR_SIZE-1 downto 0); -- Fetched instruction
  signal sMuxBOut     : std_logic_vector(PC_SIZE-1 downto 0); -- Output of Branch MUX
  signal sPlusFour    : std_logic_vector(PC_SIZE-1 downto 0); -- Constant for PC + 4

begin

  sPlusFour <= std_logic_vector(to_unsigned(4, PC_SIZE));
  -- Branch MUX
  branchMux : MUX
    generic map (PC_SIZE)
    port map (
      controlSignal => muxBranchControlIn1,
      signal1 => sAddResult,
      signal2 => muxBranchExtIn1,
      selectedSignal => sMuxBOut
    );

  -- Jump MUX
  jumpMux : MUX
    generic map (PC_SIZE)
    port map (
      controlSignal => muxJumpControlIn1,
      signal1 => sMuxBOut,
      signal2 => muxJumpExtIn1,
      selectedSignal => sPcIn
    );

  -- Program Counter
  nextAddress : Program_Counter
    generic map (PC_SIZE)
    port map (
      clk => clk,
      resetPC => resetProgCounter,
      nextAddress => sPcIn,
      currentAddress => sOutPC
    );

  -- Adder: Calculate PC + 4
  sum : Adder
    generic map (PC_SIZE)
    port map (
      a => sOutPC,
      b => sPlusFour,
      sum => sAddResult
    );

  -- Instruction Memory
  get_memory : Instruction_Memory_VHDL
    generic map (32, 256, PC_SIZE)
    port map (
      pc => sOutPC,
      instruction => sStoreInstr
    );

  -- Pipeline Stage One
  pipeline : PipeLine_Stage_One
    generic map (PC_SIZE, INSTR_SIZE)
    port map (
      clk => clk,
      resetPL1 => resetPipeline1,
      storedPC => sAddResult,
      storedInstruction => sStoreInstr,
      getPC => pcOut1,
      getInstruction => instructionOut1
    );

end behavioral;
