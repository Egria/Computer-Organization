-------------------------------------------------------------
-- Simple Microprocessor Design (ESD Book Chapter 3) 
-- Copyright 2001 Weijun Zhang
--
-- Register Files (16*16) of datapath compsed of
-- 4-bit address bus; 16-bit data bus
-- reg_file.vhd
-------------------------------------------------------------

library	ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;			   

entity register_file is
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
end register_file;

architecture behv of register_file is			

  type rf_type is array (0 to 7) of 
        std_logic_vector(15 downto 0);
  signal tmp_rf: rf_type;
  signal SP,T,IH:std_logic_vector(15 downto 0);
  

begin

  write_process: process(clock, rst, write_addr, RegWrite, write_data)
  begin
    if rst='0' then				-- high active
        tmp_rf <= (tmp_rf'range => "0000000000000000");
   elsif (clock'event and clock = '0') then
	  case RegWrite is
	   when "001" =>
	    tmp_rf(to_integer(unsigned(write_addr))) <= write_data;
		when "010" =>
		SP<=write_data;
		when "011" =>
		T<=write_data;
		when "101" =>
		IH<=write_data;
		when others =>
	end case;
	end if;
  end process;						   
	
  read_1_process: process(clock, rst, RegRead, read_1_addr)
  begin
    if rst='0' then
	data_to_A <= (data_to_A'range =>'0');
    elsif (clock'event and clock = '0') then
	  case RegRead is
	  --when "00" =>							 
	    --data_to_A <= tmp_rf(to_integer(unsigned(read_1_addr)));
	  when "01" =>
	    data_to_A <= T;
	  when "10" =>
	    data_to_A <= SP;
	  when "11" =>
		 data_to_A <= IH;
	  when others =>
	    data_to_A <= tmp_rf(to_integer(unsigned(read_1_addr)));
	  end case;
	  end if;
   end process;
	
  read2: process(clock, rst, read_2_addr)
  begin
    if rst='0' then
		data_to_B<= (data_to_B'range =>'0');
    elsif (clock'event and clock = '0') then
	  data_to_B <= tmp_rf(to_integer(unsigned(read_2_addr)));
	  end if;
	end process;
	
end behv;













