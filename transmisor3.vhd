library IEEE;
use std_logic_1164.all;
use std_numeric.all;

entity TransmisorSerie is 
	PORT(
		-- Entradas
		baud_selec_in : in std_logic_vector(2 downto 0);
		data_in : in std_logic_vector(6 downto 0);
		btn_in : in std_logic;
		
		-- Salidas
		Tx_out : out std_logic;
		Tx_ready : out std_logic;
		
		-- Clks y resets
		clk : in std_logic;
		areset : in std_logic;
	);
end entity;

architecture Behavioral of TransmisorSerie is
-- Signals FSM
type state_sig : (idle, tx_inicio, tx_datos);
signal current_st, next_st : state_sig;

-- Internal value signals
signal bauds : unsigned(63 downto 0);
signal tx_bits : unsigned(3 downto 0);
signal regdata : std_logic_vector(9 downto 0);
signal paridad : std_logic;
signal TSR : std_logic_vector(9 downto 0);
signal senal_muestreo : std_logic;

-- Control signals FSM
signal registerDataIn_enable : std_logic;
signal shifterTx_enable : std_logic;
signal baudselector_enable : std_logic;
signal counterBitsTx_enable : std_logic;
signal counterBauds_enable : std_logic;

-- Counter vars
signal count_bauds: std_logic;

begin
-- CLK FSM process
process(clk, areset)
begin
	if(areset = '1') then
		current_st <= idle;
	else if(clk'event and clk='1') theb
		current_st <= next_st;
	end if;
end process;

-- Diagram FSM process
process(current_st,BTN_IN)
begin
	case current_st is
		when idle => 
				if(BTN_IN = '1') then
					next_st <= tx_inicio;
				else
					next_st <= idle;
				end if;
		when tx_inicio =>
				next_st <= tx_datos;					
		when tx_datos =>
				if(tx_bits >= 10) then
					next_st <= idle;
				else
					next_st <= tx_datos;
				end if;
	end case;
end process;

-- Control Signals FSM
process(current_st)
begin
	case current_st is
		when idle =>
			baudselector_enable <= '1';
			registerDataIn_enable <= '0';
			shifterTx_enable <= '0';
			counterBitsTx_enable <= '0';
			counterBauds_enable <= '0';
			
			Tx_ready <= '1';
			
		when tx_inicio =>
			baudselector_enable <= '0';
			registerDataIn_enable <= '1';
			shifterTx_enable <= '0';
			counterBitsTx_enable <= '0';
			counterBauds_enable <= '0';
			
			Tx_ready <= '0';
			
		when tx_datos =>
			baudselector_enable <= '0';
			registerDataIn_enable <= '0';
			shifterTx_enable <= '1';
			counterBitsTx_enable <= '1';
			counterBauds_enable <= '1';
			
			Tx_ready <= '0';
	end case;
end process;

-- Baud selector 
process(BAUD_SELEC_IN, areset)
begin
	if(areset = '1') then
		bauds <= 0;
	else if(baudselector_enable = '1') then
		case BAUD_SELEC_IN is
			when 00 => bauds <= 2048;
			when 01 => bauds <= 1024;
			when 10 => bauds <= 571;
			when 11 => bauds <= 127;
		end case;
	end if;
end process;

-- Register data in
process(clk, areset, data_IN)
begin
	if(areset = '1') then
		RegData <= (other => '0');
	else if(register_datain_enable = '1' and clk'event and clk = '1') then
		paridad <= regdata(0) xor regdata(1) ...;
		regdata <= paridad & data_in & '0';
	end if; 
end process;

-- Baudrate counter
process(clk, areset)
begin
	if(areset = '1') then
		count_bauds <= 0;
		senal_muestreo <= '0';
	else if(counter_bauds_enable = '1' clk'event and clk = '1') then
		if(count_bauds = bauds) then
			senal_muestreo <= '1';
			count_bauds <= '0';
		else
			senal_muestreo <= '0';
			count_bauds <= count_bauds + 1;
		end if;
	end if;
end process;

-- TX Bit counter
process(senal_muestreo, areset)
begin
	if(areset = '1') then
		tx_bits <= 0;
	else if(counter_txbits_enable = '1' senal_muestreo'event and senal_muestreo = '1') then
		tx_bits <= tx_bits + 1;
	end if;
end process;

-- Shifter TX
process(senal_muestreo, areset)
begin
	if(areset = '1') then
		TSR <= (others => '0');
	else if(shifter_tx_enable = '1' senal_muestreo = '1') then
		TSR <= RegData(0);
		RegData <= RegData(0) & RegData(9 downto 1);
	end if;
end process;
