--------------------------------------------------------------------------------
--INP Projekt 1 ----------------------------------------------------------------
--Autor: Dominik Hlaváč Ďurán -- xhlava42@stud.fit.vutbr.cz---------------------
--------------------------------------------------------------------------------

--------------Knižnice----------------------------------------------------------
library IEEE; -- použitie knižnice
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


--------------Entity------------------------------------------------------------
entity ledc8x8 is
port(                 
	SMCLK, RESET: in std_logic;
	ROW, LED: out std_logic_vector(0 to 7)
);
end entity;

-------------------Telo programu------------------------------------------------
-------------------Signaly------------------------------------------------------
architecture arch of ledc8x8 is
	signal mux: std_logic :='0';
	signal mux2: std_logic :='0';
	signal counter: std_logic_vector (7 downto 0) := (others =>'0');
	signal rows, leds: std_logic_vector(7 downto 0):= (others =>'0');
	signal delay: integer range 0 to 4000000 :=0;
	
begin
	smclkdiv: process(SMCLK, RESET)
	begin
		if RESET ='1' then
			counter <="00000000"; -- vynulujem counter
		elsif SMCLK'event and SMCLK = '1' then
			counter <=1+counter;
			if counter (7 downto 0) ="11111111" then --smclk/256
				mux <='1';
			else
				mux <='0';
			end if;
		end if;
	end process;
	
	scnddelay:process(SMCLK, RESET)
	begin
		if RESET ='1' then
			delay <=0; -- vynulujem counter
		else
		if SMCLK ='1' and SMCLK'event then
			if (delay =4000000) then
				mux2 <='1';
				delay <=4000000;
			else
				delay <=1+delay ;
			end if;
		end if;
		end if;
	end process;

	rotate: process(SMCLK,RESET,mux,rows)
	begin
		if RESET = '1' then
			rows <= "10000000"; -- prvy riadok
		elsif (SMCLK = '1' and SMCLK'event and mux = '1') then
			rows <=rows(0) & rows(7 downto 1); --konkatenancia
		end if;
		ROW <= rows;
	end process;
	
	show1 :process(rows, mux2)
	begin
		if mux2 = '0' then -- prvy znak
			case rows is
				when "10000000" => leds <= "00011111";
				when "01000000" => leds <= "01101111";
				when "00100000" => leds <= "01101111";
				when "00010000" => leds <= "01101111";
				when "00001000" => leds <= "00011111";
				when "00000100" => leds <= "11111111";
				when "00000010" => leds <= "11111111";
				when "00000001" => leds <= "11111111";
				when others     => leds <= "11111111";
			end case;
		else
			case rows is
				when "10000000" => leds <= "00011111";
				when "01000000" => leds <= "01101111";
				when "00100000" => leds <= "01101111";
				when "00010000" => leds <= "01100110";
				when "00001000" => leds <= "00010110";
				when "00000100" => leds <= "11110000";
				when "00000010" => leds <= "11110110";
				when "00000001" => leds <= "11110110";
				when others     => leds <= "11111111";
			end case;
		end if;
	end process;

	ROW <= rows;
	LED <= leds;
end arch;	
	
