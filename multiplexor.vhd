---------------------------------------------------
-- Simple multiplexor Module (ESD boclick Figure 2.5)		
-- by Weijun Zhang, 04/2001
--
-- multiplexor stands for arithmatic logic unit.
-- It perform multiple operations according to 
-- the control bits.
-- we use 2's complement subraction in this example
-- two n-bit inputs
---------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 
---------------------------------------------------
entity multiplexor is
port(	  input_1:	in std_logic_vector(15 downto 0);--MSB of A,B are sign bits.
		  input_2:	in std_logic_vector(15 downto 0);
		  control_signal: in std_logic;
		  output: out std_logic_vector(15 downto 0)--make sure the input is finished;
);

end multiplexor;

---------------------------------------------------

architecture behv of multiplexor is
begin
	process(input_1,input_2,control_signal)
    begin
        case control_signal is
            when '1' =>    output <= input_2;
			   when others =>	output <= input_1;
        end case;
    end process;
end behv;
