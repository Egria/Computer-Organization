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
			  state_code: out std_logic_vector(3 downto 0)
);
end Controler_seven;

architecture Behavioral of Controler_seven is

signal bzero : std_logic ;
type controler_state is (instruction_fetch,decode,execute,mem_control,write_reg,interrupt);
signal last_instruction: STD_LOGIC_VECTOR (15 downto 0);
signal state : controler_state;
signal is_jumped: std_logic;
begin

	

--	process(rst,bZero_Ctrl)
--	begin
--		if rst = '0' then
--			bzero <= '0' ;
--		elsif rising_edge(bZero_Ctrl) then
--			if bzero = '0' then
--				bzero <= '1' ;
--			elsif bzero = '1' then
--				bzero <= '0' ;
--			end if ;
--		end if ;
--	end process;
	
	
	process(rst,clk,bZero_Ctrl)
	begin
		if(rst = '0') then
			PCWriteCond<='0';
			is_jumped<='0';
			state <= instruction_fetch;
			state_code <= "0000"; --IF
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
		elsif(is_jumped='0' and state=instruction_fetch and bZero_Ctrl='1' and last_instruction(15 downto 11)="00100") then
			PCSource <= '1' and bzero_Ctrl;
			PCWriteCond<=bZero_Ctrl;
			is_jumped<='1';
		elsif falling_edge(clk) then
			case state is
				when instruction_fetch =>
					MemRead <= '1' ;
					ALUSrcA <= '0' ;
					IorD <= '0' ;
					is_jumped<='0';
					ALUSrcB <= "01" ;
					ALUOp <= "0000";
					PCWrite <= '1' ;
					PCSource <= '0' ;
					IRWrite <= '1' ;
					RegWrite <= "000" ;
					state <= decode ;
					MemtoReg <= "00";
					PCWriteCond<='0';
					state_code <= "0001" ; --DE
				when decode =>
					MemRead <='0';
					PCWrite <='0';
					MemtoReg <= "00";
					ALUSrcA<='0';
					ALUSrcB<="10";
					SE<='0';
					ALUOp<="0000";
					state <= execute ;
					state_code <= "0010"; --EXE
				when execute =>
					IRWrite <= '0';
					last_instruction<=instructions;
					case instructions(15 downto 11) is 
						when "00001" =>                         -------------Temporarily NOP
							case instructions(10 downto 0) is 
								when "00000000000" =>   -------------NOP
									state<=instruction_fetch;
									state_code<="0000"; --IF
								when others=>
									null;
							end case;
						when "00100" =>				-------------BEQZ
							
							ALUSrcA <= '1';
							ALUOp <= "1010";
							state <= instruction_fetch ;
							state_code <= "0000" ; --IF
						when "10011" =>				-------------LW	
							ALUSrcA <= '1' ;
							ALUSrcB <= "10" ;
							ALUOp <= "0000" ;
							SE<='1';
							state <= mem_control ;
							state_code <= "0011" ; --MEM
						when "11011" =>				-------------SW	
							ALUSrcA <= '1';
							ALUSrcB <= "10" ;
							ALUOp <= "0000" ;
							SE<='1';
							state <= mem_control ;
							state_code <= "0011"; --MEM
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
							state_code <= "0100"; --WB
						when "11101" =>
							case instructions(4 downto 0) is
								when "01101" =>		------------OR
									ALUSrcA <= '1';
									ALUSrcB <= "00";
									ALUOp <= "0011";
									state <= write_reg ;
									state_code <= "0100" ; --WB
								when "01110" =>		------------XOR
									ALUSrcA <= '1';
									ALUSrcB <= "00";
									ALUOp <= "0100";
									state <= write_reg ;
									state_code <= "0100" ; --WB

								when "00000" =>
									case instructions(7 downto 5) is
										when "000" =>	------------JR
											ALUSrcA<='1';
											ALUOp<="1010";
											PCWrite <= '1';
											PCSource <= '0' ;
											state <= instruction_fetch ;
											state_code <= "0000"; --IF
										when others =>
											null ;
									end case ;
								when others =>
									null ;
							end case ;
						when "11111" => 				-------------INT
							state <= interrupt;
							state_code <= "1111";
						when others =>
									state <= instruction_fetch ;
									state_code <= "0000"; --IF
					end case ;
				when mem_control =>
					PCWrite <= '0' ;
					RegWrite <= "000" ;
					case instructions(15 downto 11) is 
						when "10011" =>				-------------LW	
							MemRead <= '1' ;
							IorD <= '1' ;
							state <= write_reg ;
							state_code <= "0100"; --WB
						when "11011" =>				-------------SW	
							MemWrite <= '1' ;
							IorD <= '1' ;
							state <= write_reg ;
							state_code <= "0100"; --WB
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
								when "01110" =>
									RegDst <= "00";
									RegWrite <= "001";
									MemtoReg <= "00" ;-------XOR
									
								when others =>
									null ;
							end case ;
						when others =>
							null ;
					end case ;
					state <= instruction_fetch ;
					state_code <="0000"; --IF
				when interrupt =>
					state<=interrupt;
					state_code<="1111";
			end case;
		end if ;
	end process;

end Behavioral;
