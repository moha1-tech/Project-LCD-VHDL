----------------------------------------------------------------------------------
-- Company: INPT
-- Engineer: Jamal KHALLAAYOUNE
-- 
-- Create Date:    17:50:29 24/03/2010 
-- Design Name: 
-- Module Name:    LCD_1 - Behavioral 
-- Project Name: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.LCD_Library.all;

entity LCD is generic(N: natural := 1);
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
end LCD;

architecture Behavioral of LCD is
type etat is (Repos, Clear_LCD, Position_LCD, Write_LCD);
signal etat_a, etat_f: etat; 
signal counter: integer range 0 to 2**21 - 1;
signal Raz_Counter_Sync: std_logic;
signal FlagInit, Temoin_f: std_logic;
signal i: natural range 1 to N+1;
signal var: std_logic_vector(7 downto 0);
signal Adresse_DD_RAM: std_logic_vector(7 downto 0);
signal Adr_DD_RAM: std_logic_vector(6 downto 0);
signal Ok_interval: boolean;
begin

SF_CE0 <= '1';		-- StrataFlash Disabled when SF_CE0 = 1 (Full access to LCD)
Ok_interval <= (Ligne = 1) or (Ligne = 2);
Adr_DD_RAM <= conv_std_logic_vector( (Position + (Ligne - 1)*64), 7);

process(RESET, CLK)
begin
if RESET = '1' then 	Raz_Counter_Sync <= '1';
							LCD_E <= '0';
							LCD_RS <= '0';
							LCD_RW<= '0';
							LCD_D <= "0011";
							FlagInit <= '0';
							etat_f <= Repos;	
							Temoin_f <= '0';
							i <= 1;							
