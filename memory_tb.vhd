--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:14:25 11/11/2016
-- Design Name:   
-- Module Name:   D:/14.7/controller_observer/memory_tb.vhd
-- Project Name:  controller_observer
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: memory
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY memory_tb IS
END memory_tb;
 
ARCHITECTURE behavior OF memory_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT memory
    PORT(
         address : IN  std_logic_vector(15 downto 0);
         data_in : IN  std_logic_vector(15 downto 0);
         data_out : OUT  std_logic_vector(15 downto 0);
         reset : IN  std_logic;
         clock : IN  std_logic;
         MemRead : IN  std_logic;
         MemWrite : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal address : std_logic_vector(15 downto 0) := (others => '0');
   signal data_in : std_logic_vector(15 downto 0) := (others => '0');
   signal reset : std_logic := '0';
   signal clock : std_logic := '0';
   signal MemRead : std_logic := '0';
   signal MemWrite : std_logic := '0';

 	--Outputs
   signal data_out : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memory PORT MAP (
          address => address,
          data_in => data_in,
          data_out => data_out,
          reset => reset,
          clock => clock,
          MemRead => MemRead,
          MemWrite => MemWrite
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
	   reset<='0';
		wait for 10 ns;
		reset<='1';
      -- hold reset state for 100 ns.
		address<="0000000000001000";
		data_in<="0000111100001111";
		MemRead<='0';
		MemWrite<='1';
		wait for 10 ns;
		address<="0000000000000100";
		data_in<="1111000000001111";
		MemRead<='0';
		MemWrite<='1';
		wait for 10 ns;
		address<="0000000000001000";
		MemRead<='1';
		MemWrite<='0';
		wait for 100 ns;	

      wait for clock_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
