LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
 
ENTITY key_tb IS
END key_tb;
 
ARCHITECTURE behavior OF key_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT key
    PORT(
         clock : IN  std_logic;
         mode : IN  std_logic;
         reset : IN  std_logic;
         index : IN  std_logic_vector(7 downto 0);
         inValue : IN  std_logic_vector(7 downto 0);
         outValue : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal mode : std_logic := '0';
   signal reset : std_logic := '0';
   signal index : std_logic_vector(7 downto 0) := (others => '0');
   signal inValue : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal outValue : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: key PORT MAP (
          clock => clock,
          mode => mode,
          reset => reset,
          index => index,
          inValue => inValue,
          outValue => outValue
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

      mode <= '0';--wpisz cos do tablicy
      for i in 0 to 10 loop
        index <= conv_std_logic_vector(i,8);
        inValue <= conv_std_logic_vector(i,8);
        wait for clock_period;
      end loop;
      
      wait for clock_period;
      reset <= '1';
      wait for clock_period;
      reset <= '0';
      wait for clock_period;
      
      for i in 0 to 3 loop
        index <= conv_std_logic_vector(i,8);
        inValue <= conv_std_logic_vector(i,8);
        wait for clock_period;
      end loop;
      
      mode <= '1';
      for i in 0 to 10 loop
        index <= conv_std_logic_vector(i,8);
        wait for clock_period;
--        assert(conv_std_logic_vector(i, 8) = outValue)
--            report "Wartosc jest inna!" severity failure;
      end loop;
      
      wait;
   end process;

END;
