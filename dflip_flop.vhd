library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dflip_flop is
port(
      clk : in std_logic;
      rst : in std_logic;
      data_in : in std_logic_vector(15 downto 0);
      data_out : out std_logic_vector(15 downto 0)
);
end entity dflip_flop;
 
architecture Behavioral of dflip_flop is
begin
   process (clk,rst) is
   begin
      if(rst='0') then
		data_out<=(data_out'range =>'0');
      elsif rising_edge(clk) then  
         data_out <= data_in;
      end if;
   end process;
end architecture Behavioral;
