library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rs_decoder is
    generic (
        DATA_WIDTH  : natural := 44;
        CODE_WIDTH  : natural := 60;
        LATENCY_DEC : natural := 8
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

architecture stub of rs_decoder is

    type data_array_t is array (natural range <>) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_pipe  : data_array_t(0 to LATENCY_DEC-1) := (others => (others => '0'));
    signal valid_pipe : std_logic_vector(0 to LATENCY_DEC-1) := (others => '0');

    signal data_comb : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    data_comb <= code_i(DATA_WIDTH-1 downto 0);

    process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                for i in 0 to LATENCY_DEC-1 loop
                    data_pipe(i)  <= (others => '0');
                    valid_pipe(i) <= '0';
                end loop;
            else
                data_pipe(0)  <= data_comb;
                valid_pipe(0) <= valid_i;
                for i in 1 to LATENCY_DEC-1 loop
                    data_pipe(i)  <= data_pipe(i-1);
                    valid_pipe(i) <= valid_pipe(i-1);
                end loop;
            end if;
        end if;
    end process;

    data_o          <= data_pipe(LATENCY_DEC-1);
    valid_o         <= valid_pipe(LATENCY_DEC-1);
    corrected_o     <= '0';
    uncorrectable_o <= '0';

end architecture;
