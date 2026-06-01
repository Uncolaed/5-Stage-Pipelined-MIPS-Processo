--------------------------------------------------------------------------------
-- Entity: PipeLine_Stage_Two
-- Description:
-- Pipeline Stage Two for MIPS Processor.
-- Stores control signals, register data, and instruction signals.
-- Aligned with updated ALU (3-bit alu_op) and control_unit_new.
-- Includes generic parameters for signal sizes.
--------------------------------------------------------------------------------

-- Standard Libraries
library IEEE;
use IEEE.std_logic_1164.all; -- Standard logic library
use IEEE.numeric_std.all;    -- Numeric operations

--===========================================
-- Entity Declaration
--===========================================
entity PipeLine_Stage_Two is
  generic (
    DATA_WIDTH : natural := 32; -- Data signal width
    ADDR_WIDTH : natural := 5;  -- Register address width
    ALU_OP_SIZE : natural := 3; -- ALU operation control size
    PC_WIDTH : natural := 32     -- Program Counter width
  );
  port (
    -- Clock and Reset
    clk             : in std_logic; -- System clock signal
    resetPL         : in std_logic; -- Reset signal for pipeline stage

    -- Control Signals (Stored from Control Unit)
    -- Write-Back (WB) Stage Signals
    storedMemToReg  : in std_logic; -- Select memory or ALU result for register write
    storedRegWrite  : in std_logic; -- Enable writing to the register file

    -- Memory Access (M) Stage Signals
    storedJump      : in std_logic; -- Enable jump operation
    storedBranch    : in std_logic; -- Enable branch operation
    storedMemRead   : in std_logic; -- Enable memory read operation
    storedMemWrite  : in std_logic; -- Enable memory write operation

    -- Execution (EX) Stage Signals
    storedRegDst    : in std_logic; -- Select the destination register
    storedAluSrc    : in std_logic; -- Select ALU source (register or immediate)
    storedAluOp     : in std_logic_vector(ALU_OP_SIZE-1 downto 0); -- ALU operation control (3 bits)

    -- Pipeline Data Signals
    storedJumpAddr  : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Jump address calculated during execution
    storedPC        : in std_logic_vector(PC_WIDTH-1 downto 0); -- Current Program Counter value (PC + 4)
    storedReadData1 : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Data read from first register
    storedReadData2 : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Data read from second register
    storedSignExt   : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Sign-extended immediate value

    -- Write Register Selection
    storedWriteRegRT : in std_logic_vector(ADDR_WIDTH-1 downto 0); -- Target register (RT) for writing data
    storedWriteRegRD : in std_logic_vector(ADDR_WIDTH-1 downto 0); -- Destination register (RD) for writing data

    -- Outputs to Next Pipeline Stage
    getMemToReg   : out std_logic; -- Pass memory/ALU write-back control signal
    getRegWrite   : out std_logic; -- Pass register write enable signal
    getJump       : out std_logic; -- Pass jump control signal
    getBranch     : out std_logic; -- Pass branch control signal
    getMemRead    : out std_logic; -- Pass memory read enable signal
    getMemWrite   : out std_logic; -- Pass memory write enable signal
    getRegDst     : out std_logic; -- Pass register destination control signal
    getAluSrc     : out std_logic; -- Pass ALU source control signal
    getAluOp      : out std_logic_vector(ALU_OP_SIZE-1 downto 0); -- Pass ALU operation control signal
    getJumpAddr   : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Pass jump address
    getPC         : out std_logic_vector(PC_WIDTH-1 downto 0); -- Pass PC value
    getReadData1  : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Pass register 1 data
    getReadData2  : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Pass register 2 data
    getSignExt    : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Pass sign-extended immediate value
    getWriteRegRT : out std_logic_vector(ADDR_WIDTH-1 downto 0); -- Pass target register (RT)
    getWriteRegRD : out std_logic_vector(ADDR_WIDTH-1 downto 0)  -- Pass destination register (RD)
  );
end PipeLine_Stage_Two;

--===========================================
-- Architecture Definition
--===========================================
architecture Behavioral of PipeLine_Stage_Two is

  -- Internal Signals
  signal sMemToReg  : std_logic;
  signal sRegWrite  : std_logic;
  signal sJump      : std_logic;
  signal sBranch    : std_logic;
  signal sMemRead   : std_logic;
  signal sMemWrite  : std_logic;
  signal sRegDst    : std_logic;
  signal sAluSrc    : std_logic;
  signal sAluOp     : std_logic_vector(ALU_OP_SIZE-1 downto 0);

  signal sJumpAddr  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sPC        : std_logic_vector(PC_WIDTH-1 downto 0); -- Updated PC Width
  signal sReadData1 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sReadData2 : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sSignExt   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sWriteRegRT : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal sWriteRegRD : std_logic_vector(ADDR_WIDTH-1 downto 0);

begin

  -- Pipeline Register Process
  process(clk, resetPL)
  begin
    if resetPL = '1' then
        -- Reset all signals
        sMemToReg  <= '0';
        sRegWrite  <= '0';
        sJump      <= '0';
        sBranch    <= '0';
        sMemRead   <= '0';
        sMemWrite  <= '0';
        sRegDst    <= '0';
        sAluSrc    <= '0';
        sAluOp     <= (others => '0');
        sJumpAddr  <= (others => '0');
        sPC        <= (others => '0');
        sReadData1 <= (others => '0');
        sReadData2 <= (others => '0');
        sSignExt   <= (others => '0');
        sWriteRegRT <= (others => '0');
        sWriteRegRD <= (others => '0');
    elsif rising_edge(clk) then
        -- Store all signals
        sMemToReg  <= storedMemToReg;
        sRegWrite  <= storedRegWrite;
        sJump      <= storedJump;
        sBranch    <= storedBranch;
        sMemRead   <= storedMemRead;
        sMemWrite  <= storedMemWrite;
        sRegDst    <= storedRegDst;
        sAluSrc    <= storedAluSrc;
        sAluOp     <= storedAluOp;
        sJumpAddr  <= storedJumpAddr;
        sPC        <= storedPC;
        sReadData1 <= storedReadData1;
        sReadData2 <= storedReadData2;
        sSignExt   <= storedSignExt;
        sWriteRegRT <= storedWriteRegRT;
        sWriteRegRD <= storedWriteRegRD;
    end if;
  end process;

  -- Outputs Assignment
  getMemToReg   <= sMemToReg;
  getRegWrite   <= sRegWrite;
  getJump       <= sJump;
  getBranch     <= sBranch;
  getMemRead    <= sMemRead;
  getMemWrite   <= sMemWrite;
  getRegDst     <= sRegDst;
  getAluSrc     <= sAluSrc;
  getAluOp      <= sAluOp;
  getJumpAddr   <= sJumpAddr;
  getPC         <= sPC;
  getReadData1  <= sReadData1;
  getReadData2  <= sReadData2;
  getSignExt    <= sSignExt;
  getWriteRegRT <= sWriteRegRT;
  getWriteRegRD <= sWriteRegRD;

end Behavioral;
