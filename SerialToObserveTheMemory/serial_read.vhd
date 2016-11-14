---------------------------------------------------
---------------------------------------------------

library ieee;

use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity serial_read is 

port(   
   clk,data_ready,rst: in std_logic;
	rdn:out std_logic;
	data_received: out std_logic
);
end serial_read;
architecture behv of serial_read is
type State is (Prepare,
	uart_to_data_bus,Finish);
signal ReadState: State :=Prepare;

begin

--signal cnt:integer range 0 to 1024:=0;
	process(clk)
 	 --variable is_clicked: std_logic;
	-- variable myregister: std_logic_vector(7 downto 0);
    begin
	if(rising_edge(clk)) then
	case ReadState is
		when Prepare =>
		rdn <= '1';
		data_received<='0';
	if(data_ready='1') then
		ReadState <=uart_to_data_bus;
	else ReadState <=Prepare;
	end if;
	   when uart_to_data_bus =>
		rdn <= '0';
		ReadState<=Finish;
		when Finish =>
		data_received<='1';
		ReadState<=Prepare;
		when others =>ReadState <=Prepare;
	  end case;
	
	end if;
   end process;
  
end behv;