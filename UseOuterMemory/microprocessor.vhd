----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:32:05 11/11/2016 
-- Design Name: 
-- Module Name:    microprocessor - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity microprocessor is
port(
	clock:	in 	std_logic;
	rst:		in 	std_logic;
	--clk0: in STD_LOGIC;
	--seg1: out std_logic_vector(7 downto 0);
	--seg2: out std_logic_vector(7 downto 0)
	--for test purpose only;
	state_code: out std_logic_vector(3 downto 0);
	ram1_data: inout std_logic_vector(15 downto 0);
	ram1_addr: out std_logic_vector(15 downto 0);
   data_ready: in std_logic;
	ram1_oe,ram1_we,ram1_en,wrn,rdn: out std_logic;
	click: in std_logic;
	tbre,tsre: in std_logic;
	alu_zero_out: out std_logic;
	PCSource_out,PCWrite_out,PCWriteCond_out: out std_logic;
	s1_out,s2_out,s3_out,s4_out,s6_out,s7_out,s8_out,s9_out,s10_out,s11_out,s12_out,s13_out,s14_out,s15_out: out std_logic_vector(15 downto 0)
);

end microprocessor;

architecture Behavioral of microprocessor is
component data_path is
port(	clock:	in 	std_logic;
	rst:		in 	std_logic;
	RegDst: in std_logic_vector(1 downto 0);
	RegWrite: IN  std_logic_vector(2 downto 0);
   RegRead : IN  std_logic_vector(1 downto 0);
   MemtoReg: in std_logic_vector(1 downto 0);
	ALUSrcA: in std_logic_vector(1 downto 0);
	ALUSrcB: in std_logic_vector(1 downto 0);
	ALUOp: in std_logic_vector(3 downto 0);
	MemRead: in std_logic;
	MemWrite: in std_logic;
	IorD: in std_logic;
	IRWrite: in std_logic;
	PCWrite: in std_logic;
	PCSource: in std_logic;
	PCWriteCond: in std_logic;
	ALU_zero: out std_logic;
	SE: in std_logic_vector(2 downto 0);
	instructions: out std_logic_vector(15 downto 0);
	ram1_data: inout std_logic_vector(15 downto 0);
	ram1_addr: out std_logic_vector(15 downto 0);
   data_ready: in std_logic;
	ram1_oe,ram1_we,ram1_en,wrn,rdn: out std_logic;
	click: in std_logic;
	tbre,tsre: in std_logic;
	SerialDisable: in std_logic;
	s1_out,s2_out,s3_out,s4_out,s6_out,s7_out,s8_out,s9_out,s10_out,s11_out,s12_out,s13_out,s14_out,s15_out: out std_logic_vector(15 downto 0)
	--s16_out: out std_logic_vector(2 downto 0);
);
end component;

component Controler_seven is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           instructions : in  STD_LOGIC_VECTOR (15 downto 0);
			  PCWrite,PCWriteCond,PCSource: out std_logic ;
			  ALUOp : out std_logic_vector(3 downto 0) ;
			  ALUSrcA : out std_logic_vector(1 downto 0) ;
			  ALUSrcB : out std_logic_vector(1 downto 0) ;
			  MemRead : out std_logic ;
			  MemWrite : out std_logic ;
			  IRWrite : out std_logic ;
			  MemtoReg :out  std_logic_vector(1 downto 0) ;
			  RegWrite : out std_logic_vector(2 downto 0) ;
			  RegDst : out std_logic_vector(1 downto 0) ;
			  IorD : out std_logic;
			  SE: out std_logic_vector(2 downto 0);
			  SerialDisable: out std_logic;
			  bZero_ctrl: in std_logic;
			  state_code: out std_logic_vector(3 downto 0)
);
end component;


signal RegDst,RegRead,ALUSrcB: std_logic_vector(1 downto 0);
signal MemRead,MemWrite,IorD,IRWrite,SerialDisable,
	PCWrite,PCSource,PCWriteCond,ALU_zero:std_logic;
signal MemtoReg,ALUSrcA:std_logic_vector(1 downto 0);
signal RegWrite,SE: std_logic_vector(2 downto 0);
signal ALUOp: std_logic_vector(3 downto 0);
signal instructions: std_logic_vector(15 downto 0);
begin
alu_zero_out<=ALU_zero;
PCSource_out<=PCSource;
PCWrite_out<=PCWrite;
PCWriteCond_out<=PCWriteCond;
U_DATA_PATH: data_path port map(clock,rst,RegDst,RegWrite,RegRead,MemtoReg,ALUSrcA,
	ALUSrcB,ALUOp,MemRead,MemWrite,IorD,IRWrite,PCWrite,PCSource,PCWriteCond,ALU_zero,
	SE,instructions,ram1_data,ram1_addr,data_ready,
	ram1_oe,ram1_we,ram1_en,wrn,rdn,click,tbre,tsre,SerialDisable,s1_out,s2_out,s3_out,s4_out,s6_out,s7_out,s8_out,s9_out,s10_out,s11_out,s12_out,s13_out,s14_out,s15_out);	

U_Controler_Seven: Controler_seven port map(rst,click,instructions,
	PCWrite,PCWriteCond,PCSource,ALUOp,ALUSrcA,ALUSrcB,MemRead,MemWrite,
	IRWrite,MemtoReg,RegWrite,RegDst,IorD,SE,SerialDisable,ALU_zero,state_code);




end Behavioral;

