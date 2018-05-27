----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:49:26 05/23/2018 
-- Design Name: 
-- Module Name:    transmisor - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity transmisor is
    PORT(
            -- Entrada
            BAUD_SELEC_IN : in std_logic_vector(1 downto 0);
            DATA_IN : in std_logic_vector(7 downto 0);
            BTN_IN : in std_logic;
            
            -- Reloj y reset asincrono
            clk :  in std_logic;
            a_reset : in std_logic;
            
            -- Salidas
            TX_out : out std_logic;
            TX_ready :  out std_logic);
end transmisor;

architecture Behavioral of transmisor is

signal state : std_logic_vector(1 downto 0):= (others => '0');  -- Estado actual   0 => IDLE
signal BAUD_SELEC : std_logic_vector(1 downto 0);               -- Selector baud
signal DATA : std_logic_vector(7 downto 0);                     -- RegData
signal BTN : std_logic;                                         -- Boton
signal SENAL_MUESTREO: std_logic := '0';
signal BIT_PARIDAD :  std_logic;

signal count : std_logic_vector(11 downto 0);                  -- Cuenta de clk
signal aux_count : std_logic_vector(11 downto 0);              -- Cuenta aux de clk

signal bauds : std_logic_vector(11 downto 0);                  -- Numero de clk para el baudrate

begin

-- Contador de ciclos de reloj
process(clk,a_reset)
begin
    if(a_reset = '1') then
        count <= (others => '0');
        aux_count <= (others => '0');   
        DATA <= (others => '0');
        BAUD_SELEC <= "00";
        -- BTN <= '0';
    elsif (clk = '1' and clk'event) then
        if (state = "01") then
            BAUD_SELEC <= BAUD_SELEC_IN;
            DATA <= DATA_IN;
            -- BTN <= BTN_IN;                               No hace falta registrarlo
            if(count = bauds) then
                count <= (others => '0');
                aux_count <= (others => '0');
                SENAL_MUESTREO <= '1';
            else
                aux_count <= aux_count + '1';
                SENAL_MUESTREO <= '0';
                count <= aux_count;
            end if;
         elsif(state = "00") then 
            -- TX_ready <= '1';
        end if;
    end if;
end process;

BIT_PARIDAD <= DATA(7) xor DATA(6) xor DATA(5) xor DATA(4) xor DATA(3) xor DATA(2) xor 
DATA(1) xor DATA(0);

-- Selector de Bauds
process(BAUD_SELEC,a_reset)
begin
    if(a_reset = '1') then
        -- BAUD_SELEC <= "00";
        bauds <= (others => '0');
    elsif(state = "01") then      -- Solo hará si se esta en estado 1
        case BAUD_SELEC is
        when "00" => bauds <= "100000000000";                -- Baud 4800 => 2048 ciclos           
        when "01" => bauds <= "010000010010";                -- Baud 9600 => 1042 ciclos
        when "10" => bauds <= "001000001001";                -- Baud 19200 => 521 ciclos
        when others => bauds <= "000010101110";              -- Baud 57600 => 174 ciclos
        end case;
    end if;
end process;

-- Pulsador de boton para estado
process(BTN_IN,a_reset)
begin
    if(a_reset = '1') then
        state <= (others => '0');
        TX_ready <= '1';
    elsif(state = "00" and BTN_IN'event and BTN_IN = '1') then
        state <= "01";
        TX_ready <= '0';
    end if;
end process;

end Behavioral;


