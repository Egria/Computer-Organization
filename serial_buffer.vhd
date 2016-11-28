library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity serial_buffer is		-- entity declaration
Port(
	clock,reset: in std_logic;
 	MemRead: in std_logic;
	MemWrite: in std_logic;
	s3: in std_logic_vector(15 downto 0);
	s4: in std_logic_vector(15 downto 0);
	ram1_data: inout std_logic_vector(15 downto 0);
	ram1_addr: out std_logic_vector(15 downto 0);
   data_ready: in std_logic;
	tbre,tsre: in std_logic;
	ram1_oe,ram1_we,ram1_en,wrn,rdn: out std_logic;
	SerialDisable: in std_logic;
	rxd: in std_logic;
	txd:out std_logic
);

end serial_buffer;

	

----------------------------------------------------------------

architecture TB of serial_buffer is
signal send_data_signal:std_logic :='0';
signal data_received,data_send_finished:std_logic :='0';
signal mem_read_request_from_serial_port,mem_write_request_from_serial_port:std_logic;
signal MemReadTotal,MemWriteTotal: std_logic;
component serial_write
 port(
		tbre,tsre,rst,clk:		in std_logic;
      send_data_signal: in std_logic;
		data_send_finished,wrn: out std_logic
);
end component;  
component ram1
port(
		 clock: in std_logic;
       reset:		in std_logic;
		 MemRead: in std_logic;
		 MemWrite: in std_logic;
		 Ram1OE: out std_logic;
		 Ram1WE: out std_logic
);
end component;
component serial_read
port(   
   clk,data_ready,rst: in std_logic;
	rdn:out std_logic;
	data_received: out std_logic
); 		
end component;
component rcvr 
port (rst,clk16x,rxd,rdn : in std_logic;
data_ready, parity_error, framing_error : out std_logic;
clear_data_ready:in std_logic;
dout : out std_logic_vector(7 downto 0)
);
end component;

component clkcon
    Port ( rst,clk0 : in  STD_LOGIC;
           clk : out  STD_LOGIC);
end component;

component txmit 
port (rst,clk16x,wrn : in std_logic;
din : in std_logic_vector(7 downto 0);
tbre,tsre,txd: out std_logic);
end component ;
signal sclk : std_logic;
signal clear_data_ready_2:  std_logic;
signal data_ready_2 : std_logic;
signal tbre_2,wrn_2,rdn_2 :  std_logic;
signal tsre_2 : std_logic;
signal framing_error,parity_error :std_logic;
signal data_from_port_2,data_to_send_2: std_logic_vector(7 downto 0);
signal send_state: std_logic_vector(1 downto 0);
signal receive_state:std_logic;
type main_state is (
		waiting, readcmd,
		--nop1, nop2,
		error0, error1,
		readramA0, readramA1, readramA2, readramA3, readramA4, readramA5, readramA6,
		writeramA0, writeramA1, writeramA2, writeramA3, writeramA4, writeramA5,writeramA6,
		respondcmd0, respondcmd1, respondcmd2, respondcmd3,
		readsize0, readsize1, readsize2, readsize3, readsize4, readsize5, 
		readsize6, readsize7,readsize8,write_serial2_1,write_serial2_2,
		read_serial2_1,read_serial2_2
	);
	signal state : main_state := waiting;
	signal next_state, readsize_state : main_state;
	signal response : std_logic_vector(7 downto 0);
	signal high : std_logic;
	signal staddr, edaddr : std_logic_vector(15 downto 0);
	signal data_tmp : std_logic_vector(15 downto 0);
	signal sendflag : std_logic;
	signal write_delay: integer range 0 to 15;
	signal tmp_addr: std_logic_vector(15 downto 0);
	signal tmp_write_1,tmp_write_2,tmp_write_total:std_logic;--unit step clock only, detecting the first rising edge of MemWrite
	signal tmp_read_1,tmp_read_2,tmp_read_total:std_logic;--unit step clock only, detecting the first rising edge of MemWrite

	--signal serial_read_request_from_cpu;
begin
  MemReadTotal<=mem_read_request_from_serial_port or MemRead;-- and (not serial_read_request_from_cpu));
  MemWriteTotal<=mem_write_request_from_serial_port or MemWrite;
  ram1_addr<=tmp_addr or s3;
  tmp_write_total<=tmp_write_1 and (not tmp_write_2);
  tmp_read_total<=tmp_read_1 and (not tmp_read_2);
  u_serial_write: serial_write port map(tbre,tsre,reset,clock,
  send_data_signal,data_send_finished,wrn); 
  u_serial_read: serial_read port map(clock,data_ready,reset,rdn,data_received);
  u_ram1: ram1 port map(clock,reset,MemReadTotal,MemWriteTotal,ram1_oe,ram1_we);
u1 : txmit PORT MAP 
(rst => reset,
clk16x => sclk,
wrn => wrn_2,
din => data_to_send_2,
tbre => tbre_2,
tsre => tsre_2,
txd => txd);


