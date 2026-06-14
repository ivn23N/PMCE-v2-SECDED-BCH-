library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bch_encoder is
    generic (
        DATA_WIDTH  : natural := 7;
        CODE_WIDTH  : natural := 15;
        LATENCY_ENC : natural := 1
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

architecture rtl of bch_encoder is

    constant CHECK_WIDTHS : boolean :=
        (DATA_WIDTH = 7) and (CODE_WIDTH = 15) and (LATENCY_ENC = 1);

    signal code_r  : std_logic_vector(CODE_WIDTH-1 downto 0) := (others => '0');
    signal valid_r : std_logic := '0';

begin

    assert CHECK_WIDTHS
        report "bch_encoder: requiere DATA_WIDTH=7, CODE_WIDTH=15, LATENCY_ENC=1"
        severity failure;

    process(clk)
        variable d : std_logic_vector(6 downto 0);
        variable p : std_logic_vector(7 downto 0);
        variable c : std_logic_vector(14 downto 0);
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                code_r  <= (others => '0');
                valid_r <= '0';
            else
                valid_r <= valid_i;
                if valid_i = '1' then
                    d := data_i;

                    --Paridad
                    p(0) := d(0) xor d(1) xor d(3);
                    p(1) := d(1) xor d(2) xor d(4);
                    p(2) := d(2) xor d(3) xor d(5);
                    p(3) := d(3) xor d(4) xor d(6);
                    p(4) := d(0) xor d(1) xor d(3) xor d(4) xor d(5);
                    p(5) := d(1) xor d(2) xor d(4) xor d(5) xor d(6);
                    p(6) := d(0) xor d(1) xor d(2) xor d(5) xor d(6);
                    p(7) := d(0) xor d(2) xor d(6);

                    c(14 downto 8) := d;
                    c(7 downto 0)  := p;

                    code_r <= c;
                end if;
            end if;
        end if;
    end process;
