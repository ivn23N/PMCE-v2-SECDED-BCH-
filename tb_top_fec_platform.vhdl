library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.fec_pkg.all;

entity tb_top_fec_platform is
end entity;

architecture sim of tb_top_fec_platform is

    constant SEL : natural := FEC_BCH;
    --FEC_BCH;
    --FEC_SECDED;

    constant DW  : natural := get_data_width(SEL);
    constant LAT : natural := get_latency(SEL);

    constant N_BLOCKS    : natural := 64;
    constant SINGLE_PER  : natural := 8;
    constant DOUBLE_PER  : natural := 16;
    constant BIT1_INJ    : natural := 2;
    constant BIT2_INJ    : natural := 5;

    function exp_corr(mode : natural) return natural is
    begin
        case mode is
            when FEC_SECDED => return 4;
            when FEC_BCH    => return 8; 
            when others     => return 0;  
        end case;
    end function;

    function exp_uncor(mode : natural) return natural is
    begin
        case mode is
            when FEC_SECDED => return 4;
            when FEC_BCH    => return 0;
            when others     => return 0;
        end case;
    end function;

    constant CLK_PERIOD : time := 10 ns;

    signal clk      : std_logic := '0';
    signal rst_n    : std_logic := '0';

    signal data_i   : std_logic_vector(63 downto 0) := (others => '0');
    signal valid_i  : std_logic := '0';

    signal blocks_o : unsigned(31 downto 0);
    signal corr_o   : unsigned(31 downto 0);
    signal uncor_o  : unsigned(31 downto 0);
    signal mism_o   : unsigned(31 downto 0);

    signal sim_done : boolean := false;

begin

    dut : entity work.top_fec_platform
        generic map (
            FEC_MODE      => SEL,
            SINGLE_PERIOD => SINGLE_PER,
            DOUBLE_PERIOD => DOUBLE_PER,
            BIT1          => BIT1_INJ,
            BIT2          => BIT2_INJ
        )
        port map (
            clk      => clk,
            rst_n    => rst_n,
            data_i   => data_i,
            valid_i  => valid_i,
            blocks_o => blocks_o,
            corr_o   => corr_o,
            uncor_o  => uncor_o,
            mism_o   => mism_o
        );

    clk_proc : process
    begin
        clk <= '0';
        while not sim_done loop
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
            clk <= '0';
        end loop;
        wait;
    end process;

    stim_proc : process
        variable cnt : unsigned(63 downto 0) := (others => '0');
        variable l   : line;
        variable ok  : boolean := true;
    begin
        --Reset
        rst_n   <= '0';
        valid_i <= '0';
        data_i  <= (others => '0');

        for i in 0 to 9 loop
            wait until rising_edge(clk);
        end loop;

        rst_n <= '1';
        wait until rising_edge(clk);

        --Enviar valid_i
        for i in 0 to N_BLOCKS-1 loop
            data_i  <= std_logic_vector(cnt);
            valid_i <= '1';
            cnt     := cnt + 1;
            wait until rising_edge(clk);
        end loop;

        valid_i <= '0';
        data_i  <= (others => '0');
        wait until rising_edge(clk);

        --Latencia
        for i in 0 to LAT + 20 loop
            wait until rising_edge(clk);
        end loop;


        sim_done <= true;
        wait;
    end process;

end architecture;
