library ieee;
  use ieee.std_logic_1164.all;

entity rs232_receiver is
  generic (
    n            : natural := 8;
    end_bits     : natural := 2;
    counter_size : natural := 8
  );
  port (
    clki_i     : in  std_logic;
    rst_ni     : in  std_logic;
    data_i     : in  std_logic;
    data_out_o : out std_logic_vector(n - 1 downto 0);
    err_o      : out std_logic;
    out_en_o   : out std_logic;
    clk0_o     : out std_logic
  );
end entity rs232_receiver;

architecture behavioral of rs232_receiver is

  signal sr_en      : std_logic;
  signal rst_n      : std_logic;
  signal pll_rst    : std_logic;
  signal pkt_done   : std_logic;
  signal clk0       : std_logic;
  signal pll_locked : std_logic;
  signal data_sync  : std_logic;

begin

  u_clock : entity work.rs232_clock(rtl)
    generic map (
      counter_size => counter_size
    )
    port map (
      clki_i      => clk0,
      rst_ni      => rst_n,
      data_i      => data_i,

      out_en_i    => pkt_done,
      sr_en_o     => sr_en,
      data_sync_o => data_sync
    );

  u_reader : entity work.rs232_reader(rtl)
    generic map (
      n        => n,
      end_bits => end_bits
    )
    port map (
      clki_i     => clk0,
      rst_ni     => rst_n,
      data_in_i  => data_sync,

      sr_en_i    => sr_en,
      data_out_o => data_out_o,
      out_en_o   => pkt_done,
      err_o      => err_o
    );

  u_pll : entity work.rs232_pll(syn)
    port map (
      areset => pll_rst,
      inclk0 => clki_i,
      c0     => clk0,
      locked => pll_locked
    );

  rst_n    <= rst_ni and pll_locked;
  pll_rst  <= not rst_ni;
  out_en_o <= pkt_done;
  clk0_o   <= clk0;

end architecture behavioral;
