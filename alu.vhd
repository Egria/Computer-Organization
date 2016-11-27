---------------------------------------------------
-- Simple ALU Module (ESD boclock Figure 2.5)		
-- by Weijun Zhang, 04/2001
--
-- ALU stands for arithmatic logic unit.
-- It perform multiple operations according to 
-- the control bits.
-- we use 2's complement subraction in this example
-- two n-bit inputs
---------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 
---------------------------------------------------
entity alu is
port(	  
	reset:		in std_logic;
	input_1:	in std_logic_vector(15 downto 0);--MSB of A,B are sign bits.
	input_2: in std_logic_vector(15 downto 0);
	Sel: in std_logic_vector(3 downto 0);
	Res:	out std_logic_vector(15 downto 0);
   Zero: out std_logic
);

end alu;

---------------------------------------------------

architecture behv of ALU is
          
begin
    
   process(input_1,input_2,Sel,reset)
   variable result_middle: std_logic_vector(15 downto 0);
	--variable Carry,OverFlow,Zero,Sign: std_logic;--carry flag bit,for unsigned used only

    begin
	 if (reset='0') then
          Res<=(input_1'range=>'0');
			 Zero<='0';
	 else
		case Sel is
					when "0000" =>--addition
						result_middle := std_logic_vector(unsigned(input_1)+unsigned(input_2));
					when "0001" => --substraction					
						result_middle := std_logic_vector(unsigned(input_1) +unsigned(not input_2)+1);
					when "0010" =>
						result_middle:= input_1 and input_2;
					when "0011" =>	 
						result_middle:= input_1 or input_2;
					when "0100" =>
						result_middle:= input_1 xor input_2;
					when "0101" =>
						result_middle:= not input_1;
					when "0110" =>--logic shift left
					   if(input_2=(input_2'range =>'0')) then
						result_middle := std_logic_vector(unsigned(input_1) sll 8);
					   else
						result_middle := std_logic_vector(unsigned(input_1) sll to_integer(unsigned(input_2)));
						end if;
					when "0111" =>--logic shift right
						result_middle := std_logic_vector(unsigned(input_1) srl to_integer(unsigned(input_2)));
					when "1000" =>--arithmetic shift right
						if(input_2=(input_2'range =>'0')) then
						result_middle :=std_logic_vector(SHIFT_RIGHT(signed(input_1),8));
						else
						result_middle :=std_logic_vector(SHIFT_RIGHT(signed(input_1),to_integer(signed(input_2))));
						end if;
					when "1001"=>--rotate left,B can be negative in two's complement;
						result_middle :=std_logic_vector(unsigned(input_1) rol to_integer(signed(input_2)));
					when "1100"=>--rotate left, Ry<<Rx
						result_middle :=std_logic_vector(unsigned(input_2) sll to_integer(signed(input_1)));
					when "1010"=>
						result_middle :=input_1;
					when "1011"=>
						result_middle :=input_2;
					when "1101"=>--CMP: 0 if equal, 1 if inequal
						if (input_1=input_2) then
							result_middle:="0000000000000000";
						else
							result_middle:="0000000000000001";
						end if;
					when "1110"=> --SLTU: 0 if larger or equal, 1 if smaller
						if (unsigned(input_1)<unsigned(input_2)) then
							result_middle:="0000000000000001";
						else
							result_middle:="0000000000000000";
						end if;
					when others =>	 
						result_middle := (input_1'range =>'0');
				end case;
				Res<=result_middle;
				if(result_middle=(input_1'range=>'0'))then
						Zero <= '1';
				else
						Zero <='0';
				end if;
		end if;
     end process;
	
end behv;
