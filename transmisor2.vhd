----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:01:54 05/25/2018 
-- Design Name: 
-- Module Name:    transmisor2 - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity transmisor2 is
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
end transmisor2;

architecture Behavioral of transmisor2 is
type state_type is (idle,tx_inicio,tx_datos);
signal state_actual, state_siguiente : state_type;

signal BAUD_SELEC : std_logic_vector(1 downto 0);               -- Selector baud
signal DATA : std_logic_vector(7 downto 0);                     -- RegData
signal BTN : std_logic;                                         -- Boton
signal SENAL_MUESTREO: std_logic := '0';
signal BIT_PARIDAD :  std_logic;
signal TSR : std_logic;

--signal MENSAJE,
signal shifter : std_logic_vector(9 downto 0);                 -- Mensaje a enviar

signal count : std_logic_vector(11 downto 0);                  -- Cuenta de clk
signal aux_count : std_logic_vector(11 downto 0);              -- Cuenta aux de clk

signal bauds : std_logic_vector(11 downto 0);                  -- Numero de clk para el baudrate

signal bits_send : std_logic_vector(3 downto 0);               -- length MENSAJE

signal flag : std_logic;

signal sending : std_logic;
--signal send : std_logic;
begin

-- Controlador de procesos
process(clk,a_reset)
begin
    -- Parte dependiente del reloj
    if(a_reset = '1') then
        state_actual <= idle;
        --state_siguiente <= idle;
    elsif (clk'event and clk = '1') then
        state_actual <= state_siguiente;
    end if;
    -- Parte Combinacional 
    TX_out <= '0';
    TX_ready <= '0';
    case state_actual is
        when idle => -- Estado de reposo 
            if(flag = '1') then
                BAUD_SELEC <= BAUD_SELEC_IN; 
                DATA <= DATA_IN;
                case BAUD_SELEC is
                    when "00" => bauds <= "100000000000";  
                    when "01" => bauds <= "010000010010";
                    when "10" => bauds <= "001000001001";
                    when others => bauds <= "000010101110";
                end case;
                
                --BTN <= '0';
                TX_ready <= '0';
                TX_out <= '0';
                state_siguiente <= tx_inicio;
           else
                BIT_PARIDAD <= '0';
                BAUD_SELEC <= (others => '0');
                bauds <= (others => '0');
                DATA <= (others => '0');
                BTN <= '0';
                TX_ready <= '1';
                TX_out <= '0';
                state_siguiente <= idle;
           end if; 
        when tx_inicio => -- Estado de tx_inicio
        BIT_PARIDAD <= DATA(7) xor DATA(6) xor DATA(5) xor DATA(4) xor DATA(3) xor DATA(2) xor DATA(1) xor DATA(0);
            --MENSAJE <= DATA(7 downto 0) & '0';
            
            TX_ready <= '0'; 
            state_siguiente <= tx_datos;
        when tx_datos => -- Estado de envio de datos
                if(sending = '0') then
                    state_siguiente <= idle;
                else
                    state_siguiente <= tx_datos;
                end if;
                TX_out <= TSR;
        when others => state_siguiente <= idle;
    end case;
end process;

process(clk,a_reset)
begin
    if(clk'event AND clk = '1') then    
        if(state_actual = tx_inicio OR state_actual = tx_datos) then
            if(state_actual = tx_inicio) then
                shifter <= BIT_PARIDAD & DATA(7 downto 0) & '0';
            end if;
            
            if(count = bauds) then
                count <= (others => '0');
                aux_count <= (others => '0');
                SENAL_MUESTREO <= '1';
                if(bits_send = "1010") then
                    bits_send <= (others => '0');
                    TSR <= shifter(0);
                    sending <= '0';
                else
                    TSR <= shifter(0);
                    shifter <= shifter(0) & shifter(9 downto 1);
                    bits_send <= bits_send + '1';
                    sending <= '1';
                end if;
            else
                aux_count <= aux_count + '1';
                SENAL_MUESTREO <= '0';
                count <= aux_count;
            end if;
        else
            shifter <= (others => '0');
            bits_send <= (others => '0');
            count <= (others => '0');
            aux_count <= (others => '0');
            SENAL_MUESTREO <= '0';    
        end if;
    end if;
end process;

process(BTN_IN,state_actual)
begin
    if(state_actual = idle and BTN_IN = '1') then
        flag <= '1';
    else
        flag <= '0';
    end if;
end process;

                --if(bits_send = "1010") then
                 --   bits_send <= (others => '0');
                 --   TSR <= '1';
                --    state_siguiente <= idle;
               -- else
                --    TSR <= MENSAJE(0);
                --    MENSAJE <= MENSAJE(0) & MENSAJE(9 downto 1);
                --    bits_send <= bits_send + '1';
                 --   state_siguiente <= tx_datos;
                --end if;

end Behavioral;
