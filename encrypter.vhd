library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;


--Component's task is to encrypt given input text with given key
--Input:
--*clock - bity zegara
--*KeyS - flaga klucza
--*TxtS - flaga tekstu
--*Input - bity klucza/tekstu
--Output:
--*Busy - trwa przeliczanie
--*OutReady - zakonczlo sie przeliczanie
--*Output - bity wyjscia - szyfrogramu

entity encrypter is
	generic (maxLen: integer := 7;
                io_period : integer := 9
            );
	port(
		clock: in std_logic;--0/1, zegar
		KeyS: in std_logic;--0/1, rozpoczyna przessylanie klucza
		TxtS: in std_logic;--0/1, rozpoczyna przesylanie tekstu
		Input: in std_logic_vector(maxLen downto 0);--8 bitowe wejscie (klucz/plaintext)
		
		Busy: out std_logic;--0/1, jezeli 1 to trwa przeliczanie
		OutReady: out std_logic;--0/1, przeliczanie sie zakonczylo
		Output: out std_logic_vector(maxLen downto 0)--8 bitowe wyjscie (szyfrogram)
	);
end encrypter;

architecture Behavioral of encrypter is
type state is (INIT, READ_KEY, KSA, IN_PROCESS, ARRRESET);
signal next_state, c_state: state;
--Sygnaly obslugujace pamiec na klucz
signal keyMode : std_logic;
signal keyReset : std_logic;
signal keyInValue : std_logic_vector(maxLen downto 0);
signal keyOutValue : std_logic_vector(maxLen downto 0);
signal keyIndex : std_logic_vector(maxLen downto 0);
--Syganly obslugujace s-block'a
signal sblockMode : std_logic;
signal sblockReset : std_logic;
signal sblockInValue : std_logic_vector(maxLen downto 0);
signal sblockOutValue : std_logic_vector(maxLen downto 0);
signal sblockIndex : std_logic_vector(maxLen downto 0);
--Sygnaly wewnetrzne
shared variable busy_internal: boolean;
--Zmienne obslugujace rejestry wew i pobor danych
--type Arr is array (255 downto 0) of std_logic_vector(maxLen downto 0);
--shared variable key : Arr:=(others =>(others => '0'));
--shared variable S : Arr:=(others =>(others => '0')); 
shared variable iter: integer:= 0;
--Zmienne potrzebne do KSA
shared variable i: integer := 0;
shared variable j: integer := 0;
shared variable temp: std_logic_vector(maxLen downto 0);
--Zmienna sterujaca czasem
shared variable clocks : integer := 0;

