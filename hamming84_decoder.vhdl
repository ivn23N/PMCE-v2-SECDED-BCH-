library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hamming84_decoder is
    port(
    clk          : in  std_logic;
    rst_n        : in  std_logic;
    code_i       : in  std_logic_vector(7 downto 0);
    valid_i      : in  std_logic;
    data_o       : out std_logic_vector(3 downto 0);
    valid_o      : out std_logic;
    single_err_o : out std_logic;
    double_err_o : out std_logic
    );
end entity;

architecture rtl of hamming84_decoder is
    signal c_r         : std_logic_vector(7 downto 0) := (others => '0');
    signal v_r         : std_logic := '0';
    signal corr_r      : std_logic_vector(7 downto 0) := (others => '0');
    signal single_r    : std_logic := '0';
    signal double_r    : std_logic := '0';
    signal valid_out_r : std_logic := '0';
begin
    process(clk)
        variable c         : std_logic_vector(7 downto 0);
        variable s1, s2, s3, s0 : std_logic;
        variable synd_slv  : std_logic_vector(2 downto 0);
        variable synd      : unsigned(2 downto 0);
        variable tmp       : std_logic_vector(7 downto 0);
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                c_r         <= (others => '0');
                v_r         <= '0';
                corr_r      <= (others => '0');
                single_r    <= '0';
                double_r    <= '0';
                valid_out_r <= '0';
            else
                c_r <= code_i;
                v_r <= valid_i;

                c   := c_r;
                tmp := c;

                s1 := c(0) xor c(2) xor c(4) xor c(6);
                s2 := c(1) xor c(2) xor c(5) xor c(6);
                s3 := c(3) xor c(4) xor c(5) xor c(6);
                s0 := c(0) xor c(1) xor c(2) xor c(3) xor
                      c(4) xor c(5) xor c(6) xor c(7);

                synd_slv := s3 & s2 & s1;
                synd     := unsigned(synd_slv);

                single_r <= '0';
                double_r <= '0';

                if v_r = '1' then
                    if (synd = 0) and (s0 = '0') then
                        null;

                    elsif (synd = 0) and (s0 = '1') then
                        tmp(7) := not tmp(7);
                        single_r <= '1';

                    elsif (synd /= 0) and (s0 = '1') then
                        tmp(to_integer(synd)-1) := not tmp(to_integer(synd)-1);
                        single_r <= '1';

                    else
                        double_r <= '1';
                    end if;
                end if;

                corr_r      <= tmp;
                valid_out_r <= v_r;
                
            end if;
        end if;
    end process;

    data_o       <= corr_r(6) & corr_r(5) & corr_r(4) & corr_r(2);
    valid_o      <= valid_out_r;
    single_err_o <= single_r;
    double_err_o <= double_r;

end architecture;

