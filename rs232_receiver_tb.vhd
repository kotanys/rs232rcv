library ieee;
  use ieee.std_logic_1164.all;

entity rs232_receiver_tb is
end entity rs232_receiver_tb;

architecture behavioral of rs232_receiver_tb is

  constant n          : natural := 8;
  constant end_bits   : natural := 2;
  constant clk_period : time    := 20 ns;  -- 50 MHz -> 2 Mhz by PLL
  constant bit_time   : time    := 26.04 us; -- 38400 baud

  signal clk     : std_logic;
  signal rst_n   : std_logic;
  signal data_in : std_logic;
  signal data    : std_logic_vector(n - 1 downto 0);
  signal err     : std_logic;
  signal done    : std_logic;
  signal clk0    : std_logic;

begin

  u_tester : entity work.rs232_tester(sim)
    --generic map (
    --  n          => n,
    --  end_bits   => end_bits,
    --  clk_period => clk_period,
    --  bit_time   => bit_time
    --)
    port map (
      clk_o  => clk,
      rst_no => rst_n,
      data_o => data_in,
      data_i => data,
      err_i  => err,
      done_i => done,
      clk0_i => clk0
    );

  u_dut : entity work.rs232_receiver
    --generic map (
    --  n            => n,
    --  end_bits     => end_bits,
    --  counter_size => 8
    --)
    port map (
      clki_i     => clk,
      rst_ni     => rst_n,
      data_i     => data_in,
      data_out_o => data,
      err_o      => err,
      out_en_o   => done,
      clk0_o     => clk0
    );

end architecture behavioral;
