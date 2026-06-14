library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fec_pkg is

    constant FEC_SECDED : natural := 0;
    constant FEC_BCH    : natural := 1;
    constant FEC_RS     : natural := 2;

    constant SECDED_DATA_W  : natural := 4;
    constant SECDED_CODE_W  : natural := 8;
    constant SECDED_LATENCY : natural := 5;

    constant BCH_DATA_W  : natural := 7;
    constant BCH_CODE_W  : natural := 15;
    constant BCH_LATENCY : natural := 7;

    constant RS_SYMBOL_W : natural := 4;
    constant RS_N        : natural := 15;
    constant RS_K        : natural := 11;
    constant RS_DATA_W   : natural := RS_K * RS_SYMBOL_W;  -- 44
    constant RS_CODE_W   : natural := RS_N * RS_SYMBOL_W;  -- 60
    constant RS_LATENCY  : natural := 11;  -- enc(1) + inj(2) + dec(8) = 11

    function get_data_width  (mode : natural) return natural;
    function get_code_width  (mode : natural) return natural;
    function get_latency     (mode : natural) return natural;
    function get_symbol_width(mode : natural) return natural;

end package fec_pkg;


package body fec_pkg is

    function get_data_width(mode : natural) return natural is
    begin
        case mode is
            when FEC_SECDED => return SECDED_DATA_W;
            when FEC_BCH    => return BCH_DATA_W;
            when FEC_RS     => return RS_DATA_W;
            when others     => return SECDED_DATA_W;
        end case;
    end function;

    function get_code_width(mode : natural) return natural is
    begin
        case mode is
            when FEC_SECDED => return SECDED_CODE_W;
            when FEC_BCH    => return BCH_CODE_W;
            when FEC_RS     => return RS_CODE_W;
            when others     => return SECDED_CODE_W;
        end case;
    end function;

    function get_latency(mode : natural) return natural is
    begin
        case mode is
            when FEC_SECDED => return SECDED_LATENCY;
            when FEC_BCH    => return BCH_LATENCY;
            when FEC_RS     => return RS_LATENCY;
            when others     => return SECDED_LATENCY;
        end case;
    end function;

    function get_symbol_width(mode : natural) return natural is
    begin
        case mode is
            when FEC_SECDED => return 1;
            when FEC_BCH    => return 1;
            when FEC_RS     => return 1;  --futuro
            when others     => return 1;
        end case;
    end function;
