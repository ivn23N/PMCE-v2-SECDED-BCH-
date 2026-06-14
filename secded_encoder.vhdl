library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity secded_encoder is
    generic (
        DATA_WIDTH : natural := 4;
        CODE_WIDTH : natural := 8
    );
    port (
        clk     : in  std_logic;
        rst_n   : in  std_logic;
        data_i  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_i : in  std_logic;
        code_o  : out std_logic_vector(CODE_WIDTH-1 downto 0);
        valid_o : out std_logic
    );
end entity;

architecture rtl of secded_encoder is

begin


    u_enc : entity work.hamming84_encoder
        port map (
            clk     => clk,
            rst_n   => rst_n,
            data_i  => data_i,
            valid_i => valid_i,
            code_o  => code_o,
            valid_o => valid_o
        );

end architecture;
