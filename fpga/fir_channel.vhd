

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity fir_filt_channel is
	port (RX_Data_in_I : in std_logic_vector(23 downto 0);
			RX_Data_in_Q : in std_logic_vector(23 downto 0);
			TX_Data_in_I : in std_logic_vector(13 downto 0);
			TX_Data_in_Q : in std_logic_vector(13 downto 0);
			Data_out_I : out std_logic_vector(23 downto 0);
			Data_out_Q : out std_logic_vector(23 downto 0);
			clk_in : in std_logic; -- 40 MHz
			clk_sample : in std_logic; -- 40/(32*32) MHz
			ssb_am : in std_logic;
			wide_narrow : in std_logic;
			tx : in std_logic;
			filt_bypass : in std_logic;
			deb : out std_logic
			);
end fir_filt_channel;

architecture filter_arch of fir_filt_channel is
	
type longbuffer is array (0 to 260) of signed (23 downto 0);
type filt_type is array (0 to 126) of signed (23 downto 0);

signal data_in_buffer_I, data_in_buffer_Q : longbuffer;

constant weaver_wide_rx : filt_type :=
--Scilab:
--> [v,a,f] = wfir ('lp', 256, [1.55/40 0], 'hn', [0 0]);
--> round(v*2^27)
	("111111111111111111101000",
    "111111111111111101111101",
    "111111111111111010010110",
    "111111111111110100011101",
    "111111111111101100010001",
    "111111111111100010001100",
    "111111111111010111000101",
    "111111111111001100000111",
    "111111111111000010110110",
    "111111111110111101000011",
    "111111111110111100100101",
    "111111111111000011001111",
    "111111111111010010101000",
    "111111111111101011111010",
    "000000000000001111101110",
    "000000000000111101111111",
    "000000000001110101110101",
    "000000000010110101011111",
    "000000000011111010010110",
    "000000000101000000111010",
    "000000000110000100111111",
    "000000000111000001110011",
    "000000000111110010001111",
    "000000001000010001001000",
    "000000001000011001011111",
    "000000001000000110111101",
    "000000000111010110000010",
    "000000000110000100011101",
    "000000000100010001011011",
    "000000000001111101111001",
    "111111111111001100101101",
    "111111111100000010101011",
    "111111111000100110100001",
    "111111110101000000110010",
    "111111110001011011100011",
    "111111101110000010001001",
    "111111101011000000100111",
    "111111101000100011001111",
    "111111100110110101111100",
    "111111100110000011101010",
    "111111100110010101101010",
    "111111100111110010111101",
    "111111101010011111101101",
    "111111101110011100110010",
    "111111110011100111011000",
    "111111111001111000101111",
    "000000000001000110001101",
    "000000001001000001010010",
    "000000010001010111111111",
    "000000011001110101010111",
    "000000100010000010001001",
    "000000101001100101101010",
    "000000110000000110110110",
    "000000110101001101010010",
    "000000111000100010011010",
    "000000111001110010101010",
    "000000111000101110100100",
    "000000110101001011110111",
    "000000101111000110010011",
    "000000100110100000010011",
    "000000011011100011011111",
    "000000001110100000101111",
    "111111111111110000000011",
    "111111101111110000000110",
    "111111011111000101011010",
    "111111001110011001001110",
    "111110111110011000001010",
    "111110101111110000100001",
    "111110100011010000011011",
    "111110011001100011111110",
    "111110010011010011001001",
    "111110010000111111110011",
    "111110010011000011111011",
    "111110011001101111111000",
    "111110100101001001000011",
    "111110110101001000110111",
    "111111001001011100001000",
    "111111100001100010111110",
    "111111111100110001001001",
    "000000011010001111000001",
    "000000111000111010111101",
    "000001010111101011010000",
    "000001110101010000100000",
    "000010010000011000010101",
    "000010100111110000100000",
    "000010111010001010000111",
    "000011000110011100111011",
    "000011001011101010101100",
    "000011001001000010010000",
    "000010111110000010011001",
    "000010101010011100001111",
    "000010001110010101001001",
    "000001101010000111111011",
    "000000111110100101011111",
    "000000001100110100100011",
    "111111010110010000101110",
    "111110011100101000100111",
    "111101100001111011011000",
    "111100101000010101011010",
    "111011110010001100011010",
    "111011000001111011000011",
    "111010011001111100000111",
    "111001111100100101011011",
    "111001101100000010110101",
    "111001101010010001000101",
    "111001111000111001001010",
    "111010011001001011111010",
    "111011001011111110011100",
    "111100010001100111000001",
    "111101101001111011001001",
    "111111010100001110010010",
    "000001001111010001111001",
    "000011011001010110010110",
    "000101110000001100111000",
    "001000010001001010110001",
    "001010111001001101001111",
    "001101100100111110001111",
    "010000010000111010000010",
    "010010111001010101010000",
    "010101011010100011001110",
    "010111110000111100100001",
    "011001111001000101100011",
    "011011101111110100101101",
    "011101010010011000001011",
    "011110011110011011000011",
    "011111010010001001101100",
    "011111101100010101000100");

