library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity segled is
  generic (
    active_low : boolean
  );
  port (
    clki_i         : in    std_logic;
    rst_ni         : in    std_logic;
    data_i         : in    std_logic_vector(7 downto 0);
    selected_cnt_o : out   std_logic_vector(1 downto 0);
    led_o          : out   std_logic_vector(6 downto 0)
  );
end entity segled;

architecture rtl of segled is

  function decode (nibble : std_logic_vector(3 downto 0))
    return std_logic_vector is
  begin
    case nibble is
      when "0000" => return "1111110";
      when "0001" => return "0110000";
      when "0010" => return "1101101";
      when "0011" => return "1111001";
      when "0100" => return "0110011";
      when "0101" => return "1011011";
      when "0110" => return "1011111";
      when "0111" => return "1110000";
      when "1000" => return "1111111";
      when "1001" => return "1111011";
      when "1010" => return "1110111";
      when "1011" => return "0011110";
      when "1100" => return "1001110";
      when "1101" => return "0111101";
      when "1110" => return "1001111";
      when "1111" => return "1000111";
      when others => return "0000001";
    end case;
  end function decode;

  signal cnt : std_logic_vector(9 downto 0) := (others => '1');

begin

  clock : process (rst_ni, clki_i) is
    variable i     : natural range 0 to 1 := 0;
    variable digit : std_logic_vector(6 downto 0);
  begin
    if (rst_ni = '0') then
      i := 0;
      cnt <= (others => '1');
      selected_cnt_o <= "10";
      if (active_low) then
        led_o <= (others => '1');
      else
        led_o <= (others => '0');
      end if;
    elsif rising_edge(clki_i) then
      cnt <= cnt - 1;

      if (cnt = (cnt'range => '1')) then
        if (i = 0) then
          i := 1;
          selected_cnt_o <= "01";
          digit := decode(data_i(7 downto 4));
        else
          i := 0;
          selected_cnt_o <= "10";
          digit := decode(data_i(3 downto 0));
        end if;

        if (active_low) then
          led_o <= not digit;
        else
          led_o <= digit;
        end if;
      end if;

    end if;

  end process clock;

end architecture rtl;
