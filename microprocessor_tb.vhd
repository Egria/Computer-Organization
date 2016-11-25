--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:11:34 11/12/2016
-- Design Name:   
-- Module Name:   D:/14.7/controller_observer/microprocessor_tb.vhd
-- Project Name:  controller_observer
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: microprocessor
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
 
ENTITY microprocessor_tb IS
END microprocessor_tb;
 
ARCHITECTURE behavior OF microprocessor_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT microprocessor
    PORT(
         clock : IN  std_logic;
         rst : IN  std_logic;
         data_bus_observer : OUT  std_logic_vector(15 downto 0);
					s6_out,s9_out,s14_out,s17_out: out std_logic_vector(15 downto 0);
         s4_out : OUT  std_logic_vector(15 downto 0);
         s15_out : OUT  std_logic_vector(15 downto 0);
         s7_out : OUT  std_logic_vector(15 downto 0);
         s1_out : OUT  std_logic_vector(15 downto 0);
         s2_out : OUT  std_logic_vector(15 downto 0);
         s3_out : OUT  std_logic_vector(15 downto 0);
         s8_out : OUT  std_logic_vector(15 downto 0);
         s10_out : OUT  std_logic_vector(15 downto 0);
         s11_out : OUT  std_logic_vector(15 downto 0);
         s12_out : OUT  std_logic_vector(15 downto 0);
         s13_out : OUT  std_logic_vector(15 downto 0);
         s16_out : OUT  std_logic_vector(2 downto 0);
			state_code: out std_logic_vector(3 downto 0);
			alu_zero_led:out std_logic;
					pc_write_condition:out std_logic;
			pc_write_observer: out std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal rst : std_logic := '0';

 	--Outputs
   signal data_bus_observer : std_logic_vector(15 downto 0);
   signal s4_out : std_logic_vector(15 downto 0);
   signal s15_out : std_logic_vector(15 downto 0);
   signal s7_out : std_logic_vector(15 downto 0);
   signal s1_out : std_logic_vector(15 downto 0);
   signal s2_out : std_logic_vector(15 downto 0);
   signal s3_out : std_logic_vector(15 downto 0);
   signal s8_out : std_logic_vector(15 downto 0);
   signal s10_out : std_logic_vector(15 downto 0);
   signal s11_out : std_logic_vector(15 downto 0);
   signal s12_out : std_logic_vector(15 downto 0);
   signal s6_out : std_logic_vector(15 downto 0);
   signal s9_out : std_logic_vector(15 downto 0);
   signal s14_out,s17_out : std_logic_vector(15 downto 0);

   signal s13_out : std_logic_vector(15 downto 0);
   signal s16_out : std_logic_vector(2 downto 0);
	signal state_code: std_logic_vector(3 downto 0);
	signal alu_zero_led:std_logic;
   signal 	pc_write_observer,pc_write_condition: std_logic;
   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: microprocessor PORT MAP (
          clock => clock,
          rst => rst,
          data_bus_observer => data_bus_observer,
          s4_out => s4_out,
          s15_out => s15_out,
          s7_out => s7_out,
          s1_out => s1_out,
          s2_out => s2_out,
          s3_out => s3_out,
          s8_out => s8_out,
          s10_out => s10_out,
          s11_out => s11_out,
          s12_out => s12_out,
          s6_out => s6_out,
          s9_out => s9_out,
          s14_out => s14_out,
			 s17_out =>s17_out,
          s13_out => s13_out,
          s16_out => s16_out,
			 state_code => state_code,
			 alu_zero_led => alu_zero_led,
			 pc_write_condition => pc_write_condition,
			 pc_write_observer=>pc_write_observer
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
      -- hold reset state for 100 ns.
		rst<='0';
      wait for 5 ns;	
		rst<='1';
		wait for 10 ns;
      -- insert stimulus here 

      wait;
   end process;

END;
