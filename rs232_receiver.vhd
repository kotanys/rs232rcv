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
    clko_o     : out std_logic
  );
end entity rs232_receiver;

architecture behavioral of rs232_receiver is

  signal internal_clk : std_logic;
  signal sr_rst_n     : std_logic;
  signal pkt_done     : std_logic;

begin

  u_clock : entity work.rs232_clock(rtl)
    generic map (
      counter_size => counter_size
    )
    port map (
      data_i         => data_i,
      rst_ni         => rst_ni,
      clki_i         => clki_i,
      clko_i         => pkt_done,
      internal_clk_o => internal_clk,
      sr_rst_no      => sr_rst_n
    );

  u_reader : entity work.rs232_reader(rtl)
    generic map (
      n        => n,
      end_bits => end_bits
    )
    port map (
      data_in_i      => data_i,
      internal_clk_i => internal_clk,
      rst_ni         => sr_rst_n,
      data_out_o     => data_out_o,
      clko_o         => pkt_done,
      err_o          => err_o
    );

  clko_o <= pkt_done;

end architecture behavioral;
