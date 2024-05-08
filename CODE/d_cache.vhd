library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity d_cache is
port(	d_in      :in std_logic_vector(31 downto 0);
	    reset     : in std_logic;
	    clk       : in std_logic;
	    dest_reg  : in std_logic_vector(4 downto 0);
	    data_write: in std_logic;
	    d_out     :out std_logic_vector(31 downto 0));
end d_cache;

architecture d_arch of d_cache is

type mem_loc is array(0 to 31) of std_logic_vector(31 downto 0);
signal cach_L: mem_loc;

begin
	d_out <= cach_L(TO_INTEGER(unsigned(dest_reg)));

process(d_in, reset, clk, data_write, dest_reg)
begin
	if(reset ='1') then
		for i in cach_L'range loop
			cach_L(i) <= (others => '0');
		end loop;
	elsif (rising_edge(clk)) then
		if(data_write = '1') then
			cach_L(TO_INTEGER(unsigned(dest_reg))) <= d_in;
		end if;
	end if;
end process;
end d_arch;





