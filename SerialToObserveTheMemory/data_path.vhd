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
	instructions: out std_logic_vector(15 downto 0);
	led: out std_logic_vector(15 downto 0);
	ram1_data: inout std_logic_vector(15 downto 0);
	ram1_addr: out std_logic_vector(15 downto 0);
   data_ready: in std_logic;
	ram1_oe,ram1_we,ram1_en,wrn,rdn: out std_logic;
	click: in std_logic;
	tbre,tsre: in std_logic;
	SerialDisable: in std_logic;
	seg1: out std_logic_vector(6 downto 0)

);
end data_path;

architecture struct of data_path is

component serial_buffer is
Port(
	clock,reset: in std_logic;
 	MemRead: in std_logic;
	MemWrite: in std_logic;
	s3: in std_logic_vector(15 downto 0);
	s4: in std_logic_vector(15 downto 0);
	ram1_data: inout std_logic_vector(15 downto 0);
	ram1_addr: out std_logic_vector(15 downto 0);
	led:out std_logic_vector(15 downto 0);
   data_ready: in std_logic;
	tbre,tsre: in std_logic;
	ram1_oe,ram1_we,ram1_en,wrn,rdn: out std_logic;
	click: in std_logic;
	SerialDisable: in std_logic;
	seg1: out std_logic_vector(6 downto 0)
);
end component;
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

component dflip_flop_falling is
port(
      clk : in std_logic;
      rst : in std_logic;
      data_in : in std_logic_vector(15 downto 0);
      data_out : out std_logic_vector(15 downto 0)
);
end component;

signal s4,s3:std_logic_vector(15 downto 0);
signal s1,s2,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s17: std_logic_vector(15 downto 0); 
signal PCWriteTotal:std_logic;
signal immediate_from_8,immediate_from_5:std_logic_vector(15 downto 0);
signal rx,ry,rz,s16: std_logic_vector(2 downto 0);

begin		
  --s3 address
  --s4 data output from B register
  --s5 ram1 data bus
  PCWriteTotal<=PCWrite or PCWriteCond;
  immediate_from_8<=(s6(7)& s6(7)&s6(7)&s6(7)&s6(7)&s6(7)&s6(7)&s6(7)& s6(7 downto 0));
  immediate_from_5<=(s6(4)& s6(4)&s6(4)&s6(4)&s6(4)&s6(4)&s6(4)&s6(4)&s6(4)&s6(4)&s6(4)& s6(4 downto 0));
  
  rx<=s6(10 downto 8);
  ry<=s6(7 downto 5);
  rz<=s6(4 downto 2);
  instructions<=s6;

  U_serial_buffer: serial_buffer port map(clock,rst,MemRead,MemWrite,
  s3,s4,ram1_data,ram1_addr,led,data_ready,tbre,tsre,ram1_oe,ram1_we,ram1_en,
  wrn,rdn,click,SerialDisable,seg1);
  U_A: dflip_flop_falling port map(click,rst,s8,s14);
  U_B: dflip_flop_falling port map(click,rst,s9,s4);
  U_ALU_Result_Register: dflip_flop_falling port map(click,rst,s12,s13);
  U_DR: dflip_flop_falling port map(click,rst,ram1_data,s15);

  U_Register_File: register_file port map(click,rst,RegWrite,RegRead,s16,
  rx,ry,s7,s8,s9);
  U_ALU: alu port map(rst,s10,s11,ALUOp,s12,ALU_zero);
  U_MemtoReg: multiplexor_two_bit generic map(16) port map(s13,s15,immediate_from_8,MemtoReg,s7);
  U_ALUSrcA: multiplexor port map(s2,s14,ALUSrcA,s10);
  U_IorD: multiplexor port map(s2,s13,IorD,s3);
  U_SE: multiplexor port map(immediate_from_8,immediate_from_5,SE,s17);
  U_PCSource: multiplexor port map(s12,s13,PCSource,s1);
  U_IR: single_register port map(click,rst,IRWrite,ram1_data,s6);
  U_PC: single_register port map(click,rst,PCWriteTotal,s1,s2);
  U_RegDst: multiplexor_two_bit generic map(3) port map(rx,rz,ry,RegDst,s16);
  U_ALUSrcB: multiplexor_two_bit generic map(16) port map(s4,"0000000000000001",s17,ALUSrcB,s11);

end struct;



