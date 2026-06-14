library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fec_pkg.all;

entity fec_encoder is
    generic (
        FEC_MODE   : natural := FEC_SECDED;
        DATA_WIDTH : natural := SECDED_DATA_W;
        CODE_WIDTH : natural := SECDED_CODE_W
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

architecture rtl of fec_encoder is
begin

    gen_secded : if FEC_MODE = 0 generate
        u_enc : entity work.secded_encoder
            generic map (
                DATA_WIDTH => DATA_WIDTH,
                CODE_WIDTH => CODE_WIDTH
            )
            port map (
                clk     => clk,
                rst_n   => rst_n,
                data_i  => data_i,
                valid_i => valid_i,
                code_o  => code_o,
                valid_o => valid_o
            );
    end generate;

    gen_bch : if FEC_MODE = 1 generate
        u_enc : entity work.bch_encoder
            generic map (
                DATA_WIDTH  => DATA_WIDTH,
                CODE_WIDTH  => CODE_WIDTH,
                LATENCY_ENC => 1
            )
            port map (
                clk     => clk,
                rst_n   => rst_n,
                data_i  => data_i,
                valid_i => valid_i,
                code_o  => code_o,
                valid_o => valid_o
            );
    end generate;

    gen_rs : if FEC_MODE = 2 generate
        u_enc : entity work.rs_encoder
            generic map (
                DATA_WIDTH  => DATA_WIDTH,
                CODE_WIDTH  => CODE_WIDTH,
                LATENCY_ENC => 1
            )
            port map (
                clk     => clk,
                rst_n   => rst_n,
                data_i  => data_i,
                valid_i => valid_i,
                code_o  => code_o,
                valid_o => valid_o
            );
    end generate;

end architecture;
