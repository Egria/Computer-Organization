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
	data_to_B	:	out std_logic_vector(15 downto 0);
	ram1_data: inout std_logic_vector(7 downto 0);
	tbre,tsre: in std_logic;
	ram1_oe,ram1_we,ram1_en,wrn,rdn: out std_logic;
	click: in std_logic
);
end register_file;

architecture behv of register_file is			

  type rf_type is array (0 to 7) of 
        std_logic_vector(15 downto 0);
  signal tmp_rf: rf_type;
  signal SP,T,IH:std_logic_vector(15 downto 0);
  signal send_data_signal:std_logic :='0';
	signal data_send_finished:std_logic;
 signal rf_pointer_buffer:integer range 0 to 7;
 type State is (Waiting,
	PrepareSendingLowerBit,
	PrepareSendingHigherBit,
	StartSendingLowerBit,
	StartSendingHigherBit,
	WaitForLowerBitSendingFinished,
	WaitForHigherBitSendingFinished,PrepareSendNextWord,
	SendNextWord,Finished);
	signal GanzeState: State :=Waiting;

component serial_write
port(	
		ram1_oe,ram1_we,ram1_en,wrn,rdn: out std_logic;
      rst,clk,tbre,tsre:		in std_logic;
      send_data_signal: in std_logic; 
	   data_send_finished: out std_logic
);
end component;  


begin
  u_serial_write: serial_write port map(ram1_oe,ram1_we,ram1_en,wrn,rdn,rst,clock,tbre,tsre,
  send_data_signal,data_send_finished);

  write_process: process(clock, rst, write_addr, RegWrite, write_data)
  begin
    if rst='0' then				-- high active
        tmp_rf <= (tmp_rf'range => "0000000000000000");
   elsif (clock'event and clock = '1') then
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
    elsif (clock'event and clock = '1') then
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
    elsif (clock'event and clock = '1') then
	  data_to_B <= tmp_rf(to_integer(unsigned(read_2_addr)));
	  end if;
	end process;

  process(click,clock,rst)--default: all input signals are sensentive.
    begin
	 if(rst='0') then
	 send_data_signal<='0';
	 rf_pointer_buffer<=0;
	 GanzeState <= Waiting;
	 elsif(rising_edge(clock)) then
		 if(click='0') then
			case GanzeState is
			when Waiting => GanzeState <= PrepareSendingLowerBit;
			when PrepareSendingLowerBit =>
			ram1_data<=tmp_rf(rf_pointer_buffer)(7 downto 0);
			GanzeState <=StartSendingLowerBit;
			when StartSendingLowerBit =>
					send_data_signal<=not send_data_signal;
					GanzeState <=WaitForLowerBitSendingFinished;
			when WaitForLowerBitSendingFinished =>
					if(data_send_finished='1') then
--						send_data_signal<='0';
						ram1_data <="ZZZZZZZZ";
						GanzeState <=PrepareSendingHigherBit;
					else
						GanzeState <=WaitForLowerBitSendingFinished;
					end if;
			when PrepareSendingHigherBit =>
					ram1_data<=tmp_rf(rf_pointer_buffer)(15 downto 8);
					GanzeState <= StartSendingHigherBit;
			when StartSendingHigherBit =>
					send_data_signal<=not send_data_signal;--'1';
					GanzeState <=WaitForHigherBitSendingFinished;
			when WaitForHigherBitSendingFinished =>
					if(data_send_finished='1') then
						ram1_data <="ZZZZZZZZ";
						GanzeState <= PrepareSendNextWord;--SendNextWord;
					else
						GanzeState <=WaitForHigherBitSendingFinished;
					end if;
			when PrepareSendNextWord=>
						rf_pointer_buffer<=rf_pointer_buffer+1;
					GanzeState<= SendNextWord;
			when SendNextWord =>
					if(rf_pointer_buffer<7) then
						GanzeState <= PrepareSendingLowerBit;
					else
					GanzeState <= Finished;
					end if;
			when others =>
					GanzeState <= Finished;
			end case;
			else
			end if;
			
    end if;
	 end process;
	
end behv;













