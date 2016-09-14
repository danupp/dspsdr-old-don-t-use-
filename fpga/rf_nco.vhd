library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.ALL;

entity rf_nco is
	port (freq_A : in std_logic_vector(24 downto 0);
			ADDR_B : out std_logic_vector(10 downto 0);
			ADDR_A : out std_logic_vector(12 downto 0);
			B_clk : in std_logic;
			A_clk : in std_logic;
			tx : in std_logic;
			if_freq : in std_logic;
			clar : in std_logic_vector(6 downto 0)
			);
end rf_nco;

architecture nco_arch of rf_nco is
signal reg0, reg0_buff : std_logic_vector(19 downto 0);
signal reg1, reg1_buff : std_logic_vector(24 downto 0);

begin
	
	p1 : process(B_clk)
	variable addnum : unsigned(19 downto 0);
	variable avgcount : integer range 0 to 15 := 0;
	
	begin
		if B_clk'event and B_clk = '1' then
			if tx = '1' then
				if if_freq = '1' then
					addnum := to_unsigned(393216,20);   -- 45.00000 MHz
				else
					addnum := to_unsigned(186996,20);   -- 21.40000 MHz - 6 Hz
				end if;
			else
				if if_freq = '1' then
					addnum := to_unsigned(390486,20);   -- 45.00000 MHz - 312.5 kHz - 38 Hz
				else
					addnum := to_unsigned(184265,20);   -- 21.40000 MHz - 312.5 kHz - 44 Hz
				end if; 
				if clar /= "0000000" then
					if clar(6) = '0' then
						addnum := addnum + unsigned(clar(5 downto 4));
					else
						addnum := addnum - 1 - unsigned(not(clar(5 downto 4)));
					end if;
					 
					if avgcount < to_integer(unsigned(clar(3 downto 0))) then 
						addnum := addnum + to_unsigned(1,20);
					end if;
					
					if avgcount < 15 then
						avgcount := avgcount + 1;
					else 
						avgcount := 0;
					end if;
				end if;
			end if;
			
			reg0 <= std_logic_vector(unsigned(reg0) + addnum);
			reg0_buff <= reg0;
			ADDR_B <= reg0_buff(19 downto 9);
		end if;	
	end process;
	
	p2 : process(A_clk)
	begin
		if A_clk'event and A_clk = '1' then
			reg1 <= std_logic_vector(unsigned(reg1) + unsigned(freq_A)); 
			reg1_buff <= reg1;
			ADDR_A <= reg1_buff(24 downto 12);
		end if;	
	end process;
		
	
		--reg0(20 downto 10) when reg0(21) = '0' else
			--	not(reg0(20 downto 10));
	
	
		--reg1(20 downto 10) when reg1(21) = '0' else
			--	not(reg1(20 downto 10));
		
	
end nco_arch;
