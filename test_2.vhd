--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:05:32 05/24/2018
-- Design Name:   
-- Module Name:   /home/rani/Desktop/VHDL/TransmisorSerie/test_2.vhd
-- Project Name:  TransmisorSerie
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: transmisor
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
 
ENTITY test_2 IS
END test_2;
 
ARCHITECTURE behavior OF test_2 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT transmisor2
    PORT(
         BAUD_SELEC_IN : IN  std_logic_vector(1 downto 0);
         DATA_IN : IN  std_logic_vector(7 downto 0);
         BTN_IN : IN  std_logic;
         clk : IN  std_logic;
         a_reset : IN  std_logic;
         TX_out : OUT  std_logic;
         TX_ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal BAUD_SELEC_IN : std_logic_vector(1 downto 0) := (others => '0');
   signal DATA_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal BTN_IN : std_logic := '0';
   signal clk : std_logic := '0';
   signal a_reset : std_logic := '0';

 	--Outputs
   signal TX_out : std_logic;
   signal TX_ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 100 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: transmisor2 PORT MAP (
          BAUD_SELEC_IN => BAUD_SELEC_IN,
          DATA_IN => DATA_IN,
          BTN_IN => BTN_IN,
          clk => clk,
          a_reset => a_reset,
          TX_out => TX_out,
          TX_ready => TX_ready
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
       a_reset <= '1';
      wait for 100 ns;	
      a_reset <= '0';
      BAUD_SELEC_IN <= "10";
      DATA_IN <= "11110001";
      BTN_IN <= '0';
      wait for 60 ns;
      BTN_IN <= '1';
      wait for clk_period;
      BTN_IN <= '0';
      wait for clk_period*1000;
      -- insert stimulus here 

      wait;
   end process;

END;
