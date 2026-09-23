library ieee;
  use ieee.std_logic_1164.all;

entity rs232_reader is
  generic (
    n        : natural := 8;
    end_bits : natural := 2
  );
  port (
    data_in_i      : in    std_logic;
    internal_clk_i : in    std_logic;
    rst_ni         : in    std_logic;
    data_out_o     : out   std_logic_vector(n - 1 downto 0);
    clko_o         : out   std_logic;
    err_o          : out   std_logic
  );
end entity rs232_reader;

architecture rtl of rs232_reader is

  signal read_sr : std_logic_vector(n + end_bits downto 0);
  signal clko    : std_logic;

begin

  clko   <= not read_sr(n + end_bits);
  clko_o <= clko;

  clock : process (internal_clk_i, rst_ni) is
  begin

    if (rst_ni = '0') then
      read_sr <= (others => '1');
    elsif (internal_clk_i'event and internal_clk_i = '1') then
      read_sr <= read_sr(n + end_bits - 1 downto 0) & data_in_i;
    end if;

  end process clock;

  data_out : process (clko) is
  begin

    if (clko = '1') then
      data_out_o <= read_sr(n + end_bits - 1 downto end_bits);
      -- all end bits must be ones
      if (read_sr(end_bits - 1 downto 0) = (read_sr(end_bits - 1 downto 0)'range => '1')) then
        err_o <= '0';
      else
        err_o <= '1';
      end if;
    end if;

  end process data_out;

end architecture rtl;