elsif rising_edge(CLK) then
	if FlagInit = '0' then
		case counter is
			when 0		=>	Raz_Counter_Sync <= '0';
			when Time0	=>	LCD_E <= '1';			-- after 15ms = 750000 cycles: LCD_E = '1' & LCD_D = "0011";
			when Time1	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0' & LCD_D = "0011";
			when Time2	=>	LCD_E <= '1';			-- after 4.1 ms = 205000 cycles: LCD_E = '1' & LCD_D = "0011";
			when Time3	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0' & LCD_D = "0011";
			when Time4	=>	LCD_E <= '1';			-- after 100 µs = 5000 cycles: LCD_E = '1' & LCD_D = "0011";
			when Time5	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0' & LCD_D = "0011";
			when Time6	=>	LCD_D <= "0010";		-- after 40 µs = 2000 cycles: LCD_D = "0010";
			when Time7	=>	LCD_E <= '1';			-- after 4 cycles: LCD_E = '1' & LCD_D = "0010";
			when Time8	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0' & LCD_D = "0010";

			when Time9	=>	LCD_D <= "0010";		-- after 40 µs = 2000 cycles: MSB de Function_Set_0x28
			when Time10	=>	LCD_E <= '1';			-- after 4 cycles: LCD_E = '1'	
			when Time11	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0'
			when Time12	=>	LCD_D <= "1000";		-- After 1 µs = 50 cycles: LSB de Function_Set_0x28
			when Time13	=>	LCD_E <= '1';			-- after 4 cycles: LCD_E = '1' 
			when Time14	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0' 

			when Time15	=>	LCD_D <= "0000";		-- after 40 µs = 2000 cycles: MSB de Entry_Mode_Set_0x06
			when Time16	=>	LCD_E <= '1';			-- after 4 cycles: LCD_E = '1'	
			when Time17	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0'
			when Time18	=>	LCD_D <= "0110";		-- After 1 µs = 50 cycles: LSB de Entry_Mode_Set_0x06
			when Time19	=>	LCD_E <= '1';			-- after 4 cycles: LCD_E = '1' 
			when Time20	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0' 

			when Time21	=>	LCD_D <= "0000";		-- after 40 µs = 2000 cycles: MSB de Display_On_Off_0x0C
			when Time22	=>	LCD_E <= '1';			-- after 4 cycles: LCD_E = '1'	
			when Time23	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0'
			when Time24	=>	LCD_D <= "1100";		-- After 1 µs = 50 cycles: LSB de Display_On_Off_0x0C
			when Time25	=>	LCD_E <= '1';			-- after 4 cycles: LCD_E = '1' 
			when Time26	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0' 

			when Time27	=>	LCD_D <= "0000";		-- after 40 µs = 2000 cycles: MSB de Clear_Display_0x01
			when Time28	=>	LCD_E <= '1';			-- after 4 cycles: LCD_E = '1'	
			when Time29	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0'
			when Time30	=>	LCD_D <= "0001";		-- After 1 µs = 50 cycles: LSB de Clear_Display_0x01
			when Time31	=>	LCD_E <= '1';			-- after 4 cycles: LCD_E = '1' 
			when Time32	=>	LCD_E <= '0';			-- after 12 cycles: LCD_E = '0' 

			when Time33	=>	Raz_Counter_Sync <= '1';
								FlagInit <= '1';
			when others		=>	NULL;
		end case;
	else										-- FlagInit = '1': Phase d'initialisation passée
		case etat_a is
			when Repos			=>	Temoin_f <= '0';
										etat_f <= Clear_LCD;
			when Clear_LCD		=>	if ClearDisplay = '0' then etat_f <= Position_LCD;
										else	Raz_Counter_Sync <= '0';
											case Counter is
												when Temp1 	=>	LCD_RS <= '0';	LCD_RW <= '0'; LCD_E <= '0'; LCD_D <= "0000";  	-- MSB de Clear_Display_0x01
												when Temp2	=>	LCD_E <= '1';																	-- after 4 cycles: LCD_E = '1'	
												when Temp3	=>	LCD_E <= '0';																	-- after 12 cycles: LCD_E = '0'
												when Temp4	=>	LCD_D <= "0001";																	-- After 1 µs = 50 cycles: LSB de Clear_Display_0x01
												when Temp5	=>	LCD_E <= '1';																	-- after 4 cycles: LCD_E = '1' 
												when Temp6	=>	LCD_E <= '0';																	-- after 12 cycles: LCD_E = '0' 
												when Temp10	=>	Raz_Counter_Sync <= '1';	
																	etat_f <= Repos; 																	-- after 1.64 ms;
																	Temoin_f <= '1';
												when others	=> etat_f <= Clear_LCD;
											end case;
										end if;
			when Position_LCD	=>	if Ligne = 0 then etat_f <= Write_LCD;
										else Raz_Counter_Sync <= '0';
											case Counter is
												when Temp1 	=>	LCD_RS <= '0';	LCD_RW <= '0'; LCD_E <= '0'; 
																	LCD_D <= Adresse_DD_RAM(7 downto 4);  																-- MSB de Set_DD_RAM_Adresse
												when Temp2	=>	LCD_E <= '1';																	-- after 4 cycles: LCD_E = '1'	
												when Temp3	=>	LCD_E <= '0';																	-- after 12 cycles: LCD_E = '0'
												when Temp4	=>	LCD_D <= Adresse_DD_RAM(3 downto 0);																	-- After 1 µs = 50 cycles: LSB de Set_DD_RAM_Adresse
												when Temp5	=>	LCD_E <= '1';																	-- after 4 cycles: LCD_E = '1' 
												when Temp6	=>	LCD_E <= '0';																	-- after 12 cycles: LCD_E = '0' 
												when Temp7	=>	Raz_Counter_Sync <= '1';	etat_f <= Write_LCD;							-- after 40 µs
												when others	=> etat_f <= Position_LCD;
											end case;
										end if;
			when Write_LCD		=>	if i < N+1 then 
											case Counter is
												when 0		=>	Raz_Counter_Sync <= '0';
																	var <= conv_std_logic_vector(Character'pos(DisplayText(i)), var'length);	
												when Temp1 	=>	LCD_RS <= '1';	LCD_RW <= '0'; LCD_E <= '0'; 
																	LCD_D <= var(7 downto 4);  																-- MSB de Write_Data
												when Temp2	=>	LCD_E <= '1';																	-- after 4 cycles: LCD_E = '1'	
												when Temp3	=>	LCD_E <= '0';																	-- after 12 cycles: LCD_E = '0'
												when Temp4	=>	LCD_D <= var(3 downto 0);  															-- After 1 µs = 50 cycles: LSB de Write_Data
												when Temp5	=>	LCD_E <= '1';																	-- after 4 cycles: LCD_E = '1' 
												when Temp6	=>	LCD_E <= '0';																	-- after 12 cycles: LCD_E = '0' 
												when Temp7	=>	Raz_Counter_Sync <= '1';
																	i <= i + 1; etat_f <= Write_LCD;
												when others	=> etat_f <= Write_LCD;
											end case;
										else Temoin_f <= '1'; etat_f <= Repos; i <= 1;
										end if;					
			when others			=>	Temoin_f <= '1'; etat_f <= Repos;
		end case;
	end if;
end if;	
end process;

process(RESET, CLK)
begin
if RESET = '1' then	counter <= 0;
elsif rising_edge(CLK) then
	if Raz_Counter_Sync = '1' then counter <= 0;
	else counter <= counter + 1;
	end if;
end if;
end process;
												
process(CLK)
begin
if rising_edge(CLK) then	 
	if Ok_interval then Adresse_DD_RAM <= '1' & Adr_DD_RAM;
	else Adresse_DD_RAM <= (others => '0');
	end if;
end if;
end process;

etat_a <= etat_f;
Temoin <= Temoin_f;

end Behavioral;