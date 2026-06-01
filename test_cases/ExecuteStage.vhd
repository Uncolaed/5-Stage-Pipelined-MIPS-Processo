library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity EX_Stage is
    Port (
        clk               : in  std_logic;
        reset             : in  std_logic;
        ID_EX_ReadData1   : in  std_logic_vector(31 downto 0); -- Read data 1 from ID/EX pipeline
        ID_EX_ReadData2   : in  std_logic_vector(31 downto 0); -- Read data 2 from ID/EX pipeline
        ID_EX_SignExtend  : in  std_logic_vector(31 downto 0); -- Sign-extended immediate from ID/EX
        ID_EX_PC          : in  std_logic_vector(31 downto 0); -- PC from ID/EX pipeline
        ID_EX_ControlSignals : in std_logic_vector(9 downto 0); -- Control signals from ID/EX
        EX_MEM_ALUResult  : out std_logic_vector(31 downto 0); -- ALU result to MEM stage
        EX_MEM_ZeroFlag   : out std_logic; -- Zero flag to MEM stage
        EX_MEM_BranchAddr : out std_logic_vector(31 downto 0); -- Branch target address
        EX_MEM_ReadData2  : out std_logic_vector(31 downto 0); -- Forwarded Read Data 2 to MEM stage
        EX_MEM_ControlSignals : out std_logic_vector(9 downto 0) -- Forwarded control signals
    );
end EX_Stage;

architecture Behavioral of EX_Stage is

    -- Control Signal Breakout
    signal alu_src : std_logic;
    signal alu_op  : std_logic_vector(1 downto 0);
    signal branch  : std_logic;

    -- ALU Signals
    signal alu_control : std_logic_vector(2 downto 0);
    signal alu_operand2 : std_logic_vector(31 downto 0);
    signal zero_flag : std_logic;
    signal alu_result : std_logic_vector(31 downto 0);

begin

    --===========================================
    -- Control Signal Decoding
    --===========================================
    alu_src <= ID_EX_ControlSignals(3);
    alu_op  <= ID_EX_ControlSignals(5 downto 4);
    branch  <= ID_EX_ControlSignals(6);

    --===========================================
    -- ALU Control Unit
    --===========================================
    ALU_Control_Unit : entity work.ALU_Control_VHDL
        port map (
            ALU_Control => alu_control,
            ALUOp       => alu_op,
            ALU_Funct   => ID_EX_SignExtend(5 downto 0) -- Assume funct field from immediate
        );

    --===========================================
    -- ALU Operand MUX
    --===========================================
    alu_operand2 <= ID_EX_SignExtend when alu_src = '1' else ID_EX_ReadData2;

    --===========================================
    -- ALU Instance
    --===========================================
    ALU : entity work.ALU_VHDL
        generic map (
            DATA_WIDTH => 32
        )
        port map (
            a           => ID_EX_ReadData1,
            b           => alu_operand2,
            alu_control => alu_control,
            alu_result  => alu_result,
            zero        => zero_flag
        );

    --===========================================
    -- Branch Address Calculation
    --===========================================
    EX_MEM_BranchAddr <= std_logic_vector(signed(ID_EX_PC) + (signed(ID_EX_SignExtend) sll 2));

    --===========================================
    -- Forward Results to EX/MEM Pipeline
    --===========================================
    EX_MEM_ALUResult <= alu_result;
    EX_MEM_ZeroFlag  <= zero_flag;
    EX_MEM_ReadData2 <= ID_EX_ReadData2;
    EX_MEM_ControlSignals <= ID_EX_ControlSignals;

end Behavioral;
