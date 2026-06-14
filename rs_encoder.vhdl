library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rs_encoder is
    generic (
        DATA_WIDTH  : natural := 44;
        CODE_WIDTH  : natural := 60;
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

architecture stub of rs_encoder is

    type code_array_t is array (natural range <>) of std_logic_vector(CODE_WIDTH-1 downto 0);
    signal code_pipe  : code_array_t(0 to LATENCY_ENC-1) := (others => (others => '0'));
    signal valid_pipe : std_logic_vector(0 to LATENCY_ENC-1) := (others => '0');

    signal code_comb : std_logic_vector(CODE_WIDTH-1 downto 0);

begin

    process(data_i)
        variable v : std_logic_vector(CODE_WIDTH-1 downto 0);
    begin
        v := (others => '0');
        v(DATA_WIDTH-1 downto 0) := data_i;
        code_comb <= v;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                for i in 0 to LATENCY_ENC-1 loop
                    code_pipe(i)  <= (others => '0');
                    valid_pipe(i) <= '0';
                end loop;
            else
                code_pipe(0)  <= code_comb;
                valid_pipe(0) <= valid_i;
                for i in 1 to LATENCY_ENC-1 loop
                    code_pipe(i)  <= code_pipe(i-1);
                    valid_pipe(i) <= valid_pipe(i-1);
                end loop;
            end if;
        end if;
    end process;

    code_o  <= code_pipe(LATENCY_ENC-1);
    valid_o <= valid_pipe(LATENCY_ENC-1);

end architecture;
