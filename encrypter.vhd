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
                io_period : integer := 8;
                maxSize : integer := 255
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
type state is (INIT, READ_KEY, KSA1, KSA2, IN_PROCESS, ARRRESET);
shared variable next_state, c_state: state;
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
--Zmienna sterujaca czasemzx
shared variable clocks : integer := 0;

begin

    key : entity WORK.memBlock generic map(maxLen => maxLen,maxSize =>maxSize)
                            port map(clock=>clock, inValue=>keyInValue, outValue=>keyOutValue, index=>keyIndex, reset=>keyReset, mode=>keyMode);
                            
    sblock : entity WORK.memBlock generic map(maxLen => maxLen,maxSize =>maxSize)
                            port map(clock=>clock, inValue=>sblockInValue, outValue=>sblockOutValue, index=>sblockIndex, reset=>sblockReset, mode=>sblockMode);

	state_manager : process(clock, KeyS, TxtS, Input)--zarzadza stanami w komponencie
	begin
        if (rising_edge(clock)) then
            --next_state := ARRRESET;--na poczatku wszystko w outpucie jest rowne 0, oraz stan poczatkowy to INIT
            
            case c_state is
            
                when INIT =>--jezeli nic nie robil
                    --Output <= conv_std_logic_vector(7, 8);
                    if (KeyS = '1' and TxtS = '0') then--i dostal sygnal do czytania klucza
                        next_state := READ_KEY;
                        --czytaj klucz
                    elsif (KeyS = '0' and TxtS = '1') then--i dostal sygnal do cztyania tesktu
                        next_state := ARRRESET;
                        --czekaj az ktos poda klucz
                    else
                        next_state := ARRRESET;--w przeciwnum razie sa 2 sytuacje
                        --1 - oba maja stan 0, wtedy nic nie rob 
                        --2 - oba maja stan 1, wtedy dajemy reset! i wszystko 
                    end if;
                    
                when READ_KEY =>--jezeli czytasz klucz
                    --Output <= conv_std_logic_vector(2, 8);
                    if (KeyS = '1' and TxtS = '0') then--to dopoki sie nie zmieni flaga - czytaj
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
                                    Output <= conv_std_logic_vector(iter, 8);
                                end if;
                                clocks := clocks + 1;
                            end if;
                            --####################save data in array end
                            if (iter = 256 ) then
                                next_state := KSA1;
                                clocks := 0;
                                busy_internal := True;--ustaw ze jestes zajety
                                --Busy <= '1';
                            else
                                next_state := READ_KEY;
                            end if;
                    elsif (KeyS = '0' and TxtS = '1') then
                        busy_internal := True;
                        next_state := KSA1;
                        clocks := 0;
                        
                    elsif (KeYS = '0' and TxtS = '0') then
                        busy_internal := True;
                        next_state := KSA1;
                        clocks := 0;
                        Output <= conv_std_logic_vector(99, 8);
                    else
                        next_state := ARRRESET;
                    --    busy_internal := True;
                    end if;
                
                when KSA1 =>
                    --Output <= conv_std_logic_vector(3, 8);
                    --#KSA#######################################################
                    if (KeyS = '1' and TxtS = '1') then
                        next_state := ARRRESET;
                    else    
                        if (clocks < 256) then
                            --Output <= conv_std_logic_vector(clocks, 8);
                            if (clocks = 0) then
                                sblockMode <= '0';
                            end if;
                            sblockIndex <= conv_std_logic_vector(clocks, 8);
                            sblockInValue <= conv_std_logic_vector(clocks, 8);
                            clocks := clocks + 1;
                            next_state := KSA1;
                            Output <= "10101010";
                        else
                            clocks := 0;
                            j := 0;
                            i := 0;
                            next_state := KSA2;
                        end if;
                    end if;
                    
                    
                when KSA2 =>
                    --Output <= conv_std_logic_vector(21, 8);
                    if (KeyS = '1' and TxtS = '1') then
                        next_state := ARRRESET;
                    else 
                        --Output <= conv_std_logic_vector(22, 8);
                        if (clocks < 2048) then--1536 -> zapomnielismy zwiekszyc :P zmienilismy mod z 6 na 8 a tu nie
                            if ((clocks mod 8) = 0) then
                                --Output <= conv_std_logic_vector((clocks mod 5), 8);
                                sblockMode <= '1';--czytanie
                                sblockIndex <= conv_std_logic_vector(i, 8);
                                --Output <= conv_std_logic_vector(42, 8);
                                keyMode <= '1';
                                keyIndex <= conv_std_logic_vector((i mod iter), 8);
                            elsif ((clocks mod 8) = 2) then
                                --Output <= conv_std_logic_vector((clocks mod 5), 8);
                                --Output <= conv_std_logic_vector(23, 8);
                                j := (j + conv_integer(unsigned(sblockOutValue)) + conv_integer(unsigned(keyOutValue))) mod 256;
                                temp := sblockOutValue;  --temp := S[i] v
                            elsif ((clocks mod 8) = 3) then
                                --Output <= conv_std_logic_vector((clocks mod 5), 8);
                                sblockIndex <= conv_std_logic_vector(j, 8);  --sblockOut = S[j] v
                            elsif ((clocks mod 8) = 4) then
                                --Output <= conv_std_logic_vector((clocks mod 5), 8);
                                sblockMode <= '0';--chcemy zapisac v
                                sblockIndex <= conv_std_logic_vector(i, 8); -- S[i]
                            elsif ((clocks mod 8) = 6) then
                                sblockInValue <= sblockOutValue; --zapis do S[i] <= S[j] v
                            elsif ((clocks mod 8) = 7) then
                                --Output <= conv_std_logic_vector((clocks mod 5), 8);
                                sblockIndex <= conv_std_logic_vector(j, 8); --S[j]
                                sblockInValue <= temp;  --zapis S[j] <= S[i] v
                                i := i + 1;
                                Output <= conv_std_logic_vector(i, 8);
                            end if;
                            --#KSA End##################################################
                        
                            clocks := clocks + 1;
                            next_state := KSA2;
                        else
                            busy_internal := False;
                            iter := 0;
                            clocks := 0;
                            i := 0; --wyzerowanie przed procedura generowania klucza
                            j := 0;
                            next_state := IN_PROCESS;--przejdz do nastepnego stanu po wykonaniu ksa
                        end if;
                    end if;
                        
                when IN_PROCESS =>
                    --Output <= conv_std_logic_vector(4, 8);
                    if (KeyS = '1' and TxtS = '1') then--jezeli oba ustawione to 
                        next_state := ARRRESET;--reset
                    elsif (KeyS = '1' and TxtS = '0') then--jezeli ustawione czytanie klucza
                        next_state := ARRRESET;--to czytaj klucz
                    elsif (KeyS = '0' and TxtS = '1') then--jezeli ustawione czytanie tekstu
                        if (clocks > (io_period+12)) then
                            clocks := -1;--calkiem koniec
                        elsif (clocks > 11) then--(clocks > 12) then
                            if (clocks = 14) then
                                OutReady <= '0';--koniec wzwodu:P
                            end if;
                        elsif ((clocks mod 12) = 0) then--wejde tu z clocks = 12, a nie chce
                            i := (i + 1) mod 256;
                            sblockMode <= '1';
                            sblockIndex <= conv_std_logic_vector(i, 8);--S[i]
                            --Output <= conv_std_logic_vector(i, 8);--i
                        elsif ((clocks mod 12) = 2) then
                            j := (j + conv_integer(unsigned(sblockOutValue))) mod 256;--j = j + s[i] 0+2takty
                        elsif ((clocks mod 12) = 3) then
                            temp := sblockOutValue;  --temp := S[i] v
                            sblockIndex <= conv_std_logic_vector(j, 8);  --sblockOut = S[j] v
                        elsif ((clocks mod 12) = 4) then
                            sblockMode <= '0';--chcemy zapisac v
                            sblockIndex <= conv_std_logic_vector(i, 8); -- S[i] 
                        elsif ((clocks mod 12) = 6) then
                            sblockInValue <= sblockOutValue; --zapis do S[i] <= S[j] 0+2 takty
                        elsif ((clocks mod 12) = 7) then
                            sblockIndex <= conv_std_logic_vector(j, 8); --S[j]
                            sblockInValue <= temp;  --zapis S[j] <= S[i] v
                        elsif ((clocks mod 12) = 9) then
                            sblockMode <= '1';--czytamy
                            sblockIndex <= conv_std_logic_vector((conv_integer(unsigned(sblockOutValue)) + conv_integer(unsigned(temp)) mod 256),8); -- ostawienie indeksu odczytu
                        elsif ((clocks mod 12) = 11) then
                            Output <= (sblockOutValue xor Input);--XOR 0+2takty
                            OutReady <= '1';
                        end if;
                        
                        clocks := clocks + 1;
                        next_state := IN_PROCESS;--to czytaj tekst
                    else--jezeli oba byly = 0 to czekamy na nastepny
                        next_state := IN_PROCESS;
                        busy_internal := False;
                    end if;
                    
                when ARRRESET =>
                    Output <= conv_std_logic_vector(66, 8);
                    iter := 0;
                    clocks := 0;
                    i := 0;
                    j := 0;
                    --busy_internal := True;

                    --Busy <= '1';
                    --keyReset <= '1';
                    --sblockReset <= '1';
                    --OutReady <= '0';
                    Output <= "00000101";
                    next_state := INIT;
                    --busy_internal := False;
                    --Busy <= '0';
                    
                when others =>
                    --Output <= conv_std_logic_vector(6, 8);
                    next_state := ARRRESET;
                    
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
			c_state := next_state;
		end if;
		
	end process;
  
end Behavioral;


