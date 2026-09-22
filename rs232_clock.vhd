library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity rs232_clock is
  generic (
    counter_size : natural := 8
  );
  port (
    data_i         : in    std_logic;
    rst_ni         : in    std_logic;
    clki_i         : in    std_logic;
    clko_i         : in    std_logic;
    internal_clk_o : out   std_logic;
    sr_rst_no      : out   std_logic
  );
end entity rs232_clock;

architecture rtl of rs232_clock is

  type clock_fsm is (
    st_c_wait,  -- Waiting for calibration packet
    st_c_start, -- Calibrating
    st_idle,    -- Waiting for data packet
    st_data     -- Receiving data packet
  );

  signal state      : clock_fsm;
  signal up_count   : std_logic_vector(counter_size - 1 downto 0);
  signal down_count : std_logic_vector(counter_size - 2 downto 0);
  signal divider2   : std_logic;

  -- 2-flop chain for (data -> st_idle) transition
  signal clko_meta : std_logic;
  signal clko_sync : std_logic;

begin

  assert counter_size >= 2
    report "counter_size must be >= 2"
    severity failure;

  internal_clk_o <= divider2;

  clock : process (clki_i, rst_ni) is
  begin

    if (rst_ni = '0') then
      state      <= st_c_wait;
      sr_rst_no  <= '0';
      up_count   <= (others => '0');
      down_count <= (others => '0');
      divider2   <= '0';
      clko_meta  <= '0';
      clko_sync  <= '0';
    elsif (clki_i'event and clki_i = '1') then
      clko_meta <= clko_i;
      clko_sync <= clko_meta;
      sr_rst_no <= '0';

      case state is

        when st_c_wait =>

          up_count   <= (others => '0');
          down_count <= (others => '0');
          divider2   <= '0';

          if (data_i = '0') then
            state <= st_c_start;
          end if;

        when st_c_start =>

          up_count <= std_logic_vector(unsigned(up_count) + 1);
          if (data_i = '1') then
            down_count <= up_count(counter_size - 1 downto 1);
            state      <= st_idle;
          end if;

        when st_idle =>

          down_count <= up_count(counter_size - 1 downto 1);
          divider2   <= '0';

          if (data_i = '0') then
            state <= st_data;
          end if;

        when st_data =>

          sr_rst_no <= '1';

          if (unsigned(down_count) = 1) then
            down_count <= up_count(counter_size - 1 downto 1);
            divider2   <= not divider2;
          else
            down_count <= std_logic_vector(unsigned(down_count) - 1);
          end if;

          if (clko_sync = '1') then
            state <= st_idle;
          end if;

      end case;

    end if;

  end process clock;

end architecture rtl;
