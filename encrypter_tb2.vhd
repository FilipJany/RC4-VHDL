--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   02:29:35 06/15/2014
-- Design Name:   
-- Module Name:   C:/Users/Filip/Documents/Rc4-VHDL/rc4_vhdl_2/encrypter_tb2.vhd
-- Project Name:  rc4_vhdl_2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: encrypter
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
 
ENTITY encrypter_tb2 IS
END encrypter_tb2;
 
ARCHITECTURE behavior OF encrypter_tb2 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT encrypter
    PORT(
         clock : IN  std_logic;
         KeyS : IN  std_logic;
         TxtS : IN  std_logic;
         Input : IN  std_logic_vector(7 downto 0);
         Busy : OUT  std_logic;
         OutReady : OUT  std_logic;
         Output : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal KeyS : std_logic := '0';
   signal TxtS : std_logic := '0';
   signal Input : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal Busy : std_logic;
   signal OutReady : std_logic;
   signal Output : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: encrypter PORT MAP (
          clock => clock,
          KeyS => KeyS,
          TxtS => TxtS,
          Input => Input,
          Busy => Busy,
          OutReady => OutReady,
          Output => Output
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
      wait for 100 ns;	

      wait for clock_period*10;

      -- insert stimulus here 
        --W 20355 ns konczy dla tego przypadku KSA
        KeyS <= '1';
        Input <= "01001011";--K
        wait for clock_period*10;
        Input <= "01100101";--e
        wait for clock_period*10;
        Input <= "01111001";--y
        wait for clock_period*10;
        
        KeyS<='0';

        wait for clock_period*2500;

        TxtS<='1';
        Input <= "01010000";--P
        wait for clock_period*22;
        Input <= "01101100";--l
        wait for clock_period*22;
        Input <= "01100001";--a
        wait for clock_period*22;
        Input <= "01101001";--i
        wait for clock_period*22;
        Input <= "01101110";--n
        wait for clock_period*22;
        Input <= "01110100";--t
        wait for clock_period*22;
        Input <= "01100101";--e
        wait for clock_period*22;
        Input <= "01111000";--x
        wait for clock_period*22;
        Input <= "01110100";--t
        wait for clock_period*22;
        TxtS <= '0';       
        
        
      wait;
   end process;

END;
