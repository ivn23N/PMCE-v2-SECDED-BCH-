library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fault_injector is
    generic (
        CODE_WIDTH    : natural := 8;
        SYMBOL_WIDTH  : natural := 1;
        SINGLE_PERIOD : natural := 8;
        DOUBLE_PERIOD : natural := 16;
        BIT1          : natural := 2;
        BIT2          : natural := 5
    );
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        code_i   : in  std_logic_vector(CODE_WIDTH-1 downto 0);
        valid_i  : in  std_logic;
        code_o   : out std_logic_vector(CODE_WIDTH-1 downto 0);
        valid_o  : out std_logic;
        single_o : out std_logic;
        double_o : out std_logic
    );
end entity;

architecture rtl of fault_injector is

    signal code_i_r  : std_logic_vector(CODE_WIDTH-1 downto 0) := (others => '0');
    signal valid_i_r : std_logic := '0';

    signal cnt       : unsigned(15 downto 0) := (others => '0');

    signal code_r    : std_logic_vector(CODE_WIDTH-1 downto 0) := (others => '0');
    signal valid_r   : std_logic := '0';
    signal single_r  : std_logic := '0';
    signal double_r  : std_logic := '0';

    function is_period(hit_period : natural; v : unsigned) return boolean is
    begin
        if hit_period = 0 then
            return false;
        else
            return (to_integer(v) mod hit_period) = 0;
        end if;
    end function;

begin

    stage1 : process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                code_i_r  <= (others => '0');
                valid_i_r <= '0';
            else
                code_i_r  <= code_i;
                valid_i_r <= valid_i;
            end if;
        end if;
    end process;

    stage2 : process(clk)
        variable v_cnt_next : unsigned(15 downto 0);
        variable v_do_s     : std_logic;
        variable v_do_d     : std_logic;
        variable v_mask     : std_logic_vector(CODE_WIDTH-1 downto 0);
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                cnt      <= (others => '0');
                code_r   <= (others => '0');
                valid_r  <= '0';
                single_r <= '0';
                double_r <= '0';
            else
                v_cnt_next := cnt;
                v_do_s     := '0';
                v_do_d     := '0';
                v_mask     := (others => '0');

                if valid_i_r = '1' then
                    v_cnt_next := cnt + 1;
                    if is_period(SINGLE_PERIOD, v_cnt_next) then v_do_s := '1'; end if;
                    if is_period(DOUBLE_PERIOD, v_cnt_next) then v_do_d := '1'; end if;

                    if v_do_d = '1' then
                        v_do_s := '0';
                        if BIT1 < CODE_WIDTH then v_mask(BIT1) := '1'; end if;
                        if BIT2 < CODE_WIDTH then v_mask(BIT2) := '1'; end if;
                    elsif v_do_s = '1' then
                        if BIT1 < CODE_WIDTH then v_mask(BIT1) := '1'; end if;
                    end if;

                    code_r   <= code_i_r xor v_mask;
                    valid_r  <= '1';
                    single_r <= v_do_s;
                    double_r <= v_do_d;
                    cnt      <= v_cnt_next;
                else
                    code_r   <= code_i_r;
                    valid_r  <= '0';
                    single_r <= '0';
                    double_r <= '0';
                end if;
            end if;
        end if;
    end process;

code_o   <= code_r;
valid_o  <= valid_r;
single_o <= single_r;
double_o <= double_r;

end architecture;
