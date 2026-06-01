-- Execute Stage of the CPU Pipeline
-- Components: ALU, pipeline3, adder, shifter, and mux

library IEEE;
use IEEE.std_logic_1164.all; -- Standard library for std_logic data type
use IEEE.numeric_std.all; -- Provides arithmetic operations for numeric types

entity Execute_Stage is
  port(
    clk               : in std_logic; -- System clock signal
    resetPipeline3    : in std_logic; -- Reset signal for pipeline stage
    -- Control signals
    memToRegIn3       : in std_logic; -- Memory-to-Register control signal
    regWriteIn3       : in std_logic; -- Register write enable signal
    jumpIn3           : in std_logic; -- Jump control signal
    branchIn3         : in std_logic; -- Branch control signal
    memReadIn3        : in std_logic; -- Memory read enable signal
    memWriteIn3       : in std_logic; -- Memory write enable signal
    regDstIn3         : in std_logic; -- Register destination select signal
    aluSrcIn3         : in std_logic; -- ALU source selection control signal
    aluOpIn3          : in std_logic_vector(2 downto 0); -- ALU operation control
    -- Input data
    jumpAddrIn3       : in std_logic_vector(31 downto 0); -- Jump target address
    programCounterIn3 : in std_logic_vector(31 downto 0); -- Current program counter
    readData1In3      : in std_logic_vector(31 downto 0); -- First operand for ALU
    readData2In3      : in std_logic_vector(31 downto 0); -- Second operand for ALU
    extendedSignalIn3 : in std_logic_vector(31 downto 0); -- Sign-extended immediate
    registerRTIn3     : in std_logic_vector(4 downto 0); -- RT register index
    registerRDIn3     : in std_logic_vector(4 downto 0); -- RD register index
    -- Output data
    memToRegOut3      : out std_logic; -- Forwarded MemToReg signal
    regWriteOut3      : out std_logic; -- Forwarded RegWrite signal
    jumpOut3          : out std_logic; -- Forwarded Jump signal
    branchOut3        : out std_logic; -- Forwarded Branch signal
    memReadOut3       : out std_logic; -- Forwarded MemRead signal
    memWriteOut3      : out std_logic; -- Forwarded MemWrite signal
    jumpAddrOut3      : out std_logic_vector(31 downto 0); -- Forwarded jump address
    branchAddrOut3    : out std_logic_vector(31 downto 0); -- Computed branch address
    zeroFlagOut3      : out std_logic; -- Zero flag from ALU
    aluResultOut3     : out std_logic_vector(31 downto 0); -- ALU computation result
    readData2Out3     : out std_logic_vector(31 downto 0); -- Forwarded data from register
    registerOut3      : out std_logic_vector(4 downto 0) -- Forwarded write register
  );
end Execute_Stage;

