library ieee;
use ieee.std_logic_1164.ALL;
--use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.ALL;

entity tx_rx_agc is
	port (rx_data_in_I : in std_logic_vector(23 downto 0);
			rx_data_in_Q : in std_logic_vector(23 downto 0);
			clk_in : in std_logic;  -- 1.25 MHz
			tx_audio_in : in std_logic_vector(15 downto 0);
			tx : in std_logic;
			rx_data_out_I : out std_logic_vector(9 downto 0);
			rx_data_out_Q : out std_logic_vector(9 downto 0);
			tx_audio_out : out std_logic_vector(9 downto 0);
			rssi : out std_logic_vector(5 downto 0)
			);
end tx_rx_agc;

architecture tx_rx_agc_arch of tx_rx_agc is

signal Data_in_I_reg, Data_in_Q_reg : signed(23 downto 0);
signal Data_out_I_reg, Data_out_Q_reg : std_logic_vector(9 downto 0);

begin
	
	reg : process (clk_in)
	begin
		if clk_in'event and clk_in = '1' then
			if tx = '0' then 
				Data_in_I_reg <= signed(rx_data_in_I);
				Data_in_Q_reg <= signed(rx_data_in_Q);
				rx_data_out_I <= Data_out_I_reg;
				rx_data_out_Q <= Data_out_Q_reg;
			else
				Data_in_I_reg <= signed(tx_audio_in(15) & tx_audio_in(15) & tx_audio_in(15) & tx_audio_in(15) & tx_audio_in(15) & tx_audio_in & "000");
				Data_in_Q_reg <= to_signed(0,24);
				tx_audio_out <= Data_out_I_reg;
			end if;
		end if;
	end process;
	
	
	p0: process (clk_in)
	variable peak_a : integer range 0 to 22;
	variable agc_a : integer range 8 to 22 := 16;
	variable peak_b, peak_b_old : integer range 0 to 2047 := 0;
	variable agc_b : integer range 16 to 31 := 16;
	variable ticks : integer range 0 to 99999 := 0;
	constant timelim : integer := 3000;
	variable Data_out_I_t, Data_out_Q_t : signed(9 downto 0);

	begin
		if clk_in'event and clk_in = '1' then
			for n in 22 downto 0 loop
            if (Data_in_I_reg(23) = '0' and Data_in_I_reg(n) = '1') or
					(Data_in_I_reg(23) = '1' and Data_in_I_reg(n) = '0') or
               (Data_in_Q_reg(23) = '0' and Data_in_Q_reg(n) = '1') or
					(Data_in_Q_reg(23) = '1' and Data_in_Q_reg(n) = '0') then
					if n > peak_a then
						peak_a := n;
					end if;
               exit;
            end if;
         end loop;

			if agc_a < 21 and peak_b < to_integer(abs(Data_in_I_reg(agc_a + 3 downto agc_a - 8))) then
				peak_b := to_integer(abs(Data_in_I_reg(agc_a + 3 downto agc_a - 8)));
				if peak_b < to_integer(abs(Data_in_Q_reg(agc_a + 3 downto agc_a - 8))) then
					peak_b := to_integer(abs(Data_in_Q_reg(agc_a + 3 downto agc_a - 8)));
				end if;
			elsif	peak_b < to_integer(abs(Data_in_I_reg(23 downto 13))) then
				peak_b := to_integer(abs(Data_in_I_reg(23 downto 13)));
				if peak_b < to_integer(abs(Data_in_Q_reg(23 downto 13))) then
					peak_b := to_integer(abs(Data_in_Q_reg(23 downto 13)));
				end if;
			end if;				
				
			ticks := ticks + 1;
				
	      if peak_b - 20 > peak_b_old or 
				--peak_b > 500 or
				peak_a > agc_a + 1 or 
				ticks > timelim then
				
				if (peak_b > 761 and agc_a < 21) or peak_a > agc_a + 1 then
					agc_a := agc_a + 2;		-- -4
					agc_b := 31;				-- 1 + 15/16
			
				elsif peak_b > 721 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 16;		  		-- 1 			
				elsif peak_b > 681 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 17;		  		-- 1 + 1/16 			
				elsif peak_b > 645 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 18;		  		-- 1 + 2/16 			
				elsif peak_b > 613 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 19;		  		-- 1 + 3/16 			
				elsif peak_b > 584 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 20;		  		-- 1 + 4/16 			
				elsif peak_b > 557 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 21;		  		-- 1 + 5/16 			
				elsif peak_b > 533 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 22;		  		-- 1 + 6/16 			
				elsif peak_b > 511 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 23;		  		-- 1 + 7/16 			
				elsif peak_b > 490 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 24;		  		-- 1 + 8/16 			
				elsif peak_b > 471 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 25;		  		-- 1 + 9/16 			
				elsif peak_b > 454 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 26;		  		-- 1 + 10/16 			
				elsif peak_b > 438 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 27;		  		-- 1 + 11/16 			
				elsif peak_b > 423 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 28;		  		-- 1 + 12/16 			
				elsif peak_b > 409 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 29;		  		-- 1 + 13/16 			
				elsif peak_b > 395 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 30;		  		-- 1 + 14/16
				elsif peak_b > 383 and agc_a < 22 then
					agc_a := agc_a + 1; 		-- -2
					agc_b := 31;		  		-- 1 + 15/16 			
					
				elsif peak_b > 360 and agc_a > 7 then
					agc_b := 16;		  		-- 1 
				elsif peak_b > 340 and agc_a > 7 then
					agc_b := 17;				-- 1 + 1/16 => max 383
				elsif peak_b > 323 and agc_a > 7 then
					agc_b := 18;				-- 1 + 2/16
				elsif peak_b > 306 and agc_a > 7 then
					agc_b := 19;
				elsif peak_b > 292 and agc_a > 7 then
					agc_b := 20;
				elsif peak_b > 279 and agc_a > 7 then
					agc_b := 21;
				elsif peak_b > 266 and agc_a > 7 then
					agc_b := 22;
				elsif peak_b > 255 and agc_a > 7 then
					agc_b := 23;
				elsif peak_b > 245 and agc_a > 7 then
					agc_b := 24;
				elsif peak_b > 237 and agc_a > 7 then
					agc_b := 25;
				elsif peak_b > 227 and agc_a > 7 then
					agc_b := 26;
				elsif peak_b > 219 and agc_a > 7 then
					agc_b := 27;
				elsif peak_b > 211 and agc_a > 7 then
					agc_b := 28;
				elsif peak_b > 204 and agc_a > 7 then
					agc_b := 29;
				elsif peak_b > 198 and agc_a > 7 then
					agc_b := 30;
				elsif peak_b > 191 and agc_a > 7 then
					agc_b := 31;				-- 1 + 15/16
					
				elsif peak_b > 180 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 16;		  		-- 1 			
				elsif peak_b > 170 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 17;		  		-- 1 + 1/16 			
				elsif peak_b > 161 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 18;		  		-- 1 + 2/16 			
				elsif peak_b > 153 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 19;		  		-- 1 + 3/16 			
				elsif peak_b > 146 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 20;		  		-- 1 + 4/16 			
				elsif peak_b > 139 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 21;		  		-- 1 + 5/16 			
				elsif peak_b > 133 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 22;		  		-- 1 + 6/16 			
				elsif peak_b > 129 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 23;		  		-- 1 + 7/16 			
				elsif peak_b > 122 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 24;		  		-- 1 + 8/16 			
				elsif peak_b > 118 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 25;		  		-- 1 + 9/16 			
				elsif peak_b > 113 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 26;		  		-- 1 + 10/16 			
				elsif peak_b > 109 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 27;		  		-- 1 + 11/16 	
				elsif peak_b > 105 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 28;		  		-- 1 + 12/16 			
				elsif peak_b > 102 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 29;		  		-- 1 + 13/16 			
				elsif peak_b > 99 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 30;		  		-- 1 + 14/16 			
				elsif peak_b > 95 and agc_a > 8 then
					agc_a := agc_a - 1; 		-- +2
					agc_b := 31;		  		-- 1 + 15/16 	
					
				elsif peak_b < 96 and agc_a > 9 then 
					agc_a := agc_a - 2;		-- +4
					agc_b := 16;				-- 1
					
				elsif agc_a = 8 then 
					agc_b := 31;				
				end if;
				
				if peak_b > 766 then
					peak_b_old := to_integer(to_unsigned(peak_b, 12) srl 2 );  -- div by 4
				elsif peak_b > 383 then
					peak_b_old := to_integer(to_unsigned(peak_b, 9) srl 1 );  -- div by 2
				elsif peak_b > 191 then
					peak_b_old := peak_b;
				elsif peak_b > 95 then
					peak_b_old := to_integer(to_unsigned(peak_b, 9) sll 1 );  -- mult by 2
				else
					peak_b_old := to_integer(to_unsigned(peak_b, 9) sll 2 );  -- mult by 4
				end if;	
				
				rssi <= std_logic_vector(to_unsigned(agc_a,6));
				
				peak_a := 0;
				peak_b := 0;
				ticks := 0;
				
         end if;

			if agc_a < 9 then
				Data_out_I_t := Data_in_I_reg(9 downto 0);
				Data_out_Q_t := Data_in_Q_reg(9 downto 0);
			elsif (agc_a < 22) and (agc_a > 8) then
            Data_out_I_t := signed(Data_in_I_reg + signed(signed'("000000000000000000000001") sll (agc_a - 9)))(agc_a + 1 downto agc_a - 8);
				Data_out_Q_t := signed(Data_in_Q_reg + signed(signed'("000000000000000000000001") sll (agc_a - 9)))(agc_a + 1 downto agc_a - 8);
			else
            Data_out_I_t := signed(Data_in_I_reg + to_signed(8192,24))(23 downto 14);
				Data_out_Q_t := signed(Data_in_Q_reg + to_signed(8192,24))(23 downto 14);
			end if;
					
			Data_out_I_reg <= std_logic_vector(Data_out_I_t * to_signed(agc_b,6))(13 downto 4);
			Data_out_Q_reg <= std_logic_vector(Data_out_Q_t * to_signed(agc_b,6))(13 downto 4);
			
		end if;
	end process;    


end tx_rx_agc_arch;

library ieee;
use ieee.std_logic_1164.ALL;
--use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.ALL;

entity tx_rx_agc_bypass is
	port (rx_data_in_I : in std_logic_vector(23 downto 0);
			rx_data_in_Q : in std_logic_vector(23 downto 0);
			clk_in : in std_logic;  -- 1.25 MHz
			tx_audio_in : in std_logic_vector(15 downto 0);
			tx : in std_logic;
			rx_data_out_I : out std_logic_vector(9 downto 0);
			rx_data_out_Q : out std_logic_vector(9 downto 0);
			tx_audio_out : out std_logic_vector(9 downto 0);
			rssi : out std_logic_vector(4 downto 0)
			);
end tx_rx_agc_bypass;

architecture agcb_arch of tx_rx_agc_bypass is

begin

rx_data_out_I <= rx_data_in_I(12 downto 3);
rx_data_out_Q <= rx_data_in_Q(12 downto 3);
tx_audio_out <= tx_audio_in(9 downto 0);
rssi <= "00100";

end agcb_arch;