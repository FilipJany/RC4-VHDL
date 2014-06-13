----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:43:55 06/13/2014 
-- Design Name: 
-- Module Name:    sblock - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity sblock is
        generic(
                    maxLen : integer := 7;
                    maxSize : integer := 255
        );
        port(
                    clock : in std_logic;
                    reset : in std_logic;
                    mode : in std_logic;
                    index : in std_logic_vector(maxLen downto 0);
                    valueIn : in std_logic_vector(maxLen downto 0);
                    
                    valueOut : out std_logic_vector(maxLen downto 0)
        );
end sblock;

architecture Behavioral of sblock is

type Arr is array (255 downto 0) of std_logic_vector(maxLen downto 0);
shared variable sblock : Arr:=(others =>(others => '0'));

begin
    process (index, clock)
    begin
        if rising_edge(clock) then--bez tego caly czas wyrzucalo warningi, teraz powinien bez straty ogolnosci robic to zawsze jak zegar idzie na 1 -> ma wzwod :P
            if (reset = '1') then--jezeli byl reset
                sblock := (others =>(others => '0'));
            elsif (mode = '0') then--pisanie
                sblock(conv_integer(unsigned(index))) := valueIn;
            elsif (mode = '1') then--czytanie
                valueOut <= sblock(conv_integer(unsigned(index)));
            end if;
        end if;
    end process;

end Behavioral;

