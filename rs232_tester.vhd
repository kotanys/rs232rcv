library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use std.textio.all;
  use ieee.std_logic_textio.all;

entity rs232_tester is
  generic (
    n          : natural;
    end_bits   : natural;
    clk_period : time;
    bit_time   : time
  );
  port (
    -- to DUT
    clk_o  : out   std_logic;
    rst_no : out   std_logic;
    data_o : out   std_logic;
    -- from DUT
    data_i : in    std_logic_vector(n - 1 downto 0);
    err_i  : in    std_logic;
    done_i : in    std_logic
  );
end entity rs232_tester;

architecture sim of rs232_tester is

  constant wait_time : time := 0 ns;

  signal clk   : std_logic := '0';
  signal rst_n : std_logic := '0';
  signal data  : std_logic := '1';

  function to_hstring (
    slv : std_logic_vector
  ) return string is

    variable l : line;

  begin

    hwrite(l, slv);
    return L.all;

  end function to_hstring;

  procedure send_bit (
    signal   l : out std_logic;
    constant b : in  std_logic;
    constant t : in  time
  ) is
  begin

    l <= b;
    wait for t;

  end procedure send_bit;

  procedure send_frame (
    signal   l    : out std_logic;
    constant data : in  std_logic_vector(n - 1 downto 0);
    constant t    : in  time
  ) is
  begin

    report "Tester: sending 0x" & to_hstring(data)
      severity note;

    send_bit(l, '0', t); -- start bit

    for i in n - 1 downto 0 loop -- data, LSB first

      send_bit(l, data(i), t);

    end loop;

    for i in 0 to end_bits - 1 loop -- stop bits

      send_bit(l, '1', t);

    end loop;

  end procedure send_frame;

begin

  clk <= not clk after clk_period / 2;

  clk_o  <= clk;
  rst_no <= rst_n;
  data_o <= data;

  send : process is
  begin
    rst_n <= '0';
    data  <= '1';
    wait for 1 ms;
    rst_n <= '1';
    wait for 1 us;

    send_frame(data, x"FF", bit_time);
    data <= '1';
    wait for wait_time;

    for i in 0 to 5 loop
      send_frame(data, x"3C", bit_time);
      data <= '1';
      wait for wait_time;
    end loop;

    send_frame(data, x"00", bit_time);
    data <= '1';
    wait for wait_time;

    send_frame(data, x"DA", bit_time);
    data <= '1';
    wait for wait_time;

    report "Tester: done."
      severity note;
    wait;

  end process send;

  monitor : process (done_i) is
  begin

    if rising_edge(done_i) then
      report "Tester: DUT reported done, data=0x" & to_hstring(data_i) &
             " err=" & std_logic'image(err_i)
        severity note;
    end if;

  end process monitor;

end architecture sim;
