library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 
---------------------------------------------------
entity memory is
port(	 
       clock: in std_logic;
		 reset:		in std_logic;
		 data_in: in std_logic_vector (15 downto 0);--s4
		 data_out:out std_logic_vector (15 downto 0);--ram1_data,or s5
		 MemRead: in std_logic;
		 MemWrite: in std_logic;
		 Ram1OE: out std_logic;
		 Ram1WE: out std_logic;
		 Ram1EN: out std_logic

);

end memory;

---------------------------------------------------
--type mainState is (idle,read_1,write_1);
--signal state : mainState;
architecture behv of memory is  
type ram_type is array (0 to 15) of 
        		std_logic_vector(15 downto 0);
signal tmp_ram: ram_type;
          
begin
		Ram1OE<=not MemRead;
		Ram1WE<=not MemWrite;
   process(clock,reset,MemRead,MemWrite)
   
    begin

	 if (reset='0') then
				--state <=idle;
	 	Ram1EN<='0';    
	 elsif(rising_edge(clock)) then
			
		if(MemRead='1') then
				data_out<=(others=>'Z');
		elsif(MemWrite='1') then
				data_out<=data_in;
		end if;	 
	 end if;
    end process;
	
end behv;

