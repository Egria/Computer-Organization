---------------------------------------------------
-- Simple microprocessor_debug Module (ESD boclick Figure 2.5)		
-- by Weijun Zhang, 04/2001
--
-- microprocessor_debug stands for arithmatic logic unit.
-- It perform multiple operations according to 
-- the control bits.
-- we use 2's complement subraction in this example
-- two n-bit inputs
---------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 
---------------------------------------------------
entity microprocessor_debug is
port(	  
   clock: in std_logic;--make sure the input is finished;
   reset:		in std_logic;
	seg2:out std_logic_vector(6 downto 0);
	led: out std_logic_vector(15 downto 0);
	ram1_data: inout std_logic_vector(15 downto 0);
	ram1_addr: out std_logic_vector(15 downto 0);
   data_ready: in std_logic;
	ram1_oe,ram1_we,ram1_en,wrn,rdn: out std_logic;
	click: in std_logic;
	tbre,tsre: in std_logic;
	seg1: out std_logic_vector(6 downto 0)
);

end microprocessor_debug;

---------------------------------------------------

architecture behv of microprocessor_debug is
  --signal button_k1,button_k2,button_k3,button_k4:std_logic;
  signal current_state:std_logic_vector(3 downto 0);
  --signal instruction_step_out_inner: std_logic_vector(2 downto 0);

component microprocessor
port(
	clock:	in 	std_logic;
	rst:		in 	std_logic;
	state_code: out std_logic_vector(3 downto 0);
	led: out std_logic_vector(15 downto 0);
	ram1_data: inout std_logic_vector(15 downto 0);
	ram1_addr: out std_logic_vector(15 downto 0);
   data_ready: in std_logic;
	ram1_oe,ram1_we,ram1_en,wrn,rdn: out std_logic;
	click: in std_logic;
	tbre,tsre: in std_logic;
	seg1: out std_logic_vector(6 downto 0)
	);
end component;


begin
	MyMicroProcessor: microprocessor port map(clock,reset,current_state,led,
	ram1_data,ram1_addr,data_ready,
	ram1_oe,ram1_we,ram1_en,wrn,rdn,click,tbre,tsre,seg1);	
	
	process(current_state)
	begin
		case current_state is
			when "0000" => seg2 <= not "1000000";
			when "0001" => seg2 <= not "1111001";
			when "0010" => seg2 <= not "0100100";
			when "0011" => seg2 <= not "0110000";
			when "0100" => seg2 <= not "0011001";
			when "0101" => seg2 <= not "0010010";
			when "0110" => seg2 <= not "0000010";
			when "0111" => seg2 <= not "1111000";
			when "1000" => seg2 <= not "0000000";
			when "1001" => seg2 <= not "0010000";
			when "1010" => seg2 <= not "0001000";
			when "1011" => seg2 <= not "0000011";
			when "1100" => seg2 <= not "1000110";
			when "1101" => seg2 <= not "0100001";
			when "1110" => seg2 <= not "0000110";
			when "1111" => seg2 <= not "0001110";
			when others => seg2 <= not "1111111";
		end case;
	end process;

end behv;
