--------------------------------------------------------
-- Simple Microprocessor Design
--
-- Program Counter 
-- single_register.vhd
--------------------------------------------------------

library	ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_register is
port(	 clk,rst:	in std_logic;
		single_register_enable: in std_logic;
		single_register_in:	in std_logic_vector(15 downto 0);
		single_register_out:	out std_logic_vector(15 downto 0)
);
end single_register;

architecture behv of single_register is
signal tmp_single_register: std_logic_vector(15 downto 0);

begin				
	process(clk,rst)
	begin
	if(rst='0') then
		tmp_single_register<=(tmp_single_register'range=>'0');
	elsif(clk'event and clk='1') then
			if single_register_enable='1' then
				tmp_single_register <= single_register_in;
			end if;
	end if;
	end process;
	
	single_register_out<=tmp_single_register;
end behv;


