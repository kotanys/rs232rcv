library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use std.textio.all;
  use ieee.std_logic_textio.all;

entity rs232_tester is
  generic (
    n          : natural := 8;
    end_bits   : natural := 2;
    clk_period : time := 500 ns; -- 2 MHz
    bit_time   : time := 26.04 us -- 38400 baud
    -- bit_time   : time := 8.68 us -- 115200 baud
  );
  port (
    -- from DUT
    data_i : in  std_logic_vector(n - 1 downto 0);
    err_i  : in  std_logic;
    done_i : in  std_logic;
    -- to DUT
    clk_o  : out std_logic;
    rst_no : out std_logic;
    data_o : out std_logic
  );
end entity rs232_tester;

architecture sim of rs232_tester is

  constant wait_time : time := 0 ns;
  constant data_len : natural := 25;
  constant data_string : std_logic_vector(data_len*8 - 1 downto 0) :=
    x"2D01C9A459016F07B5E12BC103D2A62486460D91E2B890EEB6";

  signal data_rcv : std_logic_vector(data_len*8 - 1 downto 0) := (others => '0');
  signal data_read_cnt : natural := 0;

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
    variable sent : std_logic_vector(7 downto 0);
  begin
    rst_n <= '0';
    data  <= '1';
    wait for 50 us;
    rst_n <= '1';
    wait for 1 us;

    -- Calibration packet
    send_frame(data, x"FF", bit_time);
    data <= '1';
    wait for wait_time;

    for j in 0 to 3 loop
      for i in 0 to data_len - 1 loop
        sent := data_string(data_len*8 - 1 - i*8 downto data_len*8 - 8 - i*8);

        send_frame(data, sent, bit_time);
        data <= '1';
        wait for wait_time;

      end loop;

      wait for 100 us;
    end loop;

    report "Tester: finished."
      severity note;
    wait;

  end process send;

  monitor : process (clk) is
  begin

    if (rising_edge(clk) and done_i = '1')  then
      report "Recieved data=0x" & to_hstring(data_i) & " err=" & std_logic'image(err_i)
        severity note;

      data_rcv <= data_rcv(data_rcv'high - data_i'length downto 0) & data_i;

      if (data_read_cnt = data_len - 1) then
        assert data_string = (data_rcv(data_rcv'high - data_i'length downto 0) & data_i)
          report "Txmit FAILED"
          severity failure;
        data_read_cnt <= 0;
      else
        data_read_cnt <= data_read_cnt + 1;
      end if;

    end if;

  end process monitor;

end architecture sim;
