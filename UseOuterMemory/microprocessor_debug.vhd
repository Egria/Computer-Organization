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
--	instruction_step_out: out std_logic_vector(2 downto 0);
   globalClock: in std_logic;--make sure the input is finished;
   reset:		in std_logic;
	clock: in std_logic;--for update the led only 
	led:	out std_logic_vector(15 downto 0);
	seg1:out std_logic_vector(6 downto 0);
	seg2:out std_logic_vector(6 downto 0);
	button_1: in std_logic;
	--button_1,button_2,button_3,button_4: in std_logic;
	ram1_data: inout std_logic_vector(15 downto 0);
	ram1_addr: out std_logic_vector(15 downto 0);
		rdn: out std_logic;

	Ram1OE: out std_logic;
	Ram1WE: out std_logic;
	Ram1EN: out std_logic
);

end microprocessor_debug;

---------------------------------------------------

architecture behv of microprocessor_debug is
  --signal button_k1,button_k2,button_k3,button_k4:std_logic;
  signal button_k1: std_logic;
  signal current_state:std_logic_vector(3 downto 0);
  signal encoded_state:std_logic_vector(3 downto 0);
   type data_path_show_state is (s1,s2,s4,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15);
  signal data_path_shower : data_path_show_state;
  --signal instruction_step_out_inner: std_logic_vector(2 downto 0);
  signal s6_out,s9_out,s14_out,s5_out,s4_out,s15_out,s7_out,s1_out,s2_out,s3_out,
		s8_out,s10_out,s11_out,s12_out,s13_out: std_logic_vector(15 downto 0);

component key_processing
port(
	clk: in std_logic;
	rst_n: in std_logic;
	key1: in std_logic;
	key: out std_logic
);
end component;          


component microprocessor
port(
	clock:	in 	std_logic;
	rst:		in 	std_logic;
	ram1_data: inout std_logic_vector(15 downto 0);
	ram1_addr: out std_logic_vector(15 downto 0);
	s6_out,s9_out,s14_out: out std_logic_vector(15 downto 0);
	s4_out,s15_out,s7_out,s1_out,s2_out,s8_out,s10_out,s11_out,s12_out,s13_out: out std_logic_vector(15 downto 0);
	state_code: out std_logic_vector(3 downto 0);
	Ram1OE: out std_logic;
	Ram1WE: out std_logic;
	Ram1EN: out std_logic
);
end component;
begin
	MyMicroProcessor: microprocessor port map(globalClock,reset,ram1_data,ram1_addr,s6_out,s9_out,s14_out,s4_out,s15_out,
	s7_out,s1_out,s2_out,s8_out,s10_out,s11_out,s12_out,s13_out,
	current_state,
	Ram1OE,Ram1WE,Ram1EN);
   Mybutton_1: key_processing port map (clock,reset,button_1,button_k1);
   process(reset,button_k1)
	begin
		if reset = '0' then
			rdn<='1';
			data_path_shower <= s1;--datapath;
		elsif rising_edge(button_k1) then
			case data_path_shower is
				when s1 =>
					data_path_shower <= s2;
				when s2 =>
					data_path_shower <= s4;
				when s4 =>
					data_path_shower <= s6;
				when s6 =>
					data_path_shower <= s7;
				when s7 =>
					data_path_shower <= s8 ;
				when s8 =>
				   data_path_shower <= s9 ;
				when s9 =>
				   data_path_shower <= s10 ;
				when s10=>
					data_path_shower <= s11;
				when s11 =>
					data_path_shower <= s12 ;
				when s12 =>
				   data_path_shower <= s13 ;
				when s13 =>
					data_path_shower <= s14 ;
				when s14 =>
					data_path_shower <= s15 ;
				when s15 =>
					data_path_shower <= s1;
				when others =>
				   data_path_shower <= s1;
			end case ;
		end if ;
	end process ;

	
	process(clock,reset)
	begin
--		instruction_step_out<=instruction_step_out_inner;
		if(reset='0') then
			encoded_state <= "0001";
			led<=(led'range=>'0');
		elsif(rising_edge(clock)) then
		  case data_path_shower is
				when s1 => led<=s1_out;	encoded_state<="0001";
				when s2 => led<=s2_out;	encoded_state<="0010";
				when s4 => led<=s4_out;	encoded_state<="0100";
				when s6 => led<=s6_out;	encoded_state<="0110";
				when s7 => led<=s7_out;	encoded_state<="0111";
				when s8 => led<=s8_out;	encoded_state<="1000";
				when s9 => led<=s9_out;	encoded_state<="1001";
				when s10=> led<=s10_out;	encoded_state<="1010";
				when s11 => led<=s11_out;	encoded_state<="1011";
				when s12 => led<=s12_out;	encoded_state<="1100";
				when s13 => led<=s13_out;	encoded_state<="1101";
				when s14 => led<=s14_out;	encoded_state<="1110";
				when s15 => led<=s15_out;	encoded_state<="1111";
				when others =>led<=s1_out;	encoded_state<="0001";
	end case ;
	end if;
	end process;	
	
	
	
	process(encoded_state)
	begin
		case encoded_state is
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

    	
	process(current_state)
	begin
		case current_state is
			when "0000" => seg1 <= not "1000000";
			when "0001" => seg1 <= not "1111001";
			when "0010" => seg1 <= not "0100100";
			when "0011" => seg1 <= not "0110000";
			when "0100" => seg1 <= not "0011001";
			when "0101" => seg1 <= not "0010010";
			when "0110" => seg1 <= not "0000010";
			when "0111" => seg1 <= not "1111000";
			when "1000" => seg1 <= not "0000000";
			when "1001" => seg1 <= not "0010000";
			when "1010" => seg1 <= not "0001000";
			when "1011" => seg1 <= not "0000011";
			when "1100" => seg1 <= not "1000110";
			when "1101" => seg1 <= not "0100001";
			when "1110" => seg1 <= not "0000110";
			when "1111" => seg1 <= not "0001110";
			when others => seg1 <= not "1111111";
		end case;
	end process;

end behv;
