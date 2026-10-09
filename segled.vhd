library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity segled is
  generic (
    active_low : boolean
  );
  port (
    clki_i     : in    std_logic;
    rst_ni     : in    std_logic;
    data_i     : in    std_logic_vector(7 downto 0);
    selected_o : out   std_logic_vector(2 downto 0);
    led_o      : out   std_logic_vector(6 downto 0)
  );
end entity segled;

architecture rtl of segled is

  function decode (nibble : std_logic_vector(3 downto 0))
    return std_logic_vector is
  begin
    case nibble is
      when "0000" => return "1111110"; -- 0
      when "0001" => return "0110000"; -- 1
      when "0010" => return "1101101"; -- 2
      when "0011" => return "1111001"; -- 3
      when "0100" => return "0110011"; -- 4
      when "0101" => return "1011011"; -- 5
      when "0110" => return "1011111"; -- 6
      when "0111" => return "1110000"; -- 7
      when "1000" => return "1111111"; -- 8
      when "1001" => return "1111011"; -- 9
      when "1010" => return "1110111"; -- A
      when "1011" => return "0011110"; -- B
      when "1100" => return "1001110"; -- C
      when "1101" => return "0111101"; -- D
      when "1110" => return "1001111"; -- E
      when "1111" => return "1000111"; -- F
      when others => return "0000000";
    end case;
  end function decode;

  signal digit : std_logic_vector(6 downto 0) := (others => '0');
  signal cnt   : std_logic_vector(9 downto 0) := (others => '1');

begin

  clock : process (rst_ni, clki_i) is
    variable i : natural range 0 to 2 := 2;
  begin
    if (rst_ni = '0') then
      i := 2; -- 2 so that first update lands on i=0
      cnt        <= (others => '1');
      selected_o <= "001";
      digit      <= (others => '0');
    elsif rising_edge(clki_i) then
      cnt <= cnt - 1;

      if (cnt = 0) then
        i := (i+1) mod 3;

        case i is
          when 0 =>
            digit      <= decode(data_i(7 downto 4));
            selected_o <= "001";
          when 1 =>
            digit      <= decode(data_i(3 downto 0));
            selected_o <= "010";
          when 2 =>
            digit      <= (others => '0');
            selected_o <= "100";
        end case;

      end if;

    end if;

  end process clock;

  set_led : process(digit) is
  begin
    if (active_low) then
      led_o <= not digit;
    else
      led_o <= digit;
    end if;
  end process set_led;

end architecture rtl;
