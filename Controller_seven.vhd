----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:53:33 04/13/2012 
-- Design Name: 	Gao XueCheng
-- Module Name:    Controler_seven - Behavioral 
-- Project Name: Controler_seven
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

entity Controler_seven is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           instructions : in  STD_LOGIC_VECTOR (15 downto 0);
			  PCWrite,PCWriteCond,PCSource: out std_logic ;
			  ALUOp : out std_logic_vector(3 downto 0) ;
			  ALUSrcA : out std_logic ;
			  ALUSrcB : out std_logic_vector(1 downto 0) ;
			  MemRead : out std_logic ;
			  MemWrite : out std_logic ;
			  IRWrite : out std_logic ;
			  MemtoReg :out  std_logic_vector(1 downto 0) ;
			  RegWrite : out std_logic_vector(2 downto 0) ;
			  RegDst : out std_logic_vector(1 downto 0) ;
			  IorD : out std_logic;
			  SE: out std_logic;
			  bZero_ctrl: in std_logic;
			  next_instruction: out std_logic
);
end Controler_seven;

architecture Behavioral of Controler_seven is

signal bzero : std_logic ;
type controler_state is (instruction_fetch,decode,execute,mem_control,write_reg);
signal state : controler_state;
begin

	

	process(rst,bZero_Ctrl)
	begin
		if rst = '0' then
			bzero <= '0' ;
		elsif rising_edge(bZero_Ctrl) then
			if bzero = '0' then
				bzero <= '1' ;
			elsif bzero = '1' then
				bzero <= '0' ;
			end if ;
		end if ;
	end process;
	
	process(bzero)
	begin
		if bzero = '1' then
			PCWriteCond <= '1' ;
		elsif bzero = '0' then
			PCWriteCond <= '0' ;
		end if ;
	end process ;
	
	process(rst,clk)
	begin
		if(rst = '0') then
			next_instruction<='0';
			state <= instruction_fetch;
			IorD <= '0' ;
			IRWrite <= '0' ;
			MemRead <= '0' ;
			MemWrite <= '0' ;
			MemtoReg <= "00" ;
			ALUOp <= "0000" ;
			ALUSrcA <= '0' ;
			ALUSrcB <= "00" ;
			PCWrite <= '0' ;
			PCSource <= '0' ;
			SE <='0';
			RegDst <= "00" ;
			RegWrite <= "000" ;
		elsif rising_edge(clk) then
			case state is
				when instruction_fetch =>
				next_instruction<='1';
					MemRead <= '1' ;
					ALUSrcA <= '0' ;
					IorD <= '0' ;
					ALUSrcB <= "01" ;
					ALUOp <= "0000";
					PCWrite <= '1' ;
					PCSource <= '0' ;
					IRWrite <= '1' ;
					RegWrite <= "000" ;
					state <= decode ;
				when decode =>
				next_instruction<='0';
					MemRead <= '0' ;
					PCWrite <= '0' ;
					ALUSrcA<='0';
					ALUSrcB<="10";
					SE<='0';
					ALUOp<="0000";
					state <= execute ;
				when execute =>
					IRWrite <= '0';
					case instructions(15 downto 11) is 
						when "00100" =>				-------------BEQZ
							ALUSrcA <= '1' ;
							ALUOp <= "1010" ;
							PCSource <= '1' ;
							state <= instruction_fetch ;
						when "10011" =>				-------------LW	
							ALUSrcA <= '1' ;
							ALUSrcB <= "10" ;
							ALUOp <= "0000" ;
							SE<='1';
							state <= mem_control ;
						when "11011" =>				-------------SW	
							ALUSrcA <= '1';
							ALUSrcB <= "10" ;
							ALUOp <= "0000" ;
							SE<='1';
							state <= mem_control ;
						when "11100" =>
							case instructions(1 downto 0) is
								when "01" =>			-------------ADDU
									ALUSrcA <= '1';
									ALUSrcB <= "00";
									ALUOp <= "0000" ;
								when "11" =>			-------------SUBU
									ALUSrcA <= '1';
									ALUSrcB <= "00";
									ALUOp <= "0001" ;
								when others =>
									null ;
							end case ;
							state <= write_reg ;
						when "11101" =>
							case instructions(4 downto 0) is
								when "01101" =>		------------OR
									ALUSrcA <= '1';
									ALUSrcB <= "00";
									ALUOp <= "1010";
									state <= write_reg ;
								when "00000" =>
									case instructions(7 downto 5) is
										when "000" =>	------------JR
											ALUSrcA<='1';
											ALUOp<="1010";
											PCWrite <= '1';
											PCSource <= '0' ;
											state <= instruction_fetch ;
										when others =>
											null ;
									end case ;
								when others =>
									null ;
							end case ;
							when others =>
								null ;
					end case ;
				when mem_control =>
					PCWrite <= '0' ;
					RegWrite <= "000" ;
					case instructions(15 downto 11) is 
						when "10011" =>				-------------LW	
							MemRead <= '1' ;
							IorD <= '1' ;
							state <= write_reg ;
						when "11011" =>				-------------SW	
							MemWrite <= '1' ;
							IorD <= '1' ;
							state <= write_reg ;
						when others =>
							null ;
					end case;
				when write_reg =>
					MemWrite <= '0' ;
					MemRead <= '0' ;
					case instructions(15 downto 11) is 
						when "10011" =>				-------------LW	
							RegDst <= "10";
							RegWrite <= "001";
							MemtoReg <= "01" ;
						when "11011" =>				-------------SW	
							MemWrite <= '0' ;
							IorD <= '0' ;
						when "11100" =>
							case instructions(1 downto 0) is
								when "01" =>			-------------ADDU
									RegDst <= "01";
									RegWrite <= "001" ;
									MemtoReg <= "00" ;
								when "11" =>			-------------SUBU
									RegDst <= "01";
									RegWrite <= "001"; 
									MemtoReg <= "00" ;
								when others =>
									null ;
							end case ;
						when "11101" =>
							case instructions(4 downto 0) is
								when "01101" =>		------------OR
									RegDst <= "00";
									RegWrite <= "001";
									MemtoReg <= "00" ;
								when others =>
									null ;
							end case ;
						when others =>
							null ;
					end case ;
					state <= instruction_fetch ;
			end case;
		end if ;
	end process;

end Behavioral;
