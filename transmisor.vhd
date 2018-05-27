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
--signal BTN : std_logic;                                         -- Boton
signal SENAL_MUESTREO: std_logic := '0';
signal BIT_PARIDAD :  std_logic;
signal TSR : std_logic;

signal MENSAJE : std_logic_vector(9 downto 0);                 -- Mensaje a enviar

signal count : std_logic_vector(11 downto 0);                  -- Cuenta de clk
signal aux_count : std_logic_vector(11 downto 0);              -- Cuenta aux de clk

signal bauds : std_logic_vector(11 downto 0);                  -- Numero de clk para el baudrate

signal bits_send : std_logic_vector(3 downto 0);               -- length MENSAJE

begin

-- Contador de ciclos de reloj
clk_counter:process(clk,a_reset)
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
            MENSAJE <= BIT_PARIDAD & DATA(7 downto 0) & '0';
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
         elsif(state = "10") then 
             if(count = bauds) then
                count <= (others => '0');
                aux_count <= (others => '0');
                SENAL_MUESTREO <= '1';
            else
                aux_count <= aux_count + '1';
                SENAL_MUESTREO <= '0';
                count <= aux_count;
            end if;
        end if;
    end if;
end process;

BIT_PARIDAD <= DATA(7) xor DATA(6) xor DATA(5) xor DATA(4) xor DATA(3) xor DATA(2) xor DATA(1) xor DATA(0);

-- Selector de Bauds
selec_bauds:process(BAUD_SELEC,a_reset)
begin
    if(a_reset = '1') then
        BAUD_SELEC <= "00";
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
button:process(BTN_IN,state)
begin
    if(state = "00" and BTN_IN'event and BTN_IN = '1') then
            state <= "01";
    end if;
end process;

-- Shifter
shifter:process(senal_muestreo,a_reset)
begin
    if(a_reset = '1') then
        bits_send <= (others => '0');
    elsif(senal_muestreo'event and senal_muestreo = '1') then
        case state is
        when "01" =>
            bits_send <= "0000";
            state <= "10";
            TSR <= MENSAJE(0);
            bits_send <= bits_send + '1';
        when "10" => 
            if (bits_send = "1010") then
                bits_send <= (others => '0');
                TSR <= '1';
                state <= "00";
            else
                MENSAJE <= MENSAJE(0) & MENSAJE(9 downto 1);
                TSR <= MENSAJE(0);
                bits_send <= bits_send + '1';
            end if;
        when others =>
                state <= "00"; 
           
        end case;
    end if;
end process;

TX_out <= TSR;

-- TX_ready
txready:process(state)
begin
    if(state = "00") then
        TX_ready <= '1';
    else 
        TX_ready <= '0';
    end if;
end process;

end Behavioral;