constant weaver_wide_tx : filt_type :=
--Scilab:
--> [v,a,f] = wfir ('lp', 256, [1.55/26 0], 'hn', [0 0]);
--> round(v*2^26)

   ("111111111111111111111001",
    "000000000000000000001100",
    "000000000000000001101110",
    "000000000000000100111111",
    "000000000000001001110001",
    "000000000000001110111110",
    "000000000000010010110011",
    "000000000000010011000000",
    "000000000000001101100101",
    "000000000000000001010011",
    "111111111111101110010110",
    "111111111111010110101101",
    "111111111110111110001001",
    "111111111110101001110110",
    "111111111110011111100000",
    "111111111110100100010110",
    "111111111110111011110010",
    "111111111111100110010011",
    "000000000000100000110010",
    "000000000001100100010011",
    "000000000010100110101100",
    "000000000011011011110111",
    "000000000011110111101010",
    "000000000011110000000111",
    "000000000010111111100110",
    "000000000001100110101000",
    "111111111111101100110000",
    "111111111101100000011101",
    "111111111011010101101011",
    "111111111001100011010010",
    "111111111000011111101000",
    "111111111000011100110001",
    "111111111001100100110011",
    "111111111011110111000101",
    "111111111111000110111101",
    "000000000010111100001100",
    "000000000110110101011000",
    "000000001010001100001110",
    "000000001100011011000000",
    "000000001101000010110000",
    "000000001011110000110100",
    "000000001000100011010110",
    "000000000011101011011110",
    "111111111101101100101001",
    "111111110111011001001101",
    "111111110001101100001010",
    "111111101101100000111001",
    "111111101011101010000011",
    "111111101100101000111011",
    "111111110000100110100101",
    "111111110111010000000001",
    "111111111111110110011101",
    "000000001001010011101110",
    "000000010010010010101100",
    "000000011001011010110110",
    "000000011101011101001111",
    "000000011101100001010111",
    "000000011001001111100110",
    "000000010000110111101010",
    "000000000101010001101100",
    "111111110111111001010110",
    "111111101010100011001011",
    "111111011111001101010011",
    "111111010111101101011110",
    "111111010101011110111100",
    "111111011001010010101000",
    "111111100011000100100110",
    "111111110001111000001110",
    "000000000011111100101101",
    "000000010110111001011101",
    "000000101000000001100010",
    "000000110100101011010110",
    "000000111010101001111101",
    "000000111000100011110101",
    "000000101110000100000001",
    "000000011100000010100000",
    "000000000100100001110110",
    "111111101010100001111001",
    "111111010001101000100000",
    "111110111101100010111101",
    "111110110001100011111111",
    "111110110000000011010000",
    "111110111010000010110010",
    "111111001110111110111011",
    "111111101100101011110010",
    "000000001111100001011011",
    "000000110010110110011000",
    "000001010001100101011010",
    "000001100110111010001100",
    "000001101110111110111100",
    "000001100111100100100001",
    "000001010000011111000010",
    "000000101011110001111001",
    "111111111101101000011111",
    "111111001011111010111111",
    "111110011101100001110101",
    "111101111001011100010110",
    "111101100101110010001000",
    "111101100110110111000000",
    "111101111110011010001010",
    "111110101011001000010011",
    "111111101000100101111110",
    "000000101111100100111101",
    "000001110110110100000001",
    "000010110100000100011010",
    "000011011101011101111000",
    "000011101010110111001111",
    "000011010111001000000000",
    "000010100001001000101000",
    "000001001100010111001110",
    "111111100000111010100101",
    "111101101011000000100001",
    "111011111001111001001110",
    "111010011110010101100011",
    "111001101000110010011001",
    "111001100111011101101111",
    "111010100100100011100010",
    "111100100100110000011001",
    "111111100110010110000000",
    "000011100000111001011001",
    "001000000101101111011110",
    "001101000001000101101110",
    "010001111011110001001110",
    "010110011101011000010011",
    "011010001110101000111000",
    "011100111011101011000100",
    "011110010110000000001100");


