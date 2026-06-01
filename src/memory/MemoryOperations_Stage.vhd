--------------------------------------------------------------------------------
-- Entity: MemoryOperations_Stage
-- Description:
-- Memory access stage for the pipelined MIPS processor.
-- Handles data memory access and forwards write-back control/data.
--------------------------------------------------------------------------------

library IEEE; -- Import the IEEE library
use IEEE.std_logic_1164.all; -- Include support for std_logic data type
use IEEE.numeric_std.all; -- Include arithmetic operations for numeric types

-- Entity declaration for memoryOperations
entity MemoryOperations_Stage is
  port(
    clk              : in std_logic; -- System clock signal
    resetPipeline4   : in std_logic; -- Reset signal for the pipeline stage

    memToRegIn4      : in std_logic; -- Memory-to-Register control signal
    regWriteIn4      : in std_logic; -- Register write enable signal
    jumpIn4          : in std_logic; -- Jump control signal
    branchIn4        : in std_logic; -- Branch control signal
    memReadIn4       : in std_logic; -- Memory read enable signal
    memWriteIn4      : in std_logic; -- Memory write enable signal
    jumpAddrIn4      : in std_logic_vector(31 downto 0); -- Jump target address
    branchAddrIn4    : in std_logic_vector(31 downto 0); -- Branch target address
    zeroFlagIn4      : in std_logic; -- Zero flag from the ALU
    aluResultIn4     : in std_logic_vector(31 downto 0); -- ALU computation result
    readData2In4     : in std_logic_vector(31 downto 0); -- Data to write into memory
    registerIn4      : in std_logic_vector(4 downto 0); -- Register for write-back
    -- Output signals
    memToRegOut4     : out std_logic; -- Forwarded Memory-to-Register control signal
    regWriteOut4     : out std_logic; -- Forwarded Register write enable signal
    jumpOut4         : out std_logic; -- Forwarded Jump control signal
    branchOut4       : out std_logic; -- Forwarded Branch control signal
    jumpAddrOut4     : out std_logic_vector(31 downto 0); -- Forwarded Jump target address
    branchAddrOut4   : out std_logic_vector(31 downto 0); -- Forwarded Branch target address
    aluResultOut4    : out std_logic_vector(31 downto 0); -- Forwarded ALU computation result
    readDataMemOut4  : out std_logic_vector(31 downto 0); -- Data read from memory
    registerOut4     : out std_logic_vector(4 downto 0) -- Forwarded write-back register
  );
end MemoryOperations_Stage;

-- Architecture of memoryOperations
architecture behavioral of MemoryOperations_Stage is

  -- Component declaration for pipeline4 (Pipeline stage 4)
  component PipeLine_Stage_four is
    port (
      clk               : in std_logic; -- System clock signal
      resetPL           : in std_logic; -- Reset signal
      -- Control signals for Write-Back stage
      storedMemToReg    : in std_logic; -- Memory-to-Register control signal
      storedRegWrite    : in std_logic; -- Register write enable signal
      -- Data read from memory
      storedReadDataMem : in std_logic_vector(31 downto 0); -- Data read from memory
      -- ALU output signals
      storedAluResult   : in std_logic_vector(31 downto 0); -- ALU computation result
      -- Write-back register
      storedWriteReg    : in std_logic_vector(4 downto 0); -- Register for write-back
      -- Output signals
      getMemToReg       : out std_logic; -- Forwarded Memory-to-Register control signal
      getRegWrite       : out std_logic; -- Forwarded Register write enable signal
      getReadDataMem    : out std_logic_vector(31 downto 0); -- Forwarded data read from memory
      getAluResult      : out std_logic_vector(31 downto 0); -- Forwarded ALU computation result
      getWriteReg       : out std_logic_vector(4 downto 0) -- Forwarded write-back register
    );
  end component;

  -- Component declaration for dataMemory (Data memory module)
component Data_Memory_VHDL is
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
end component;


  -- Internal signal to store data read from memory
  signal sDataFromMem : std_logic_vector(31 downto 0);

begin

    -- Pass the jump control signal directly to the output
    jumpOut4        <= jumpIn4;
    -- Pass the jump target address directly to the output
    jumpAddrOut4    <= jumpAddrIn4;
    -- Compute the branch control signal based on branchIn4 and zeroFlagIn4
    branchOut4      <= branchIn4 and zeroFlagIn4;
    -- Pass the branch target address directly to the output
    branchAddrOut4  <= branchAddrIn4;

  -- Instantiate the dataMemory component
    dataMemoryOp : Data_Memory_VHDL
    generic map (
        DATA_WIDTH => 32, -- Default data width is 32 bits
        MEM_SIZE   => 256 -- Default memory size in 32-bit words
    )
    port map (
        clk            => clk,               -- Connect system clock signal
        mem_access_addr => aluResultIn4(15 downto 0), -- Data memory converts this byte address to a word index
        mem_write_data  => readData2In4,     -- Connect data to write into memory
        mem_write_en    => memWriteIn4,      -- Connect memory write enable signal
        mem_read        => memReadIn4,       -- Connect memory read enable signal
        mem_read_data   => sDataFromMem      -- Connect data read from memory to internal signal
    );

    -- Instantiate the pipeline4 component
    pipeline : PipeLine_Stage_four
      port map (
        clk               => clk,               -- Connect system clock signal
        resetPL           => resetPipeline4,    -- Connect reset signal
        storedMemToReg    => memToRegIn4,       -- Connect Memory-to-Register control signal
        storedRegWrite    => regWriteIn4,       -- Connect Register write enable signal
        storedReadDataMem => sDataFromMem,      -- Connect data read from memory
        storedAluResult   => aluResultIn4,      -- Connect ALU computation result
        storedWriteReg    => registerIn4,       -- Connect write-back register
        getMemToReg       => memToRegOut4,      -- Output forwarded Memory-to-Register control signal
        getRegWrite       => regWriteOut4,      -- Output forwarded Register write enable signal
        getReadDataMem    => readDataMemOut4,   -- Output forwarded data read from memory
        getAluResult      => aluResultOut4,     -- Output forwarded ALU computation result
        getWriteReg       => registerOut4       -- Output forwarded write-back register
      );

end behavioral;

