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
				tmp_ram(0)<="1001100101001000";--r[2]<=Mem[8],LW R1 R2 8
				tmp_ram(1)<="1101101101001111";--Mem[15]<=r[2],SW R3 R2 F
				tmp_ram(2)<="1001100111101111";--r[7]<=Mem[15]=0x3333; LW R1 R7 F
				tmp_ram(8)<="0011001100110011";--Mem[8]=0x3333
	 elsif(rising_edge(clock)) then
	if(MemWrite='1') then
			tmp_ram(to_integer(unsigned(address))) <= data_in;
	elsif(MemRead='1') then
			data_out<=tmp_ram(to_integer(unsigned(address)));
	end if;
	 end if;
	 end process;
	
end behv;

