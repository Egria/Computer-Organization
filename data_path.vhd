----------------------------------------------------------------
-- Simple Microprocessor Design (ESD Book Chapter 3)
-- Copyright 2001 Weijun Zhang
--
-- data_path composed of Multiplexor, Register File and ALU
-- VHDL structural modeling
-- data_path.vhd
----------------------------------------------------------------

library	ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;
entity data_path is				
port(	clock:	in 	std_logic;
	rst:		in 	std_logic;
	RegDst: in std_logic_vector(1 downto 0);
	RegWrite: IN  std_logic_vector(2 downto 0);
   RegRead : IN  std_logic_vector(1 downto 0);
   MemtoReg: in std_logic_vector(1 downto 0);
	ALUSrcA: in std_logic;
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
	SE: in std_logic;
	data_bus: out std_logic_vector(15 downto 0);
	--for test purpose only
	s4_out,s15_out,s7_out,s1_out,s2_out,s3_out,s8_out,s10_out,s11_out,s12_out,s13_out: out std_logic_vector(15 downto 0);
	s16_out: out std_logic_vector(2 downto 0);
	--for test purpose only
	
	instructions: out std_logic_vector(15 downto 0)
);
end data_path;

architecture struct of data_path is

component register_file is
port ( 	clock	: 	in std_logic; 	
	rst	: 	in std_logic;
	RegWrite	: 	in std_logic_vector(2 downto 0);
	RegRead	: 	in std_logic_vector(1 downto 0);
	write_addr	: 	in std_logic_vector(2 downto 0);  
	read_1_addr	: 	in std_logic_vector(2 downto 0);
	read_2_addr	: 	in std_logic_vector(2 downto 0);
	write_data	: 	in std_logic_vector(15 downto 0);
	data_to_A	: 	out std_logic_vector(15 downto 0);
	data_to_B	:	out std_logic_vector(15 downto 0)
);
end component;

component alu is
port(	  
	reset:		in std_logic;
	input_1:	in std_logic_vector(15 downto 0);--MSB of A,B are sign bits.
	input_2: in std_logic_vector(15 downto 0);
	Sel: in std_logic_vector(3 downto 0);
	Res:	out std_logic_vector(15 downto 0);
   Zero: out std_logic
);
end component;

component memory is
port(	 
       clock: in std_logic;
		 reset:		in std_logic;
 		 address: in std_logic_vector(15 downto 0);
		 data_in: in std_logic_vector (15 downto 0);
		 data_out:out std_logic_vector (15 downto 0);
		 MemRead: in std_logic;
		 MemWrite: in std_logic
);
end component;

component multiplexor is
port(	  input_1:	in std_logic_vector(15 downto 0);--MSB of A,B are sign bits.
		  input_2:	in std_logic_vector(15 downto 0);
		  control_signal: in std_logic;
		  output: out std_logic_vector(15 downto 0)--make sure the input is finished;
);
end component;

component single_register is
port(	 clk,rst:	in std_logic;
		single_register_enable: in std_logic;
		single_register_in:	in std_logic_vector(15 downto 0);
		single_register_out:	out std_logic_vector(15 downto 0)
);
end component;
component multiplexor_two_bit is
generic(n:natural:=16);
port(	  input_1:	in std_logic_vector(n-1 downto 0);
		  input_2:	in std_logic_vector(n-1 downto 0);
		  input_3:  in std_logic_vector(n-1 downto 0);
		  control_signal: in std_logic_vector(1 downto 0);
		  output: out std_logic_vector(n-1 downto 0)
);
end component;

component dflip_flop is
port(
      clk : in std_logic;
      rst : in std_logic;
      data_in : in std_logic_vector(15 downto 0);
      data_out : out std_logic_vector(15 downto 0)
);
end component;

component dflip_flop_falling is
port(
      clk : in std_logic;
      rst : in std_logic;
      data_in : in std_logic_vector(15 downto 0);
      data_out : out std_logic_vector(15 downto 0)
);
end component;

signal s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s17: std_logic_vector(15 downto 0); 
signal PCWriteTotal:std_logic;
signal immediate_from_8,immediate_from_5:std_logic_vector(15 downto 0);
signal rx,ry,rz,s16: std_logic_vector(2 downto 0);
--signal immediate_after_extension: std_logic_vector(15 downto 0);
begin		
  PCWriteTotal<=PCWrite or PCWriteCond;
  immediate_from_8<=(s6(7)& s6(7)&s6(7)&s6(7)&s6(7)&s6(7)&s6(7)&s6(7)& s6(7 downto 0));
  immediate_from_5<=(s6(4)& s6(4)&s6(4)&s6(4)&s6(4)&s6(4)&s6(4)&s6(4)&s6(4)&s6(4)&s6(4)& s6(4 downto 0));
  
  rx<=s6(10 downto 8);
  ry<=s6(7 downto 5);
  rz<=s6(4 downto 2);
  instructions<=s6;
  data_bus<=s5;
  	--for test purpose only
	s1_out<=s1;s2_out<=s2;s3_out<=s3;s8_out<=s8;s10_out<=s10;s11_out<=s11;s12_out<=s12;s13_out<=s13;
	s15_out<=s15;s7_out<=s7;s16_out<=s16;s4_out<=s4;
	--for test purpose only
	
  U_A: dflip_flop port map(clock,rst,s8,s14);
  U_B: dflip_flop port map(clock,rst,s9,s4);
  U_ALU_Result_Register: dflip_flop_falling port map(clock,rst,s12,s13);
  U_DR: dflip_flop port map(clock,rst,s5,s15);
  U_Register_File: register_file port map(clock,rst,RegWrite,RegRead,s16,
  rx,ry,s7,s8,s9);
  U_ALU: alu port map(rst,s10,s11,ALUOp,s12,ALU_zero);
  U_Memory: memory port map(clock,rst,s3,s4,s5,MemRead,MemWrite);
  U_MemtoReg: multiplexor_two_bit generic map(16) port map(s13,s15,immediate_from_8,MemtoReg,s7);
  U_ALUSrcA: multiplexor port map(s2,s14,ALUSrcA,s10);
  U_IorD: multiplexor port map(s2,s13,IorD,s3);
  U_SE: multiplexor port map(immediate_from_8,immediate_from_5,SE,s17);
  U_PCSource: multiplexor port map(s12,s13,PCSource,s1);
  U_IR: single_register port map(clock,rst,IRWrite,s5,s6);
  U_PC: single_register port map(clock,rst,PCWriteTotal,s1,s2);
  U_RegDst: multiplexor_two_bit generic map(3) port map(rx,rz,ry,RegDst,s16);
  U_ALUSrcB: multiplexor_two_bit generic map(16) port map(s4,"0000000000000001",s17,ALUSrcB,s11);
end struct;







