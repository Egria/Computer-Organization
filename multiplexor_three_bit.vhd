---------------------------------------------------
-- Simple multiplexor_three_bit Module (ESD boclick Figure 2.5)		
-- by Weijun Zhang, 04/2001
--
-- multiplexor_three_bit stands for arithmatic logic unit.
-- It perform multiple operations according to 
-- the control bits.
-- we use 2's complement subraction in this example
-- two n-bit inputs
---------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 
---------------------------------------------------
entity multiplexor_three_bit is
generic(n:natural:=16);
port(	  input_1:	in std_logic_vector(n-1 downto 0);--MSB of A,B are sign bits.
		  input_2:	in std_logic_vector(n-1 downto 0);
		  input_3:  in std_logic_vector(n-1 downto 0);
		  input_4:  in std_logic_vector(n-1 downto 0);
		  input_5:  in std_logic_vector(n-1 downto 0);
		  control_signal: in std_logic_vector(2 downto 0);
		  output: out std_logic_vector(n-1 downto 0)--make sure the input is finished;
);

end multiplexor_three_bit;

---------------------------------------------------

architecture behv of multiplexor_three_bit is
begin
	process(input_1,input_2,input_3,input_4,control_signal)
    begin
        case control_signal is
            when "001" =>    output <= input_2;
				when "010" => output<= input_3;
				when "011" => output<= input_4;
				when "100" => output<= input_5;
			   when others =>	output <= input_1;
        end case;
    end process;
end behv;