constant weaver_narrow : filt_type :=
--Scilab:
--> [v,a,f] = wfir ('lp', 256, [0.4/39 0], 'hn', 0);
--> round(v*2^28)

	("000000000000000001100010",
    "000000000000000110010010",
    "000000000000001110011100",
    "000000000000011010000110",
    "000000000000101001010001",
    "000000000000111011111011",
    "000000000001010001111000",
    "000000000001101010111010",
    "000000000010000110101101",
    "000000000010100100110100",
    "000000000011000100110001",
    "000000000011100101111100",
    "000000000100000111101100",
    "000000000100101001001111",
    "000000000101001001110001",
    "000000000101101000011000",
    "000000000110000100001000",
    "000000000110011100000000",
    "000000000110101110111101",
    "000000000110111011111000",
    "000000000111000001101011",
    "000000000110111111001110",
    "000000000110110011011000",
    "000000000110011101000001",
    "000000000101111011000100",
    "000000000101001100011101",
    "000000000100010000001001",
    "000000000011000101001101",
    "000000000001101010110001",
    "000000000000000000000000",
    "111111111110000100001111",
    "111111111011110110111010",
    "111111111001010111100010",
    "111111110110100101110011",
    "111111110011100001100100",
    "111111110000001010110011",
    "111111101100100001101010",
    "111111101000100110100001",
    "111111100100011001110111",
    "111111011111111100011100",
    "111111011011001111001010",
    "111111010110010011001010",
    "111111010001001001110000",
    "111111001011110100011111",
    "111111000110010101000110",
    "111111000000101101100101",
    "111110111011000000000100",
    "111110110101001110111100",
    "111110101111011100110001",
    "111110101001101100010100",
    "111110100100000000011111",
    "111110011110011100011011",
    "111110011001000011011000",
    "111110010011111000110001",
    "111110001111000000001010",
    "111110001010011101001100",
    "111110000110010011101010",
    "111110000010100111011000",
    "111101111111011100010010",
    "111101111100110110010100",
    "111101111010111001011100",
    "111101111001101001101010",
    "111101111001001010111000",
    "111101111001100001000001",
    "111101111010101111111001",
    "111101111100111011010000",
    "111110000000000110101101",
    "111110000100010101101100",
    "111110001001101011100011",
    "111110010000001011010111",
    "111110010111111000000010",
    "111110100000110100001110",
    "111110101011000010010011",
    "111110110110100100011010",
    "111111000011011100010101",
    "111111010001101011100110",
    "111111100001010011010101",
    "111111110010010100010111",
    "000000000100101111000111",
    "000000011000100011101000",
    "000000101101110001100110",
    "000001000100011000010000",
    "000001011100010110011101",
    "000001110101101010101010",
    "000010010000010010111001",
    "000010101100001100101111",
    "000011001001010101011010",
    "000011100111101001101011",
    "000100000111000101111010",
    "000100100111100110000101",
    "000101001001000101110011",
    "000101101011100000010000",
    "000110001110110000010011",
    "000110110010110000011100",
    "000111010111011010110110",
    "000111111100101001011010",
    "001000100010010101101101",
    "001001001000011001000101",
    "001001101110101100101000",
    "001010010101001001001111",
    "001010111011100111101001",
    "001011100010000000011011",
    "001100001000001100000001",
    "001100101110000010110101",
    "001101010011011101001011",
    "001101111000010011011000",
    "001110011100011101110001",
    "001110111111110100101111",
    "001111100010010000110000",
    "010000000011101010011011",
    "010000100011111010011111",
    "010001000010111001111001",
    "010001100000100001110011",
    "010001111100101011101001",
    "010010010111010001000110",
    "010010110000001100001101",
    "010011000111010111010011",
    "010011011100101101001001",
    "010011110000001000110101",
    "010100000001100101111011",
    "010100010001000000011001",
    "010100011110010100101011",
    "010100101001011111101100",
    "010100110010011110110110",
    "010100111001010000000100",
    "010100111101110001110000",
    "010101000000000010110111");

