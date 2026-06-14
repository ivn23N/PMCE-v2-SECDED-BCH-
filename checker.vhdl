library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity checker is
    generic (
        DATA_WIDTH : natural := 4
    );
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        exp_i           : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        got_i           : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_i         : in  std_logic;
        corrected_i     : in  std_logic;
        uncorrectable_i : in  std_logic;
        blocks_o        : out unsigned(31 downto 0);
        corr_o          : out unsigned(31 downto 0);
        uncor_o         : out unsigned(31 downto 0);
        mism_o          : out unsigned(31 downto 0)
    );
end entity;

architecture rtl of checker is

    signal blocks, corr, uncor, mism : unsigned(31 downto 0) := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                blocks <= (others => '0');
                corr   <= (others => '0');
                uncor  <= (others => '0');
                mism   <= (others => '0');
            else
                if valid_i = '1' then
                    blocks <= blocks + 1;
                    if corrected_i = '1' then
                        corr <= corr + 1;
                    end if;
                    if uncorrectable_i = '1' then
                        uncor <= uncor + 1;
                    end if;
                    if got_i /= exp_i then
                        mism <= mism + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

blocks_o <= blocks;
corr_o   <= corr;
uncor_o  <= uncor;
mism_o   <= mism;

end architecture;
