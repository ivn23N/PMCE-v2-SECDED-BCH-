library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hamming84_encoder is
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    data_i  : in  std_logic_vector(3 downto 0);
    valid_i : in  std_logic;
    code_o  : out std_logic_vector(7 downto 0);
    valid_o : out std_logic
  );
end entity;

architecture rtl of hamming84_encoder is

  signal code_r  : std_logic_vector(7 downto 0) := (others => '0');
  signal valid_r : std_logic := '0';

begin

  process(clk)
    variable d0  : std_logic;
    variable d1  : std_logic;
    variable d2  : std_logic;
    variable d3  : std_logic;

    variable p1  : std_logic;
    variable p2  : std_logic;
    variable p3  : std_logic;
    variable p0  : std_logic;

    variable tmp : std_logic_vector(7 downto 0);
  begin
    if rising_edge(clk) then
      if rst_n = '0' then

        code_r  <= (others => '0');
        valid_r <= '0';

      else

        valid_r <= valid_i;

        if valid_i = '1' then

          d0 := data_i(0);
          d1 := data_i(1);
          d2 := data_i(2);
          d3 := data_i(3);

          p1 := d0 xor d1 xor d3;
          p2 := d0 xor d2 xor d3;
          p3 := d1 xor d2 xor d3;

          tmp(0) := p1;
          tmp(1) := p2;
          tmp(2) := d0;
          tmp(3) := p3;
          tmp(4) := d1;
          tmp(5) := d2;
          tmp(6) := d3;

          p0 := tmp(0) xor tmp(1) xor tmp(2) xor tmp(3) xor
                tmp(4) xor tmp(5) xor tmp(6);

          tmp(7) := p0;

          code_r <= tmp;

        end if;

      end if;
    end if;
  end process;

  code_o  <= code_r;
  valid_o <= valid_r;

end architecture;
