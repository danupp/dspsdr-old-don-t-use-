library ieee;
use ieee.std_logic_1164.ALL;

entity tx_rx_clock_mux is
	port (rx_clk : in std_logic;
			tx_clk : in std_logic;
			tx : in std_logic;
			clk_out : out std_logic
			);
end tx_rx_clock_mux;

architecture clock_mux_arch of tx_rx_clock_mux is

begin
	
	clk_out <= (tx and tx_clk) or (not tx and rx_clk);
	
end clock_mux_arch;