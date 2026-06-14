library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delay_line is
    generic (
        DATA_WIDTH : natural := 4;
        LATENCY    : natural := 4
    );
    port (
        clk     : in  std_logic;
        rst_n   : in  std_logic;
        data_i  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_i : in  std_logic;
        data_o  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_o : out std_logic
    );
end entity;

architecture rtl of delay_line is

    type data_array_t is array (natural range <>) of std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    assert LATENCY >= 1
        report "delay_line: LATENCY debe ser >= 1"
        severity warning;

    gen_passthrough : if LATENCY = 0 generate
        data_o  <= data_i;
        valid_o <= valid_i;
    end generate;

    gen_pipe : if LATENCY >= 1 generate
        signal data_pipe  : data_array_t(0 to LATENCY-1) := (others => (others => '0'));
        signal valid_pipe : std_logic_vector(0 to LATENCY-1) := (others => '0');
    begin
        process(clk)
        begin
            if rising_edge(clk) then
                if rst_n = '0' then
                    for i in 0 to LATENCY-1 loop
                        data_pipe(i)  <= (others => '0');
                        valid_pipe(i) <= '0';
                    end loop;
                else
                    data_pipe(0)  <= data_i;
                    valid_pipe(0) <= valid_i;
                    for i in 1 to LATENCY-1 loop
                        data_pipe(i)  <= data_pipe(i-1);
                        valid_pipe(i) <= valid_pipe(i-1);
                    end loop;
                end if;
            end if;
        end process;

        data_o  <= data_pipe(LATENCY-1);
        valid_o <= valid_pipe(LATENCY-1);
        
    end generate;
