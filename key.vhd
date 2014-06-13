library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity key is
    generic(
            maxLen : integer := 7;
            maxSize : integer := 255
    );
    port(
            clock : in std_logic;
            mode : in std_logic;
            reset : in std_logic;
            index : in std_logic_vector(maxLen downto 0);
            inValue : in std_logic_vector(maxLen downto 0);
            
            outValue : out std_logic_vector(maxLen downto 0)
    );
end key;

architecture Behavioral of key is

type Arr is array (255 downto 0) of std_logic_vector(maxLen downto 0);
shared variable key : Arr:=(others =>(others => '0'));

begin
    process (index, clock)
    begin
        if rising_edge(clock) then--bez tego caly czas wyrzucalo warningi, teraz powinien bez straty ogolnosci robic to zawsze jak zegar idzie na 1 -> ma wzwod :P
            if (reset = '1') then--jezeli byl reset
                key := (others =>(others => '0'));
            elsif (mode = '0') then--pisanie
                key(conv_integer(unsigned(index))) := inValue;
            elsif (mode = '1') then--czytanie
                outValue <= key(conv_integer(unsigned(index)));
            end if;
        end if;
    end process;
    
end Behavioral;