u2 : rcvr PORT MAP  
(rst => reset,
clk16x => sclk,
rxd => rxd,
rdn => rdn_2,
data_ready => data_ready_2,
framing_error => framing_error,
parity_error => parity_error,
clear_data_ready => clear_data_ready_2,
dout => data_from_port_2
);

u3:clkcon port map
  (rst=>reset,
	clk0=>clock,
	clk=>sclk);

  process(clock,reset)
   begin
	 if(reset='0') then
    tmp_write_1<='0';
	 tmp_write_2<='0';
	 tmp_read_1<='0';
	 tmp_read_2<='0';
	 elsif(rising_edge(clock)) then
	 tmp_write_1<=MemWrite;
	 tmp_write_2<=tmp_write_1;
	 tmp_read_1<=MemRead;
	 tmp_read_2<=tmp_read_1;
	 end if;
  end process;
  process(clock,reset)--default: all input signals are sensentive.
    begin
	 if(reset='0') then
	 state<=waiting;
	 send_data_signal<='0';
	 state <= waiting;
	 ram1_en<='0';
	 wrn_2<='1';
	 clear_data_ready_2<='1';
	 rdn_2<='1';
	 mem_read_request_from_serial_port<='0';
	 mem_write_request_from_serial_port<='0';
	 --serial_read_request_from_cpu<='1';
	 ram1_data<=(others => '0');
	 tmp_addr<=(others =>'0');
	 elsif(rising_edge(clock)) then --only place to revise ram1_data_bus and address bus
			case state is--when the program is running,the serial port can not be used!
			when waiting =>   --try to stop the program at certain point.MemRead=0;
				if(tmp_write_total='1') then--MemWrite
					if(s3=x"bf00") then--only use the lower 8 bits
						data_to_send_2<=s4(7 downto 0);
						wrn_2<='1';
						state<=write_serial2_1;
						--send_data_signal <=not send_data_signal;--send data to serial port 
					elsif(s3=x"bf01") then
					ram1_en<='1';
					ram1_data(0)<=tbre and tsre;
					else
					ram1_data<=s4;
					ram1_en<='0';
					end if;
				elsif(tmp_read_total='1') then--MemRead
					--if(s3=x"bf01") then
					--read state from serial port here
					--	ram1_data(0)<=data_send_finished;--the lowest bit.
					--	ram1_data(1)<=data_received;
					--else
					if(s3=x"bf00") then
					ram1_en<='1';
					rdn_2<='1';--dout<='zzz';
					state<=read_serial2_1;
					--clear_data_ready_2<='1';--data_ready_2<='0';
					elsif(s3=x"bf01") then
					ram1_en<='1';
					clear_data_ready_2<='0';
					ram1_data(1)<=data_ready_2;
					else
					--serial_read_request_from_cpu<='0';	
					--if receive data from serial port, memory read should be closed,
					ram1_en<='0';
					ram1_data<=(others => 'Z');--if MemRead='1' then ram1_data<='zzz'
					end if;
				elsif(SerialDisable='0') then
					ram1_en<='0';
					ram1_data<=(others => 'Z');
					if(data_received = '1') then
							state <= readcmd;
					end if;
				else
					ram1_en<='0';
				end if;
			when readcmd => 	
				case ram1_data(1 downto 0) is
					when "01" =>    --ram1√¸¡Ó
						if (ram1_data(2) = '0') then--∂¡ram1 001,µÕ»˝Œª 0x01
							state <= readramA0;
						else--–¥ram1 101 0x05
							state <= writeramA0;
						end if;
					when others =>    --ERROR Handling
						state <= error0;
				end case;
			when readramA0 =>
				sendflag <= '0';
				next_state <= readramA1;
				state <= respondcmd0;
				response <= "00100011";
			when readramA1 =>
				state <= readsize0;
				readsize_state <= readramA2;
			when readramA2 =>
				state <= readramA3;
				tmp_addr <= staddr;
				high <= '0';
			when readramA3 =>
				if (sendflag = '1') then
					response<=x"23";
					next_state<= waiting;
					state <= respondcmd0;
				else
					state <= readramA4;
					write_delay<=0;
				end if;
			when readramA4 =>
				state <= readramA5;
				mem_read_request_from_serial_port<='1';
				ram1_data <= (others => 'Z');
			when readramA5 =>--read out from sram memory only in one period.
				state <= readramA6;
				data_tmp <= ram1_data;
				mem_read_request_from_serial_port<='0';
			when readramA6 =>
				if (tmp_addr = edaddr and high = '0') then
					sendflag <= '1';
					state<=readramA3;
				elsif (high = '1') then
					tmp_addr <= tmp_addr + 1;
					high <= '0';
					state <= respondcmd0;
					response <= data_tmp(15 downto 8);
					next_state <= readramA3;
				else
					response<= data_tmp(7 downto 0);
					high <= '1';
					next_state<=readramA6;
					state <= respondcmd0;
				end if;
			when writeramA0 =>
				next_state <= writeramA1;
				state <= respondcmd0;
				response <= "00100011";
			when writeramA1 =>
				state <= readsize0;
				readsize_state <= writeramA2;
			when writeramA2 =>
				tmp_addr <= staddr(15 downto 0)-1;
				high <= '1';
				state <= writeramA3;
			when writeramA3 =>
				write_delay<=0;
				ram1_data<=(others=>'Z');
				mem_write_request_from_serial_port<='0';
				if (data_received = '1') then
					if (high = '1') then
						tmp_addr <= tmp_addr + 1;
						high <= '0';
					else
						high <= '1';
					end if;
					state <=writeramA4;
				else
						state <=writeramA3;
				end if;
			when writeramA4 =>
				if(high='0') then 
					data_tmp(7 downto 0) <= ram1_data(7 downto 0);
   				state <= writeramA3;
				else
					data_tmp(15 downto 8)<=ram1_data(7 downto 0);
					state <= writeramA5;
					mem_write_request_from_serial_port <= '1';
				end if;
			when writeramA5 =>--write to memory in one clock period
					if(write_delay=15) then
						ram1_data<= data_tmp;
						state<=writeramA6;
						write_delay<=0;
					else
					write_delay<=write_delay+1;
					state<=writeramA5;
					end if;
			when writeramA6 =>
				if(write_delay=15) then
					if(tmp_addr = edaddr) then
					response<=x"23";
					next_state<= waiting;
					state <= respondcmd0;
					mem_write_request_from_serial_port <= '0';
					write_delay<=0;
					else
					mem_write_request_from_serial_port <= '0';
					response<=x"24";
					next_state<= writeramA3;
					state <= respondcmd0;
					end if;
				else
							write_delay<=write_delay+1;
							state<=writeramA6;
				end if;
			when respondcmd0 =>
				send_data_signal<=not send_data_signal;
				ram1_data(7 downto 0) <= response;
				state <= respondcmd1;
			when respondcmd1 =>
				if(data_send_finished='1') then
					state <= next_state;
				else
					state <= respondcmd1;
				end if;
			when error0 =>
					state <= respondcmd0;
					response <= x"22";
					next_state <= waiting;
			when readsize0 =>
				ram1_data<=(others => 'Z');
				if (data_received = '1') then
					state <= readsize1;
				end if;
			when readsize1 =>
				staddr(15 downto 8) <= ram1_data(7 downto 0);
				state <= respondcmd0;
				response <= x"25";
				next_state <= readsize2;
			when readsize2 =>
				ram1_data<=(others => 'Z');
				if (data_received = '1') then
					state <= readsize3;
				end if;
			when readsize3 =>
				staddr(7 downto 0) <= ram1_data(7 downto 0);
				state <= respondcmd0;
				response <= x"26";
				next_state <= readsize4;
			when readsize4 =>
				ram1_data<=(others => 'Z');
				if (data_received = '1') then
					state <= readsize5;
				end if;
			when readsize5 =>
				edaddr(15 downto 8) <= ram1_data(7 downto 0);
				state <= respondcmd0;
				response <= x"28";
				next_state <= readsize6;
			when readsize6 =>
				ram1_data<=(others => 'Z');
				if (data_received = '1') then
					state <= readsize7;
				end if;
			when readsize7 =>
				edaddr(7 downto 0) <= ram1_data(7 downto 0);
				state <= respondcmd0;
				response <= x"29";
				next_state <= readsize8;
			when readsize8 => 
				state <=readsize_state;
			when write_serial2_1=>
				state <=write_serial2_2;
				wrn_2<='0';
				--state<=waiting;
			when write_serial2_2=>
				wrn_2<='1';
				--if(tbre_2='1' and tsre_2='1') then
				state <=waiting;
				--end if;
			when read_serial2_1=>
				clear_data_ready_2<='0';
				--if(data_ready_2='1') then
					state<=read_serial2_2;
					rdn_2<='0';--data get
				--end if;
			when read_serial2_2=>
				  clear_data_ready_2<='1';--data_ready_2<='0';
				  ram1_data(7 downto 0)<=data_from_port_2;
				  state<=waiting;
			when others =>
					state <= waiting;
			end case;
			
    end if;
	 end process;
	 
	 
--	process(clock)
--	begin
--	if(rising_edge(clock)) then
--		case state is
--			when waiting => seg1 <= not "1000000";--0
--			when readcmd => seg1 <= not "1111001";--1
--			when readramA0 => seg1 <= not "0100100";--2
--			when readramA1  => seg1 <= not "0110000";--3
--			when respondcmd0 => seg1 <= not "0011001";--4
--			when respondcmd1 => seg1 <= not "0010010";--5
--			when error0 => seg1 <= not "0000010";--6
--			when readsize0 => seg1 <= not "1111000";--7
--			when readsize1 => seg1 <= not "0000000";--8
--			when writeramA6 => seg1 <= not "0010000";--9
--			when writeramA0 => seg1 <= not "0001000";--a
--			when writeramA1 => seg1 <= not "0000011";--b
--			when writeramA2 => seg1 <= not "1000110";--c
--			when writeramA3 => seg1 <= not "0100001";--d
--			when writeramA4 => seg1 <= not "0000110";--e
--			when writeramA5 => seg1 <= not "0001110";--f
--			when others => seg1 <= not "1111111";--exception
--		end case;
--	end if;
--	end process;


end TB;