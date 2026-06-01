library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--===========================================
-- Entity Declaration
--===========================================
entity Decode_instruction is
  generic (
    DATA_WIDTH : natural := 32; -- Width for data signals
    ADDR_WIDTH : natural := 5;  -- Width for register addresses
    ALU_OP_SIZE : natural := 3; -- Width for ALU operation control signals
    INSTR_WIDTH : natural := 32; -- Width for instruction signals
    NUM_REGS   : integer := 32;  -- Number of registers
    PC_SIZE    : natural := 32    -- Width for Program Counter (PC)
  );
  port (
    -- Clock and Reset
    clk                 : in std_logic; -- System clock signal
    resetPipeline2      : in std_logic; -- Reset signal for pipeline stage two

    -- Registers Write-back Inputs
    regWriteFlagIn2     : in std_logic; -- Enable writing to registers
    regWriteIn2         : in std_logic_vector(ADDR_WIDTH-1 downto 0); -- Write register address
    dataWriteIn2        : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Data to write into the register

    -- Instruction and Program Counter
    instructionIn2      : in std_logic_vector(INSTR_WIDTH-1 downto 0); -- Current instruction
    programCounterIn2   : in std_logic_vector(PC_SIZE-1 downto 0); -- Program Counter (PC+4)

    -- Control Unit Outputs
    memToRegOut2        : out std_logic; -- Memory to register control signal
    regWriteOut2        : out std_logic; -- Enable writing to the register file
    jumpOut2            : out std_logic; -- Enable jump operation
    branchOut2          : out std_logic; -- Enable branch operation
    memReadOut2         : out std_logic; -- Enable memory read operation
    memWriteOut2        : out std_logic; -- Enable memory write operation
    regDstOut2          : out std_logic; -- Select register destination
    aluSrcOut2          : out std_logic; -- Select ALU source
    aluOpOut2           : out std_logic_vector(ALU_OP_SIZE-1 downto 0); -- ALU operation signal

    -- Data Outputs
    jumpAddrOut2        : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Jump address
    programCounterOut2  : out std_logic_vector(PC_SIZE-1 downto 0); -- Program Counter value
    readData1Out2       : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Data from Register 1
    readData2Out2       : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Data from Register 2
    extendedSignalOut2  : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Sign-extended immediate value
    registerRTOut2      : out std_logic_vector(ADDR_WIDTH-1 downto 0); -- Register RT
    registerRDOut2      : out std_logic_vector(ADDR_WIDTH-1 downto 0) -- Register RD
  );
end Decode_instruction;