architecture behavioral of Execute_Stage is

  -- Component declarations for modular design
  component ALU_VHDL is
  generic (
  DATA_WIDTH : integer := 32 -- Default data width
  );
     port(
        a           : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- Operand 1 (src1)
        b           : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- Operand 2 (src2)
        alu_control : in  std_logic_vector(2 downto 0); -- ALU operation selector
        alu_result  : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Result of ALU operation
        zero        : out std_logic -- Zero flag
    );
  end component;

  component PipeLine_Stage_Three is
    port (
      clk             : in std_logic; -- Clock signal
      resetPL         : in std_logic; -- Reset signal
      -- Control signals
      storedMemToReg  : in std_logic;
      storedRegWrite  : in std_logic;
      storedJump      : in std_logic;
      storedBranch    : in std_logic;
      storedMemRead   : in std_logic;
      storedMemWrite  : in std_logic;
      -- Address and ALU signals
      storedJumpAddr  : in std_logic_vector(31 downto 0);
      storedBranchAddr: in std_logic_vector(31 downto 0);
      storedZero      : in std_logic;
      storedAluResult : in std_logic_vector(31 downto 0);
      storedReadData2 : in std_logic_vector(31 downto 0);
      storedWriteReg  : in std_logic_vector(4 downto 0);
      -- Outputs
      getMemToReg     : out std_logic;
      getRegWrite     : out std_logic;
      getJump         : out std_logic;
      getBranch       : out std_logic;
      getMemRead      : out std_logic;
      getMemWrite     : out std_logic;
      getJumpAddr     : out std_logic_vector(31 downto 0);
      getBranchAddr   : out std_logic_vector(31 downto 0);
      getZero         : out std_logic;
      getAluResult    : out std_logic_vector(31 downto 0);
      getReadData2    : out std_logic_vector(31 downto 0);
      getWriteReg     : out std_logic_vector(4 downto 0)
    );
  end component;

  component adder is
    generic(
      dimension : natural := 32 -- Dimension for the adder
    );
    port(
      a  : in std_logic_vector(dimension - 1 downto 0); -- First operand
      b  : in std_logic_vector(dimension - 1 downto 0); -- Second operand
      sum      : out std_logic_vector(dimension - 1 downto 0) -- Sum output
    );
  end component;

  component shifterLeft is
    generic(
      inputDim     : natural := 32; -- Input dimension
      outputDim    : natural := 32; -- Output dimension
      bitToShift   : natural := 2  -- Number of bits to shift
    );
    port(
      inputV   : in std_logic_vector(inputDim - 1 downto 0); -- Input vector
      outputV  : out std_logic_vector(outputDim - 1 downto 0) -- Shifted output
    );
  end component;

  component mux is
    generic(
      dimension : natural := 32 -- Dimension of signals
    );
    port(
      controlSignal  : in std_logic; -- Control signal to select between inputs
      signal1        : in std_logic_vector(dimension - 1 downto 0); -- Input 1
      signal2        : in std_logic_vector(dimension - 1 downto 0); -- Input 2
      selectedSignal : out std_logic_vector(dimension - 1 downto 0) -- Output
    );
  end component;

  -- Internal signals for computations and interconnections
  signal sZero : std_logic; -- Zero flag from ALU
  signal sSelectedWriteReg : std_logic_vector(4 downto 0); -- Selected write register
  signal sAluData2, sAluResult : std_logic_vector(31 downto 0); -- ALU operands and result
  signal sExtendedShiftedSignal, sBranchAddrRes : std_logic_vector(31 downto 0); -- Shifted signal and branch address

begin

  -- Select the destination register based on regDstIn3 signal
  selectRegister : mux
    generic map (5)
    port map (controlSignal => regDstIn3, signal1 => registerRTIn3, signal2 => registerRDIn3, selectedSignal => sSelectedWriteReg);

  -- Select the second operand for ALU based on aluSrcIn3 signal
  selectSecondData : mux
    generic map (32)
    port map (controlSignal => aluSrcIn3, signal1 => readData2In3, signal2 => extendedSignalIn3, selectedSignal => sAluData2);

  -- Shift the immediate value left by 2 for branch address computation
  shiftSignal : shifterLeft
    generic map (32, 32, 2)
    port map (inputV => extendedSignalIn3, outputV => sExtendedShiftedSignal);

  -- Perform ALU operations
  aluElaboration : ALU_VHDL
    generic map (
      DATA_WIDTH => 32
    )
    port map (a => readData1In3, b => sAluData2, alu_control => aluOpIn3, alu_result => sAluResult, zero => sZero);

  -- Add the shifted immediate value to the program counter for branch address
  branchAdd : adder
    generic map (32)
    port map (a => programCounterIn3, b => sExtendedShiftedSignal, sum => sBranchAddrRes);

  -- Pass data to the next pipeline stage
  pipeline : PipeLine_Stage_Three
    port map (clk => clk, resetPL => resetPipeline3, storedMemToReg => memToRegIn3, storedRegWrite => regWriteIn3, storedJump => jumpIn3,
      storedBranch => branchIn3, storedMemRead => memReadIn3, storedMemWrite => memWriteIn3, storedJumpAddr => jumpAddrIn3, storedBranchAddr => sBranchAddrRes, storedZero => sZero, storedAluResult => sAluResult, storedReadData2 => readData2In3, storedWriteReg => sSelectedWriteReg, getMemToReg => memToRegOut3,
      getRegWrite => regWriteOut3, getJump => jumpOut3, getBranch => branchOut3, getMemRead => memReadOut3, getMemWrite => memWriteOut3,
      getJumpAddr => jumpAddrOut3, getBranchAddr => branchAddrOut3, getZero => zeroFlagOut3, getAluResult => aluResultOut3, getReadData2 => readData2Out3,
      getWriteReg => registerOut3);

end behavioral;
