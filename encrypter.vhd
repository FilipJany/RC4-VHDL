library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

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
	generic (maxLen: integer := 7);
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
type state is (INIT, READ_KEY, KSA, IN_READY, IN_PROCESS);
signal next_state, c_state: state;

shared variable busy_internal: boolean;
type Arr is array (255 downto 0) of integer;
shared variable key : Arr;
shared variable S : Arr; 
shared variable iter: integer:= 0;
shared variable actualSign: integer;

procedure SaveData(inp:in integer) is
begin
	key(iter) := inp;
	iter := iter + 1;
end SaveData;

procedure KSA(dummy: in integer) is
variable i: integer;
variable j: integer;
begin
	for i in 0 to 255 loop
		S(i) := i;
	end loop;
	j := 0;
	for i in 0 to 255 loop
		j := (j + S(i) + key(i mod iter)) mod 256;
	end loop;
end KSA;

function to_uint(v: std_logic_vector) return integer is
begin
	if v'length = 0 then
		return 0;
	elsif v'length = 1 then
      return to_integer(unsigned(v));
	else
      return to_integer(signed(v));
   end if;
end;

begin
	state_manager : process(clock, KeyS, TxtS, c_state, Input)--zarzadza stanami w komponencie
	begin
		Busy <= '0';
		OutReady <= '0';
		Output <= "00000000";
		next_state <= INIT;--na poczatku wszystko w outpucie jest rowne 0, oraz stan poczatkowy to INIT
		
		case c_state is
		
			when INIT =>--jezeli nic nie robil
				iter := 0;
				if (KeyS = '1' and TxtS = '0') then--i dostal sygnal do czytania klucza
					next_state <= READ_KEY;
					--czytaj klucz
				elsif (KeyS = '0' and TxtS = '1') then--i dostal sygnal do cztyania tesktu
					next_state <= INIT;
					busy_internal := False;
					--czekaj az ktos poda klucz
				else
					next_state <= INIT;--w przeciwnum razie sa 2 sytuacje
					--1 - oba maja stan 0, wtedy nic nie rob 
					--2 - oba maja stan 1, wtedy dajemy reset! i wszystko 
					busy_internal := False;
				end if;
				
			when READ_KEY =>--jezeli czytasz klucz
				if (KeyS = '1' and TxtS = '0') then--to dopoki sie nie zmieni flaga - czytaj
					if (iter > 2 ) then
						next_state <= KSA;
						busy_internal := True;--ustaw ze jestes zajety
					else
						SaveData(to_uint(Input));
						next_state <= READ_KEY;
						--czytaj klucz
					end if;
				elsif (KeyS = '0' and TxtS = '1') then
					busy_internal := True;
					next_state <= KSA;
					
				elsif (KeYS = '0' and TxtS = '0') then
					busy_internal := True;
					next_state <= KSA;
				else
					next_state <= INIT;
					busy_internal := False;
				end if;
				
			when KSA =>
				KSA(0);
				Busy <= '0';
				next_state <= IN_READY;--przejdz do nastepnego stanu po wykonaniu ksa
				
			when IN_READY =>
				if (KeyS = '1' and TxtS = '1') then--jezeli oba ustawione to 
					next_state <= INIT;--reset
					busy_internal := False;
				elsif (KeyS = '1' and TxtS = '0') then--jezeli ustawione czytanie kluczt
					next_state <= READ_KEY;--to czytaj klucz
				elsif (KeyS = '0' and TxtS = '1') then--jezeli ustawione czytanie tekstu
					next_state <= IN_PROCESS;--to czytaj tekst
				else--jezeli oba byly  = 0 to reset
					next_state <= INIT;
					busy_internal := False;
				end if;
				
			when IN_PROCESS =>
				if (KeyS = '1' and TxtS = '1') then--jezeli oba ustawione to 
					next_state <= INIT;--reset
					busy_internal := False;
				elsif (KeyS = '1' and TxtS = '0') then--jezeli ustawione czytanie kluczt
					iter := 0;
					next_state <= READ_KEY;--to czytaj klucz
				elsif (KeyS = '0' and TxtS = '1') then--jezeli ustawione czytanie tekstu
					next_state <= IN_PROCESS;--to czytaj tekst
				else--jezeli oba byly  = 0 to reset
					next_state <= IN_READY;
				busy_internal := True;
				--czytaj dane
				--szyfruj dane
				busy_internal := False;
				end if;
				
		end case;
		if (busy_internal = True) then
			Busy <= '1';
		else
			Busy <= '0';
		end if;
	end process;
	
	state_register : process (clock)
	begin
		if (clock' event and clock='1') then
			c_state <= next_state;
		end if;
		
	end process;
  
end Behavioral;

