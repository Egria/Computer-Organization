---------------------------------------------------
-- Simple multiplexor_two_bit Module (ESD boclick Figure 2.5)		
-- by Weijun Zhang, 04/2001
--
-- multiplexor_two_bit stands for arithmatic logic unit.
-- It perform multiple operations according to 
-- the control bits.
-- we use 2's complement subraction in this example
-- two n-bit inputs
---------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 
---------------------------------------------------
entity multiplexor_two_bit is
generic(n:natural:=16);
port(	  input_1:	in std_logic_vector(n-1 downto 0);--MSB of A,B are sign bits.
		  input_2:	in std_logic_vector(n-1 downto 0);
		  input_3:  in std_logic_vector(n-1 downto 0);
		  control_signal: in std_logic_vector(1 downto 0);
		  output: out std_logic_vector(n-1 downto 0)--make sure the input is finished;
);

end multiplexor_two_bit;

---------------------------------------------------

architecture behv of multiplexor_two_bit is
begin
	process(input_1,input_2,input_3,control_signal)
    begin
        case control_signal is
            when "01" =>    output <= input_2;
				when "10" => output<= input_3;
			   when others =>	output <= input_1;
        end case;
    end process;
end behv;
