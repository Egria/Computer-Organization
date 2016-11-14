----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:50:14 11/06/2016 
-- Design Name: 
-- Module Name:    serial_write - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serial_write is
port(
		tbre,tsre,rst,clk:		in std_logic;
      send_data_signal: in std_logic;
		data_send_finished,wrn: out std_logic
);
end serial_write;

architecture Behavioral of serial_write is
type State is (Prepare,
	ram1_data_to_uart_sender_buffer,
	uart_sender_buffer_to_shift_register,
	uart_shift_register_to_serial_port,Finish);
	signal WriteState: State :=Prepare;
	signal data_sended_signal:std_logic;
begin
process(clk,rst,tbre,tsre,send_data_signal)
begin
if(rst='0') then 
data_sended_signal<=send_data_signal;
data_send_finished<='1';
elsif(falling_edge(clk)) then
case WriteState is
			when Prepare => 
			   if(data_sended_signal/=send_data_signal) then
				wrn <= '1';
				WriteState<=ram1_data_to_uart_sender_buffer;
				data_sended_signal<=send_data_signal;
				data_send_finished<='0';
				else
				WriteState<=Prepare;
				end if;
			when ram1_data_to_uart_sender_buffer => --Ð´´®¿ÚµÄ×´Ì¬1,TBD --write uart is controlled by one-step clock
				wrn<='0';
				WriteState<=uart_sender_buffer_to_shift_register;
			when uart_sender_buffer_to_shift_register => --Ð´´®¿ÚµÄ×´Ì¬2£¬TBD
				wrn<='1';
				WriteState<=uart_shift_register_to_serial_port;
			when uart_shift_register_to_serial_port =>
				if(tbre='1') then
				WriteState<=Finish;
				else
				WriteState<=uart_shift_register_to_serial_port;
				end if;
			when Finish => --Ð´´®¿ÚµÄ×´Ì¬3,TBD
			if(tsre='1') then
				WriteState<=Prepare;
				data_send_finished<='1';
				--the last data is sended.
			 else WriteState<=Finish;
			 end if;

	      when others => WriteState<=Finish;
end case;
end if;
end process;
end Behavioral;

