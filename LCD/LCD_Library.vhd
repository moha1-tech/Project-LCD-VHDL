
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package LCD_Library is

constant Cyc_12: natural := 12;
constant Cyc_4: natural := 3;
Constant T_40us: natural := 2000;					-- 40 µs
constant T_1us: natural := 50;						-- 1 µs
constant T_100us: natural := 5000;					-- 100 µs
constant T_4_1ms: natural := 205000;				-- 4.1 ms
constant T_1_64ms: natural := 82000;				-- 1.64 ms

constant Time0: natural := 750000;					-- 15 ms
constant Time1: natural := Time0 + Cyc_12;
constant Time2: natural := Time1 + T_4_1ms;
constant Time3: natural := Time2 + Cyc_12;
constant Time4: natural := Time3 + T_100us;
constant Time5: natural := Time4 + Cyc_12;
constant Time6: natural := Time5 + T_40us;
constant Time7: natural := Time6 + Cyc_4;
constant Time8: natural := Time7 + Cyc_12; 

constant Time9: natural := Time8 + T_40us;
constant Time10: natural := Time9 + Cyc_4;
constant Time11: natural := Time10 + Cyc_12;
constant Time12: natural := Time11 + T_1us; 
constant Time13: natural := Time12 + Cyc_4;
constant Time14: natural := Time13 + Cyc_12;

constant Time15: natural := Time14 + T_40us;
constant Time16: natural := Time15 + Cyc_4;
constant Time17: natural := Time16 + Cyc_12;
constant Time18: natural := Time17 + T_1us; 
constant Time19: natural := Time18 + Cyc_4;
constant Time20: natural := Time19 + Cyc_12;

constant Time21: natural := Time20 + T_40us;
constant Time22: natural := Time21 + Cyc_4;
constant Time23: natural := Time22 + Cyc_12;
constant Time24: natural := Time23 + T_1us; 
constant Time25: natural := Time24 + Cyc_4;
constant Time26: natural := Time25 + Cyc_12;

constant Time27: natural := Time26 + T_40us;
constant Time28: natural := Time27 + Cyc_4;
constant Time29: natural := Time28 + Cyc_12;
constant Time30: natural := Time29 + T_1us; 
constant Time31: natural := Time30 + Cyc_4;
constant Time32: natural := Time31 + Cyc_12;

constant Time33: natural := Time32 + T_1_64ms;

-- Pour la lecture du LSB
constant Temp1: natural := 4;
constant Temp2: natural := Temp1 + Cyc_4;
constant Temp3: natural := Temp2 + Cyc_12;
constant Temp4: natural := Temp3 + T_1us;
constant Temp5: natural := Temp4 + Cyc_4;
constant Temp6: natural := Temp5 + Cyc_12;
constant Temp7: natural := Temp6 + T_40us;
-- Pour la lecture du MSB
constant Temp8: natural := Temp5 + Cyc_4;
constant Temp9: natural := Temp8 + Cyc_4;
-- Pour le Clear
constant Temp10: natural := Temp5 + T_1_64ms;

constant Un_espace: 		string(1 to 1) 	:= " ";
constant Deux_espace: 	string(1 to 2) 	:= "  ";
constant Trois_espace: 	string(1 to 3) 	:= "   ";
constant Quatre_espace: string(1 to 4)		:= "    ";
constant Cinq_espace: 	string(1 to 5) 	:= "     ";
constant Six_espace: 	string(1 to 6) 	:= "      ";
constant Sept_espace: 	string(1 to 7) 	:= "       ";
constant Huit_espace: 	string(1 to 8) 	:= "        ";


type Tab_Hex_To_Char is array(0 to 15) of character;
constant Conv_Hex_To_Char: Tab_Hex_To_Char := ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');

function conv_string(N_Hexa: std_logic_vector; N_car: natural) return string;

component LCD is generic(N: natural := 1);
    Port ( RESET: in STD_LOGIC;
			  CLK: in STD_LOGIC;
			  ClearDisplay: in std_logic;
			  Ligne: in natural range 0 to 2;
			  Position: in natural range 0 to 15;
			  DisplayText: in string(1 to N);

			  Temoin: out std_logic;
			  LCD_D : out  STD_LOGIC_VECTOR (11 downto 8);
			  SF_CE0: out STD_LOGIC;			-- StrataFlash Disabled when SF_CE0 = 1 (Full access to LCD)
           LCD_E : out  STD_LOGIC;
           LCD_RS : out  STD_LOGIC;
           LCD_RW : out  STD_LOGIC
			  );
end component;
end LCD_Library;


package body LCD_Library is

function conv_string(N_Hexa: std_logic_vector; N_car: natural) return string is
variable Chiffre: std_logic_vector(3 downto 0);
variable Nb_Chiffre: natural;
variable Str: string(1 to N_car) := (others => ' ');
begin
	Nb_Chiffre := N_Hexa'length / 4;
			
	if Nb_Chiffre <= N_car then
			for i in 1 to Nb_Chiffre loop 
					Chiffre := N_Hexa(4*i-1 downto 4*i-4);
					str(N_car - i + 1) := Conv_Hex_To_Char(conv_integer(Chiffre));
			end loop;
	else	for i in 1 to N_car loop 
					Chiffre := N_Hexa(4*i-1 downto 4*i-4);
					str(N_car - i + 1) := Conv_Hex_To_Char(conv_integer(Chiffre));
			end loop;
	end if;
return str;
end conv_string;
 
end LCD_Library;