constant am_filter : filt_type :=

-->[v,a,f] = wfir ('lp', 256, [7.5/39 0], 'hn', [0 0]);
-->round(v*2^24)

   ("000000000000000000000110",
    "000000000000000000010011",
    "111111111111111111101011",
    "111111111111111110010111",
    "111111111111111111000101",
    "000000000000000010110011",
    "000000000000000100100011",
    "111111111111111111001100",
    "111111111111110111101000",
    "111111111111111001111010",
    "000000000000000111011011",
    "000000000000001111001110",
    "000000000000000010001111",
    "111111111111101100110101",
    "111111111111101101010000",
    "000000000000001010001011",
    "000000000000100000101001",
    "000000000000001101000101",
    "111111111111100001000010",
    "111111111111010111000111",
    "000000000000000110001100",
    "000000000000110111000011",
    "000000000000100011011101",
    "111111111111011001000111",
    "111111111110110111010111",
    "111111111111110110001011",
    "000000000001001110011001",
    "000000000001000111110010",
    "111111111111011011010001",
    "111111111110010000010100",
    "111111111111010101011010",
    "000000000001100000011111",
    "000000000001111010010001",
    "111111111111101110001101",
    "111111111101100111000000",
    "111111111110100000100111",
    "000000000001100101100000",
    "000000000010111000010101",
    "000000000000011000010010",
    "111111111101000011000001",
    "111111111101010110111011",
    "000000000001010100101011",
    "000000000011111100001010",
    "000000000001011110010101",
    "111111111100101110001100",
    "111111111011111010101101",
    "000000000000100101011011",
    "000000000100111100101111",
    "000000000011000010100110",
    "111111111100110011110101",
    "111111111010010010000111",
    "111111111111010000011010",
    "000000000101101110000100",
    "000000000101000011110011",
    "111111111101011111100110",
    "111111111000100111001111",
    "111111111101010000111001",
    "000000000110000001111001",
    "000000000111011100010101",
    "111111111110111100011000",
    "111111110111001000000101",
    "111111111010100101110000",
    "000000000101101000101010",
    "000000001010000001111000",
    "000000000001010010111100",
    "111111110110000110000001",
    "111111110111010010100010",
    "000000000100010010101001",
    "000000001100100101001100",
    "000000000100101000110001",
    "111111110101110101000100",
    "111111110011011111111111",
    "000000000001110001001000",
    "000000001110110010011001",
    "000000001000111110111111",
    "111111110110101010111111",
    "111111101111011100100101",
    "111111111101110111011110",
    "000000010000010001001111",
    "000000001110010001101110",
    "111111111000111110101001",
    "111111101011011100011110",
    "111111111000011011101100",
    "000000010000100101011100",
    "000000010100010111110111",
    "111111111101000111101010",
    "111111100111111001100110",
    "111111110001010110011011",
    "000000001111001110010111",
    "000000011011000011001111",
    "000000000011011111100000",
    "111111100101010100000110",
    "111111101000100001011101",
    "000000001011100101001010",
    "000000100010000001011001",
    "000000001100100100110101",
    "111111100100010011111111",
    "111111011101110011111100",
    "000000000100110111001010",
    "000000101000111100101100",
    "000000011001000100101111",
    "111111100101101110101001",
    "111111010000111001011000",
    "111111111001110110111001",
    "000000101111011101110111",
    "000000101010010001111011",
    "111111101010110110110000",
    "111111000000111011001000",
    "111111101000010010001111",
    "000000110101001101101100",
    "000001000011000111011001",
    "111111110110001110011110",
    "111110101011011100111101",
    "111111001010101001000011",
    "000000111001110110110111",
    "000001101011111000100110",
    "000000001110101101111101",
    "111110001000001000101011",
    "111110001110011100010010",
    "000000111101000111101010",
    "000011000111010011001111",
    "000001010011101011001101",
    "111100100111110011000100",
    "111010110110110001001100",
    "000000111110110011010111",
    "001101001011101001110001",
    "010111001001001110011111");

