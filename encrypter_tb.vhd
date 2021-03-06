--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:36:22 06/15/2014
-- Design Name:   
-- Module Name:   C:/Users/Filip/Documents/Rc4-VHDL/rc4_vhdl_2/encrypter_tb.vhd
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
 
ENTITY encrypter_tb IS
END encrypter_tb;
 
ARCHITECTURE behavior OF encrypter_tb IS 
 
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
TxtS<= '1';
KeyS<='1';
      wait for clock_period*10;
TxtS<= '0';
KeyS<='0';
      wait for clock_period*10;

      -- insert stimulus here 
	KeyS <= '1';
	Input <= "01010000";--P
 	wait for clock_period*10;
	Input <= "01010010";--r
	wait for clock_period*10;
Input <= "01001111";--o
wait for clock_period*10;
Input <= "01010011";--s
wait for clock_period*10;
Input <= "01001001";--i
wait for clock_period*10;
Input <= "01001101";--m
wait for clock_period*10;
Input <= "01011001";--y
wait for clock_period*10;
Input <= "00100001";--!
wait for clock_period*10;
KeyS<='0';

wait for clock_period*2000;

TxtS<='1';
Input <= "01010000";--P
wait for clock_period*22;
Input <= "01000001";--a
wait for clock_period*22;
Input <= "01001110";--n
wait for clock_period*22;
Input <= "01000100";--d
wait for clock_period*22;
Input <= "01000001";--a
wait for clock_period*22;
Input <= "00100000";-- 
wait for clock_period*22;
Input <= "00110101";--5
wait for clock_period*22;
Input <= "00100001";--!
wait for clock_period*22;      
TxtS <= '0';

      wait;
   end process;

END;
