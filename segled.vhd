library ieee;
  use ieee.std_logic_1164.all;

entity segled is
  generic (
    n          : natural;
    active_low : boolean
  );
  port (
    clki_i         : in    std_logic;
    rst_ni         : in    std_logic;
    data_i         : in    std_logic_vector(n - 1 downto 0);
    selected_cnt_o : out   std_logic_vector(1 downto 0);
    led_o          : out   std_logic_vector(6 downto 0)
  );
end entity segled;

architecture rtl of segled is

  constant cnt_digits : integer := (n + 3) / 4;

  signal led_out      : std_logic_vector(((n + 3) / 4 * 7) - 1 downto 0);

begin

  assert (n > 0)
    report "no digits!"
    severity failure;


  clock : process (rst_ni, clki_i) is
    variable i : integer;
  begin

    if (rst_ni = '0') then
      i := 0;
      selected_cnt_o <= "01";
      if active_low then
        led_o <= (others => '1');  -- active-low: all segments off
      else
        led_o <= (others => '0');  -- active-high: all segments off
      end if;
    elsif rising_edge(clki_i) then
      if (i = 0) then
        i := 1;
        selected_cnt_o <= "10";
        led_o          <= led_out(13 downto 7);
      else
        i := 0;
        selected_cnt_o <= "01";
        led_o          <= led_out(6 downto 0);
      end if;
    end if;

  end process clock;

  convert : process (data_i) is

    variable data_padded : std_logic_vector(cnt_digits * 4 - 1 downto 0);
    variable led         : std_logic_vector(cnt_digits * 7 - 1 downto 0);
    variable slice       : std_logic_vector(3 downto 0);

  begin

    data_padded                 := (others => '0');
    data_padded(n - 1 downto 0) := data_i;

    for i in cnt_digits - 1 downto 0 loop

      slice := data_padded((i + 1) * 4 - 1 downto i * 4);

      case slice is

        when "0000" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1111110";
        when "0001" =>
          led((i + 1) * 7 - 1 downto i * 7) := "0110000";
        when "0010" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1101101";
        when "0011" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1111001";
        when "0100" =>
          led((i + 1) * 7 - 1 downto i * 7) := "0110011";
        when "0101" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1011011";
        when "0110" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1011111";
        when "0111" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1110000";
        when "1000" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1111111";
        when "1001" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1111011";
        when "1010" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1110111";
        when "1011" =>
          led((i + 1) * 7 - 1 downto i * 7) := "0011110";
        when "1100" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1001110";
        when "1101" =>
          led((i + 1) * 7 - 1 downto i * 7) := "0111101";
        when "1110" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1001111";
        when "1111" =>
          led((i + 1) * 7 - 1 downto i * 7) := "1000111";
        when others =>
          led((i + 1) * 7 - 1 downto i * 7) := "0000001";
      end case;

    end loop;

    if (active_low) then
      led_out <= not led;
    else
      led_out <= led;
    end if;

  end process convert;

end architecture rtl;
