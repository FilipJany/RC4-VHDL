library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

--Nowy pomysl, zrobic to jako tablica zadanych vectorow i przede wszystkim zrobic ja 1!
-- A oto moj pomysl


entity storage is
    generic(
                maxLen :integer := 7;
                maxSize : integer := 255
            );
    port(
            inVal: in std_logic_vector(maxLen downto 0);--wartosc wejsciowa
            arrayIndex: in integer;--aktualny index w tablicy
            workType: in std_logic;--0 -> pisanie, 1 -> czytanie
            resetArray: in std_logic;--zerowanie tablicy
            
            outVal: out std_logic_vector(maxLen downto 0)
         );
end storage;

architecture Behavioral of storage is

type Arr is array (maxSize downto 0) of std_logic_vector(maxLen downto 0);--definicja typu
shared variable arry : Arr;--zmienna typu Arr

begin
    process(arrayIndex, resetArray)
    begin
        if (workType = '0') then--pisz do tablicy
            arry(arrayIndex) := inVal;            
        elsif (workType = '1') then--czytaj z tablicy
            outVal <= arry(arrayIndex);
        elsif(resetArray = '1') then
            arry := (others =>(others => '0'));--zerowanie niewymienionych rekordow -> tutaj wszystkich
        end if;
    end process;
end Behavioral;

