library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity secded_decoder is
    generic (
        DATA_WIDTH : natural := 4;
        CODE_WIDTH : natural := 8
    );
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        code_i          : in  std_logic_vector(CODE_WIDTH-1 downto 0);
        valid_i         : in  std_logic;
        data_o          : out std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_o         : out std_logic;
        corrected_o     : out std_logic;
        uncorrectable_o : out std_logic
    );
end entity;

architecture rtl of secded_decoder is

begin
    u_dec : entity work.hamming84_decoder
        port map (
            clk          => clk,
            rst_n        => rst_n,
            code_i       => code_i,
            valid_i      => valid_i,
            data_o       => data_o,
            valid_o      => valid_o,
            single_err_o => corrected_o,
            double_err_o => uncorrectable_o
        );

end architecture;