begin

    key : entity WORK.key generic map(maxLen => maxLen)
                            port map(clock=>clock, inValue=>keyInValue, outValue=>keyOutValue, index=>keyIndex, reset=>keyReset, mode=>keyMode);
                            
    sblock : entity WORK.sblock generic map(maxLen => maxLen)
                            port map(clock=>clock, valueIn=>sblockInValue, valueOut=>sblockOutValue, index=>sblockIndex, reset=>sblockReset, mode=>sblockMode);

	state_manager : process(clock, KeyS, TxtS, c_state, Input)--zarzadza stanami w komponencie
	begin
        if (rising_edge(clock)) then
            Busy <= '0';
            OutReady <= '0';
            Output <= "00000000";
            next_state <= ARRRESET;--na poczatku wszystko w outpucie jest rowne 0, oraz stan poczatkowy to INIT
            
            case c_state is
            
                when INIT =>--jezeli nic nie robil
                    if (KeyS = '1' and TxtS = '0') then--i dostal sygnal do czytania klucza
                        next_state <= READ_KEY;
                        --czytaj klucz
                    elsif (KeyS = '0' and TxtS = '1') then--i dostal sygnal do cztyania tesktu
                        next_state <= ARRRESET;
                        busy_internal := False;
                        --czekaj az ktos poda klucz
                    else
                        next_state <= ARRRESET;--w przeciwnum razie sa 2 sytuacje
                        --1 - oba maja stan 0, wtedy nic nie rob 
                        --2 - oba maja stan 1, wtedy dajemy reset! i wszystko 
                        busy_internal := False;
                    end if;
                    
                when READ_KEY =>--jezeli czytasz klucz
                    if (KeyS = '1' and TxtS = '0') then--to dopoki sie nie zmieni flaga - czytaj
                        if (iter > 255 ) then
                            next_state <= KSA;
                            busy_internal := True;--ustaw ze jestes zajety
                        else
                            --####################save data in array
                            if(clocks > io_period) then
                                clocks := 0;
                            else
                                if (clocks = 0) then
                                    --key(iter) := Input;
                                    keyMode <= '0';
                                    keyIndex <= conv_std_logic_vector(iter, 8);
                                    keyInValue <= Input;
                                    iter := iter + 1;
                                end if;
                                clocks := clocks + 1;
                            end if;
                            --####################save data in array end
                            next_state <= READ_KEY;
                        end if;
                    elsif (KeyS = '0' and TxtS = '1') then
                        busy_internal := True;
                        next_state <= KSA;
                        
                    elsif (KeYS = '0' and TxtS = '0') then
                        busy_internal := True;
                        next_state <= KSA;
                    else
                        next_state <= ARRRESET;
                        busy_internal := False;
                    end if;
                    
                when KSA =>
                    --#KSA#######################################################
                    sblockMode <= '0';
                    for i in 0 to 255 loop
                        --S(i) := conv_std_logic_vector(i, 8);
                        sblockIndex <= conv_std_logic_vector(i, 8);
                        sblockInValue <= conv_std_logic_vector(i, 8);
                    end loop;
                    j := 0;
                    for i in 0 to 255 loop
                        --j := (j + conv_integer(unsigned(S(i))) + conv_integer(unsigned(key(i mod iter)))) mod 256;
                        --temp := S(j);
                        --S(j) := S(i);
                        --S(i) := temp;
                        --Output <= S(i);
                        sblockMode <= '1';
                        sblockIndex <= conv_std_logic_vector(i, 8);--jak wysle to to w sblockOutValue powinienem dostac wartosc(chyba)
                        keyMode <= '1';
                        keyIndex <= conv_std_logic_vector((i mod iter), 8);
                        j := (j + conv_integer(unsigned(sblockOutValue)) + conv_integer(unsigned(keyOutValue))) mod 256;
                        temp := sblockOutValue;
                        sblockMode <= '0';
                        sblockIndex <= conv_std_logic_vector(j, 8);
                        sblockInValue <= sblockOutValue;
                        sblockIndex <= conv_std_logic_vector(i, 8);
                        sblockInValue <= temp;--jezeli to tak bedzie dzialalo jak tu napisalem to bedzie bosko :P
                    end loop;
                    --#KSA End##################################################
                    Busy <= '0';
                    busy_internal := FAlSe;
                    next_state <= IN_PROCESS;--przejdz do nastepnego stanu po wykonaniu ksa
                    iter := 0;
                    clocks := 0;
                    
                when IN_PROCESS =>
                    if (KeyS = '1' and TxtS = '1') then--jezeli oba ustawione to 
                        next_state <= ARRRESET;--reset
                        busy_internal := False;
                    elsif (KeyS = '1' and TxtS = '0') then--jezeli ustawione czytanie kluczt
                        next_state <= ARRRESET;--to czytaj klucz
                    elsif (KeyS = '0' and TxtS = '1') then--jezeli ustawione czytanie tekstu
                        if (clocks > io_period) then
                            clocks := 0;--calkiem koniec
                        elsif (clocks > 0) then
                            if (clocks = 2) then
                                OutReady <= '0';--koniec wzniesienia
                            end if;
                            clocks := clocks + 1;
                        else
      --                      Output <= (Input xor S(iter));--XOR
                            iter := (iter + 1) mod 256;
                            OutReady <= '1';
                            clocks := clocks + 1;
                        end if;
                        next_state <= IN_PROCESS;--to czytaj tekst
                    else--jezeli oba byly  = 0 to reset
                        next_state <= IN_PROCESS;
                        busy_internal := False;
                    end if;
                    
                when ARRRESET =>
                    iter := 0;
                    clocks := 0;
     --               key :=(others =>(others => '0'));
     --               S :=(others =>(others => '0'));
                    
                    Busy <= '1';
                    OutReady <= '0';
                    next_state <= INIT;
                    
                when others =>
                    next_state <= ARRRESET;
                    
            end case;
            if (busy_internal = True) then
                Busy <= '1';
            else
                Busy <= '0';
            end if;
        end if;
	end process;
    
    state_register : process (clock)
	begin
		if (clock' event and clock='1') then
			c_state <= next_state;
		end if;
		
	end process;
  
end Behavioral;