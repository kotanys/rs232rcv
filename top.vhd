library ieee;
  use ieee.std_logic_1164.all;

entity top is
  generic (
    n              : natural := 8;
    end_bits       : natural := 2;
    counter_size   : natural := 14;
    M_timeout_log2 : natural := 4
  );
  port (
    clki_i          : in  std_logic;
    rst_ni          : in  std_logic;
    data_i          : in  std_logic;
    data_out_o      : out std_logic_vector(n - 1 downto 0);
    selected_cnt_o  : out std_logic_vector(1 downto 0); -- TODO generic'ize
	  led_out_o       : out std_logic_vector(6 downto 0);
    err_o           : out std_logic;
    out_en_o        : out std_logic;
    clk0_o          : out std_logic;
    selected_cnt2_o : out std_logic
  );
end entity top;

architecture behavioral of top is

  signal rst_n        : std_logic;
  signal pll_rst      : std_logic;
  signal data_out     : std_logic_vector(n - 1 downto 0);
  signal pkt_done     : std_logic;
  signal clk0         : std_logic;
  signal pll_locked   : std_logic;

begin

  u_rcv : entity work.rs232_receiver(behavioral)
    generic map (
      n              => n,
      end_bits       => end_bits,
      counter_size   => counter_size,
      M_timeout_log2 => M_timeout_log2
    )
    port map (
      clki_i     => clk0,
      rst_ni     => rst_n,
      data_i     => data_i,
      data_out_o => data_out,
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

  u_segled : entity work.segled(rtl)
    generic map (
      active_low => true
    )
    port map (
      clki_i         => clk0,
      rst_ni         => rst_n,
      data_i         => data_out,
      led_o          => led_out_o,
      selected_cnt_o => selected_cnt_o
    );

  data_out_o      <= data_out;
  rst_n           <= rst_ni and pll_locked;
  pll_rst         <= not rst_ni;
  out_en_o        <= pkt_done;
  clk0_o          <= clk0;
  selected_cnt2_o <= '0';

end architecture behavioral;
