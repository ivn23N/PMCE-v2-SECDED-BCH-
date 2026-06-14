library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fec_pkg.all;

entity top_fec_platform is
    generic (
        FEC_MODE      : natural := FEC_SECDED;

        DATA_WIDTH    : natural := 0;
        CODE_WIDTH    : natural := 0;
        TOTAL_LATENCY : natural := 0;

        SINGLE_PERIOD : natural := 8;
        DOUBLE_PERIOD : natural := 16;
        BIT1          : natural := 2;
        BIT2          : natural := 5
    );
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        data_i   : in  std_logic_vector(63 downto 0);  
        valid_i  : in  std_logic;
        blocks_o : out unsigned(31 downto 0);
        corr_o   : out unsigned(31 downto 0);
        uncor_o  : out unsigned(31 downto 0);
        mism_o   : out unsigned(31 downto 0)
    );
end entity;

architecture rtl of top_fec_platform is

    function resolve(override : natural; default_v : natural) return natural is
    begin
        if override = 0 then
            return default_v;
        else
            return override;
        end if;
    end function;

    constant DW  : natural := resolve(DATA_WIDTH,    get_data_width(FEC_MODE));
    constant CW  : natural := resolve(CODE_WIDTH,    get_code_width(FEC_MODE));
    constant LAT : natural := resolve(TOTAL_LATENCY, get_latency(FEC_MODE));
    constant SW  : natural := get_symbol_width(FEC_MODE);

    signal data_in     : std_logic_vector(DW-1 downto 0);

    signal code_enc    : std_logic_vector(CW-1 downto 0);
    signal v_enc       : std_logic;

    signal code_ch     : std_logic_vector(CW-1 downto 0);
    signal v_ch        : std_logic;

    signal data_dec    : std_logic_vector(DW-1 downto 0);
    signal v_dec       : std_logic;
    signal corrected   : std_logic;
    signal uncorrect   : std_logic;

    signal exp_data    : std_logic_vector(DW-1 downto 0);
    signal exp_valid   : std_logic;

begin

    data_in <= data_i(DW-1 downto 0);

    u_enc : entity work.fec_encoder
        generic map (
            FEC_MODE   => FEC_MODE,
            DATA_WIDTH => DW,
            CODE_WIDTH => CW
        )
        port map (
            clk     => clk,
            rst_n   => rst_n,
            data_i  => data_in,
            valid_i => valid_i,
            code_o  => code_enc,
            valid_o => v_enc
        );

    u_inj : entity work.fault_injector
        generic map (
            CODE_WIDTH    => CW,
            SYMBOL_WIDTH  => SW,
            SINGLE_PERIOD => SINGLE_PERIOD,
            DOUBLE_PERIOD => DOUBLE_PERIOD,
            BIT1          => BIT1,
            BIT2          => BIT2
        )
        port map (
            clk      => clk,
            rst_n    => rst_n,
            code_i   => code_enc,
            valid_i  => v_enc,
            code_o   => code_ch,
            valid_o  => v_ch,
            single_o => open,
            double_o => open
        );

    u_dec : entity work.fec_decoder
        generic map (
            FEC_MODE   => FEC_MODE,
            DATA_WIDTH => DW,
            CODE_WIDTH => CW
        )
        port map (
            clk             => clk,
            rst_n           => rst_n,
            code_i          => code_ch,
            valid_i         => v_ch,
            data_o          => data_dec,
            valid_o         => v_dec,
            corrected_o     => corrected,
            uncorrectable_o => uncorrect
        );

    u_delay : entity work.delay_line
        generic map (
            DATA_WIDTH => DW,
            LATENCY    => LAT
        )
        port map (
            clk     => clk,
            rst_n   => rst_n,
            data_i  => data_in,
            valid_i => valid_i,
            data_o  => exp_data,
            valid_o => exp_valid
        );

    u_chk : entity work.checker
        generic map (
            DATA_WIDTH => DW
        )
        port map (
            clk             => clk,
            rst_n           => rst_n,
            exp_i           => exp_data,
            got_i           => data_dec,
            valid_i         => v_dec,
            corrected_i     => corrected,
            uncorrectable_i => uncorrect,
            blocks_o        => blocks_o,
            corr_o          => corr_o,
            uncor_o         => uncor_o,
            mism_o          => mism_o
        );

end architecture;