--===========================================
-- Architecture Definition
--===========================================
architecture Behavioral of Decode_instruction is

  --===========================================
  -- Subcomponent Declarations with Generics
  --===========================================
  component control_unit_new is
    generic (
      OPCODE_SIZE : natural := 6;
      FUNCT_SIZE  : natural := 6;
      ALU_OP_SIZE : natural := ALU_OP_SIZE
    );
    port (
      opcode         : in std_logic_vector(OPCODE_SIZE-1 downto 0);
      funct          : in std_logic_vector(FUNCT_SIZE-1 downto 0);
      reset          : in std_logic;
      reg_dst        : out std_logic;
      mem_to_reg     : out std_logic;
      alu_op         : out std_logic_vector(ALU_OP_SIZE-1 downto 0);
      jump           : out std_logic;
      branch         : out std_logic;
      mem_read       : out std_logic;
      mem_write      : out std_logic;
      alu_src        : out std_logic;
      reg_write      : out std_logic
    );
  end component;

  component register_file_VHDL is
    generic (
      DATA_WIDTH : natural := DATA_WIDTH;
      NUM_REGS   : natural := 32
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
  end component;

  component Sign_Extend is
    generic (
      INPUT_SIZE  : natural := 16;
      OUTPUT_SIZE : natural := DATA_WIDTH
    );
    port (
      a  : in std_logic_vector(INPUT_SIZE-1 downto 0);
      y : out std_logic_vector(OUTPUT_SIZE-1 downto 0)
    );
  end component;

  component shifterLeft is
    generic (
      inputDim  : natural := 32;
      outputDim : natural := 32;
      bitToShift: natural := 2
    );
    port (
      inputV   : in std_logic_vector(inputDim-1 downto 0);
      outputV  : out std_logic_vector(outputDim-1 downto 0)
    );
  end component;

  component PipeLine_Stage_Two is
    generic (
      DATA_WIDTH : natural := DATA_WIDTH; -- Width of data signals
      ADDR_WIDTH : natural := ADDR_WIDTH; -- Width of register addresses
      ALU_OP_SIZE: natural := ALU_OP_SIZE; -- Width of ALU control signal
      PC_WIDTH   : natural := PC_SIZE -- Width of the Program Counter
    );
    port (
      -- Clock and Reset
      clk             : in std_logic; -- Clock signal for synchronization
      resetPL         : in std_logic; -- Reset signal for pipeline stage

      -- Control Signals (Stored from Control Unit)
      storedMemToReg  : in std_logic; -- Memory to register control signal
      storedRegWrite  : in std_logic; -- Register write enable
      storedJump      : in std_logic; -- Jump control signal
      storedBranch    : in std_logic; -- Branch control signal
      storedMemRead   : in std_logic; -- Memory read enable
      storedMemWrite  : in std_logic; -- Memory write enable
      storedRegDst    : in std_logic; -- Register destination selection
      storedAluSrc    : in std_logic; -- ALU source control
      storedAluOp     : in std_logic_vector(ALU_OP_SIZE-1 downto 0); -- ALU operation control signal

      -- Data Signals
      storedJumpAddr  : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Jump address
      storedPC        : in std_logic_vector(PC_WIDTH-1 downto 0); -- Program Counter (PC + 4)
      storedReadData1 : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Data from Register 1
      storedReadData2 : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Data from Register 2
      storedSignExt   : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Sign-extended immediate value

      -- Write Register Signals
      storedWriteRegRT : in std_logic_vector(ADDR_WIDTH-1 downto 0); -- Write Register RT
      storedWriteRegRD : in std_logic_vector(ADDR_WIDTH-1 downto 0); -- Write Register RD

      -- Outputs
      getMemToReg   : out std_logic; -- Pass memory-to-register control signal
      getRegWrite   : out std_logic; -- Pass register write enable
      getJump       : out std_logic; -- Pass jump control signal
      getBranch     : out std_logic; -- Pass branch control signal
      getMemRead    : out std_logic; -- Pass memory read enable
      getMemWrite   : out std_logic; -- Pass memory write enable
      getRegDst     : out std_logic; -- Pass destination register control
      getAluSrc     : out std_logic; -- Pass ALU source control
      getAluOp      : out std_logic_vector(ALU_OP_SIZE-1 downto 0); -- Pass ALU operation control
      getJumpAddr   : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Pass jump address
      getPC         : out std_logic_vector(PC_WIDTH-1 downto 0); -- Pass Program Counter
      getReadData1  : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Pass Register 1 data
      getReadData2  : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Pass Register 2 data
      getSignExt    : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Pass sign-extended immediate
      getWriteRegRT : out std_logic_vector(ADDR_WIDTH-1 downto 0); -- Pass write register RT
      getWriteRegRD : out std_logic_vector(ADDR_WIDTH-1 downto 0)  -- Pass write register RD
    );
  end component;

  --===========================================
  -- Internal Signals
  --===========================================
  signal sExtendResult : std_logic_vector(DATA_WIDTH-1 downto 0); -- Extended immediate value
  signal sReadData1    : std_logic_vector(DATA_WIDTH-1 downto 0); -- Data from register 1
  signal sReadData2    : std_logic_vector(DATA_WIDTH-1 downto 0); -- Data from register 2
  signal sShiftedInstr : std_logic_vector(27 downto 0); -- Shifted instruction bits
  signal sJumpAddr     : std_logic_vector(DATA_WIDTH-1 downto 0); -- Jump address

  -- Control Signals
  signal sRegDst, sJump, sBranch, sMemRead, sMemWrite, sMemToReg, sAluSrc, sRegWrite : std_logic;
  signal sAluOp : std_logic_vector(ALU_OP_SIZE-1 downto 0);

begin

  --===========================================
  -- Sign Extension
  --===========================================
  extendSignal : Sign_Extend
    port map (
      a => instructionIn2(15 downto 0),
      y => sExtendResult
    );

  --===========================================
  -- Register File Mapping
  --===========================================
  readRegister : register_file_VHDL
    generic map (DATA_WIDTH, NUM_REGS)
    port map (
      clk => clk,
      rst => resetPipeline2,
      reg_write_en => regWriteFlagIn2,
      reg_write_dest => regWriteIn2,
      reg_write_data => dataWriteIn2,
      reg_read_addr_1 => instructionIn2(25 downto 21),
      reg_read_addr_2 => instructionIn2(20 downto 16),
      reg_read_data_1 => sReadData1,
      reg_read_data_2 => sReadData2
    );

  --===========================================
  -- Control Unit
  --===========================================
  setControlFlag : control_unit_new
    generic map (
      OPCODE_SIZE => 6,
      FUNCT_SIZE => 6,
      ALU_OP_SIZE => ALU_OP_SIZE
    )
    port map (
      opcode    => instructionIn2(31 downto 26), -- 6-bit opcode field
      funct     => instructionIn2(5 downto 0),   -- 6-bit funct field
      reset     => resetPipeline2,              -- Reset signal mapped correctly
      reg_dst   => sRegDst,                      -- Destination register control
      jump      => sJump,                        -- Jump control signal
      branch    => sBranch,                      -- Branch control signal
      mem_read  => sMemRead,                     -- Memory read enable
      mem_write => sMemWrite,                    -- Memory write enable
      mem_to_reg=> sMemToReg,                    -- Memory to register control
      alu_src   => sAluSrc,                      -- ALU source control
      reg_write => sRegWrite,                    -- Register write enable
      alu_op    => sAluOp                        -- ALU operation control signal
    );

  --===========================================
  -- Jump Address Calculation
  --===========================================
  shiftInstruction : shifterLeft
    generic map (26, 28, 2)
    port map (
      inputV => instructionIn2(25 downto 0),
      outputV => sShiftedInstr
    );

  -- Jump address calculation: upper PC bits plus the shifted instruction target.
  sJumpAddr <= programCounterIn2(31 downto 28) & sShiftedInstr;

  --===========================================
  -- PipeLine_Stage_Two
  --===========================================
  pipeline : PipeLine_Stage_Two
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      ADDR_WIDTH => ADDR_WIDTH,
      ALU_OP_SIZE => ALU_OP_SIZE,
      PC_WIDTH => PC_SIZE
    )
    port map (
      -- Clock and Reset
      clk             => clk,
      resetPL         => resetPipeline2,

      -- Control Signals (Stored from Control Unit)
      storedMemToReg  => sMemToReg, -- Control signal for memory-to-register selection
      storedRegWrite  => sRegWrite, -- Enable register write
      storedJump      => sJump, -- Enable jump instruction
      storedBranch    => sBranch, -- Enable branch instruction
      storedMemRead   => sMemRead, -- Enable memory read
      storedMemWrite  => sMemWrite, -- Enable memory write
      storedRegDst    => sRegDst, -- Destination register selection
      storedAluSrc    => sAluSrc, -- ALU source selection
      storedAluOp     => sAluOp, -- ALU operation control signal

      -- Data Signals
      storedJumpAddr  => sJumpAddr, -- Jump address calculated
      storedPC        => programCounterIn2, -- Program Counter (PC + 4)
      storedReadData1 => sReadData1, -- Data from register 1
      storedReadData2 => sReadData2, -- Data from register 2
      storedSignExt   => sExtendResult, -- Sign-extended immediate value

      -- Write Register Signals
      storedWriteRegRT => instructionIn2(20 downto 16), -- Target Register RT
      storedWriteRegRD => instructionIn2(15 downto 11), -- Destination Register RD

      -- Outputs to Next Stage
      getMemToReg   => memToRegOut2, -- Pass memory-to-register control signal
      getRegWrite   => regWriteOut2, -- Pass register write enable
      getJump       => jumpOut2, -- Pass jump control signal
      getBranch     => branchOut2, -- Pass branch control signal
      getMemRead    => memReadOut2, -- Pass memory read enable
      getMemWrite   => memWriteOut2, -- Pass memory write enable
      getRegDst     => regDstOut2, -- Pass destination register control
      getAluSrc     => aluSrcOut2, -- Pass ALU source control
      getAluOp      => aluOpOut2, -- Pass ALU operation control signal
      getJumpAddr   => jumpAddrOut2, -- Pass jump address
      getPC         => programCounterOut2, -- Pass Program Counter (PC + 4)
      getReadData1  => readData1Out2, -- Pass data from register 1
      getReadData2  => readData2Out2, -- Pass data from register 2
      getSignExt    => extendedSignalOut2, -- Pass sign-extended immediate value
      getWriteRegRT => registerRTOut2, -- Pass write register RT
      getWriteRegRD => registerRDOut2  -- Pass write register RD
    );

end Behavioral;
