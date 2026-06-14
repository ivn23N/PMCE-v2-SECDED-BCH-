library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fec_pkg.all;

entity fec_decoder is
    generic (
        FEC_MODE   : natural := FEC_SECDED;
        DATA_WIDTH : natural := SECDED_DATA_W;
        CODE_WIDTH : natural := SECDED_CODE_W
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

architecture rtl of fec_decoder is
begin

    gen_secded : if FEC_MODE = FEC_SECDED generate
        u_dec : entity work.secded_decoder
            generic map (
                DATA_WIDTH => DATA_WIDTH,
                CODE_WIDTH => CODE_WIDTH
            )
            port map (
                clk             => clk,
                rst_n           => rst_n,
                code_i          => code_i,
                valid_i         => valid_i,
                data_o          => data_o,
                valid_o         => valid_o,
                corrected_o     => corrected_o,
                uncorrectable_o => uncorrectable_o
            );
    end generate;

    gen_bch : if FEC_MODE = FEC_BCH generate
        u_dec : entity work.bch_decoder
            generic map (
                DATA_WIDTH  => DATA_WIDTH,
                CODE_WIDTH  => CODE_WIDTH,
                LATENCY_DEC => 4
            )
            port map (
                clk             => clk,
                rst_n           => rst_n,
                code_i          => code_i,
                valid_i         => valid_i,
                data_o          => data_o,
                valid_o         => valid_o,
                corrected_o     => corrected_o,
                uncorrectable_o => uncorrectable_o
            );
    end generate;

    gen_rs : if FEC_MODE = FEC_RS generate
        u_dec : entity work.rs_decoder
            generic map (
                DATA_WIDTH  => DATA_WIDTH,
                CODE_WIDTH  => CODE_WIDTH,
                LATENCY_DEC => 8
            )
            port map (
                clk             => clk,
                rst_n           => rst_n,
                code_i          => code_i,
                valid_i         => valid_i,
                data_o          => data_o,
                valid_o         => valid_o,
                corrected_o     => corrected_o,
                uncorrectable_o => uncorrectable_o
            );
    end generate;

end architecture;
