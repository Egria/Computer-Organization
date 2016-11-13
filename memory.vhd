library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 
---------------------------------------------------
entity memory is
port(	 
       clock: in std_logic;
		 reset:		in std_logic;
 		 address: in std_logic_vector(15 downto 0);
		 data_in: in std_logic_vector (15 downto 0);
		 data_out:out std_logic_vector (15 downto 0);
		 MemRead: in std_logic;
		 MemWrite: in std_logic
);

end memory;

---------------------------------------------------

architecture behv of memory is  
type ram_type is array (0 to 15) of 
        		std_logic_vector(15 downto 0);
signal tmp_ram: ram_type;
          
begin
  process(clock,reset)
    begin
	 if (reset='0') then
tmp_ram(0)<="0000100000000000";--NOP
tmp_ram(1)<="1001101001001010";
tmp_ram(2)<="1110101000000000";
tmp_ram(3)<="0000100000000000";--NOP
tmp_ram(4)<="1110001001001001";
tmp_ram(5)<="1110001001001001";
tmp_ram(6)<="1110001001001001";
tmp_ram(7)<="1101101101001011";
tmp_ram(8)<="1001101101101011";				
tmp_ram(10)<="0000000000000110";
	 elsif(rising_edge(clock)) then
	if(MemWrite='1') then
			tmp_ram(to_integer(unsigned(address))) <= data_in;
	elsif(MemRead='1') then
			data_out<=tmp_ram(to_integer(unsigned(address)));
	end if;
	 end if;
	 end process;
	
end behv;

