library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

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

  -- 2-flop chain for (st_data -> st_idle) transition
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
      state <= st_c_wait;
    elsif (clki_i'event and clki_i = '1') then

      case state is

        when st_c_wait =>

          if (data_i = '0') then
            state <= st_c_start;
          end if;

        when st_c_start =>

          if (data_i = '1') then
            state <= st_idle;
          end if;

        when st_idle =>

          if (data_i = '0') then
            state <= st_data;
          end if;

        when st_data =>

          if (clko_sync = '1') then
            state <= st_idle;
          end if;

      end case;

    end if;

  end process clock;

  signals : process (clki_i, rst_ni) is
  begin

    if (rst_ni = '0') then
      sr_rst_no  <= '0';
      up_count   <= (others => '0');
      down_count <= (others => '0');
      divider2   <= '0';
      clko_meta  <= '0';
      clko_sync  <= '0';
    elsif (clki_i'event and clki_i = '1') then
      clko_meta <= clko_i;
      clko_sync <= clko_meta;

      if (state = st_c_wait) then
        up_count <= (others => '0');
      elsif (state = st_c_start) then
        up_count <= up_count + 1;
      end if;

      if (state = st_c_wait) then
        down_count <= (others => '0');
      elsif (state = st_c_start and data_i = '1') then
        down_count <= up_count(counter_size - 1 downto 1);
      elsif (state = st_idle) then
        down_count <= up_count(counter_size - 1 downto 1);
      elsif (state = st_data) then
        if (down_count = 1) then
          down_count <= up_count(counter_size - 1 downto 1);
        else
          down_count <= down_count - 1;
        end if;
      end if;

      if (state = st_data) then
        if (down_count = 1) then
          divider2 <= not divider2;
        end if;
      else
        divider2 <= '0';
      end if;

      if (state = st_data) then
        sr_rst_no <= '1';
      else
        sr_rst_no <= '0';
      end if;
    end if;

  end process signals;

end architecture rtl;