signal sample : boolean := false;
signal to_sample : boolean := false;
signal sampled : boolean := false;
signal state : integer range 0 to 6 := 0;
signal write_pointer : integer range 0 to 260 := 255;
signal read_pointer : integer range 0 to 260 := 255;
signal asynch_data_read_I, asynch_data_read_Q, synch_data_read_I, synch_data_read_Q : signed (23 downto 0);
signal mac_I, mac_Q : signed (54 downto 0);
signal prod_I, prod_Q : signed (47 downto 0);
	

begin
	
	p0 : process (clk_in)
	variable indata_I, indata_Q : signed (23 downto 0);
	begin	
		if clk_in'event and clk_in = '1' then
			if sample = true then
				to_sample <= true; -- sample at next clock cycle
			elsif to_sample = true then -- sample and write to RAM
				if tx = '0' then
					indata_I := signed(RX_Data_in_I);
					indata_Q := signed(RX_Data_in_Q);
				else
					indata_I := signed(TX_Data_in_I(13) & TX_Data_in_I(13) & TX_Data_in_I(13) & TX_Data_in_I(13) & TX_Data_in_I(13) & TX_Data_in_I(13) & TX_Data_in_I(13) & TX_Data_in_I(13) & TX_Data_in_I(13) & TX_Data_in_I(13) & TX_Data_in_I);
					indata_Q := signed(TX_Data_in_Q(13) & TX_Data_in_Q(13) & TX_Data_in_Q(13) & TX_Data_in_Q(13) & TX_Data_in_Q(13) & TX_Data_in_Q(13) & TX_Data_in_Q(13) & TX_Data_in_Q(13) & TX_Data_in_Q(13) & TX_Data_in_Q(13) & TX_Data_in_Q);
				end if;
				data_in_buffer_I(write_pointer) <= indata_I;
				data_in_buffer_Q(write_pointer) <= indata_Q;
				to_sample <= false;
				sampled <= true;
			else
				sampled <= false;

			end if;
			asynch_data_read_I <= data_in_buffer_I(read_pointer);
			asynch_data_read_Q <= data_in_buffer_Q(read_pointer);
			synch_data_read_I <= asynch_data_read_I;
			synch_data_read_Q <= asynch_data_read_Q;
				
		end if;
	end process;
	
	sample_ff : process(clk_sample,sampled)
	begin
		if to_sample = true then
			sample <= false;
		elsif clk_sample'event and clk_sample = '1' then
			sample <= true;
		end if;
	end process;
			
	p1 : process (clk_in)
	variable filtkoeff : signed(23 downto 0);
	variable n : integer range 0 to 270 := 0;
	variable p : integer range 0 to 540;
	variable k : integer range 0 to 126;
	
	begin
		if clk_in'event and clk_in = '0' then 
				
			if sampled = true then
				state <= 0;
			elsif state = 0 then
				deb <= '1';
				n := 0;
				if write_pointer = 0 then
					write_pointer <= 260;
					read_pointer <= 2;
				elsif write_pointer = 260 then
					write_pointer <= write_pointer - 1;
					read_pointer <= 1;
				elsif write_pointer = 259 then
					write_pointer <= write_pointer - 1;
					read_pointer <= 0;
				else
					write_pointer <= write_pointer - 1;
					read_pointer <= write_pointer + 2;
				end if;		
				mac_I <= to_signed(0,55);
				mac_Q <= to_signed(0,55);
				prod_I <= to_signed(0,48);
				prod_Q <= to_signed(0,48);
				state <= 1;
			elsif state = 1 then 
				p := read_pointer + 1;
				if p > 260 then
					read_pointer <= p - 261;
				else
					read_pointer <= p;
				end if;
				state <= 3;
			elsif state = 3 then

				if n > 126 then
					k := 253 - n;
				else
					k := n;
				end if;
				
				if filt_bypass = '1' then
					if n = 10 then
						filtkoeff := "011111111111111111111111";
					else
						filtkoeff := "000000000000000000000000";
					end if;
				elsif ssb_am = '0' then
					filtkoeff := am_filter(k);
				else
					if wide_narrow = '1' then
						if tx = '0' then
							filtkoeff := weaver_wide_rx(k);
						else
							filtkoeff := weaver_wide_tx(k);
						end if;
					else
						filtkoeff := weaver_narrow(k);
					end if;
				end if;
				prod_I <= synch_data_read_I * filtkoeff;
				prod_Q <= synch_data_read_Q * filtkoeff;
				mac_I <= mac_I + prod_I;
				mac_Q <= mac_Q + prod_Q;
		
				n := n + 1;
				
				if n > 253 then
					state <= 4;
				else				
					p := read_pointer + 1;
					if p > 260 then
						read_pointer <= p - 261;
					else
						read_pointer <= p;
					end if;
				end if;
				
			elsif state = 4 then
				mac_I <= mac_I + prod_I;
				mac_Q <= mac_Q + prod_Q;
				state <= 5;
			elsif state = 5 then
					--Data_out_I <= std_logic_vector(mac_I + to_signed(8388608,61))(47 downto 24);  
					--Data_out_Q <= std_logic_vector(mac_Q + to_signed(8388608,61))(47 downto 24);  
				deb <= '0';
				if ssb_am = '0' then
					Data_out_I <= std_logic_vector(mac_I + to_signed(33554432,63))(49 downto 26);  
					Data_out_Q <= std_logic_vector(mac_Q + to_signed(33554432,63))(49 downto 26);  
				else
					if tx = '1' then
						Data_out_I <= std_logic_vector(mac_I + to_signed(16777216,63))(48 downto 25);  
						Data_out_Q <= std_logic_vector(mac_Q + to_signed(16777216,63))(48 downto 25);  
					else
						Data_out_I <= std_logic_vector(mac_I + to_signed(134217728,63))(51 downto 28); -- 49 downto 26
						Data_out_Q <= std_logic_vector(mac_Q + to_signed(134217728,63))(51 downto 28); 
					end if;
				end if;
				state <= 6;
			end if;
		end if;
	end process;
	
end filter_arch;