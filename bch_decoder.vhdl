library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bch_pkg.all;

entity bch_decoder is
    generic (
        DATA_WIDTH  : natural := 7;
        CODE_WIDTH  : natural := 15;
        LATENCY_DEC : natural := 4
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

architecture rtl of bch_decoder is

    constant CHECK_WIDTHS : boolean :=
        (DATA_WIDTH = 7) and (CODE_WIDTH = 15) and (LATENCY_DEC = 4);

    --registros
    signal s1_code  : std_logic_vector(14 downto 0) := (others => '0');
    signal s1_valid : std_logic := '0';

    signal s2_code  : std_logic_vector(14 downto 0) := (others => '0');
    signal s2_synd  : std_logic_vector(7 downto 0)  := (others => '0');
    signal s2_valid : std_logic := '0';

    signal s3_code        : std_logic_vector(14 downto 0) := (others => '0');
    signal s3_err_pattern : std_logic_vector(14 downto 0) := (others => '0');
    signal s3_uncor       : std_logic := '0';
    signal s3_synd_nz     : std_logic := '0';
    signal s3_valid       : std_logic := '0';

    --Salidas
    signal s4_data  : std_logic_vector(6 downto 0) := (others => '0');
    signal s4_corr  : std_logic := '0';
    signal s4_uncor : std_logic := '0';
    signal s4_valid : std_logic := '0';

begin
    assert CHECK_WIDTHS
        report "bch_decoder: requiere DATA_WIDTH=7, CODE_WIDTH=15, LATENCY_DEC=4"
        severity failure;

    stage1 : process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                s1_code  <= (others => '0');
                s1_valid <= '0';
            else
                s1_code  <= code_i;
                s1_valid <= valid_i;
            end if;
        end if;
    end process;

    stage2 : process(clk)
        variable v_synd : std_logic_vector(7 downto 0);
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                s2_code  <= (others => '0');
                s2_synd  <= (others => '0');
                s2_valid <= '0';
            else
                v_synd(0) := s1_code(0) xor s1_code(8) xor s1_code(9)  xor s1_code(11);
                v_synd(1) := s1_code(1) xor s1_code(9) xor s1_code(10) xor s1_code(12);
                v_synd(2) := s1_code(2) xor s1_code(10) xor s1_code(11) xor s1_code(13);
                v_synd(3) := s1_code(3) xor s1_code(11) xor s1_code(12) xor s1_code(14);
                v_synd(4) := s1_code(4) xor s1_code(8) xor s1_code(9)  xor s1_code(11) xor s1_code(12) xor s1_code(13);
                v_synd(5) := s1_code(5) xor s1_code(9) xor s1_code(10) xor s1_code(12) xor s1_code(13) xor s1_code(14);
                v_synd(6) := s1_code(6) xor s1_code(8) xor s1_code(9)  xor s1_code(10) xor s1_code(13) xor s1_code(14);
                v_synd(7) := s1_code(7) xor s1_code(8) xor s1_code(10) xor s1_code(14);

                s2_code  <= s1_code;
                s2_synd  <= v_synd;
                s2_valid <= s1_valid;
            end if;
        end if;
    end process;

    stage3 : process(clk)
        variable v_lut_word : std_logic_vector(15 downto 0);
        variable v_synd_nz  : std_logic;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                s3_code        <= (others => '0');
                s3_err_pattern <= (others => '0');
                s3_uncor       <= '0';
                s3_synd_nz     <= '0';
                s3_valid       <= '0';
            else
                v_lut_word := BCH_LUT(to_integer(unsigned(s2_synd)));

                if s2_synd = "00000000" then
                    v_synd_nz := '0';
                else
                    v_synd_nz := '1';
                end if;

                s3_code        <= s2_code;
                s3_err_pattern <= v_lut_word(14 downto 0);
                s3_uncor       <= v_lut_word(15);
                s3_synd_nz     <= v_synd_nz;
                s3_valid       <= s2_valid;
            end if;
        end if;
    end process;

    stage4 : process(clk)
        variable v_corrected_code : std_logic_vector(14 downto 0);
        variable v_data           : std_logic_vector(6 downto 0);
        variable v_corr           : std_logic;
        variable v_uncor          : std_logic;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                s4_data  <= (others => '0');
                s4_corr  <= '0';
                s4_uncor <= '0';
                s4_valid <= '0';
            else
                --No corregible
                if s3_uncor = '1' then
                    v_corrected_code := s3_code;
                else
                    v_corrected_code := s3_code xor s3_err_pattern;
                end if;

                v_data  := v_corrected_code(14 downto 8);
                v_corr  := s3_synd_nz and (not s3_uncor);
                v_uncor := s3_uncor;

                s4_data  <= v_data;
                s4_corr  <= v_corr;
                s4_uncor <= v_uncor;
                s4_valid <= s3_valid;
            end if;
        end if;
    end process;

data_o          <= s4_data;
valid_o         <= s4_valid;
corrected_o     <= s4_corr;
uncorrectable_o <= s4_uncor;

end architecture;
