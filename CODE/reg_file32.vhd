library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.all;


entity regfile_32 is
port( din           : in std_logic_vector(31 downto 0);
      reset         : in std_logic;
      clk           : in std_logic;
      write_en      : in std_logic;
      read_a        : in std_logic_vector(4 downto 0);
      read_b        : in std_logic_vector(4 downto 0);
      write_address : in std_logic_vector(4 downto 0);
      out_a         : out std_logic_vector(31 downto 0);
      out_b         : out std_logic_vector(31 downto 0));
end regfile_32;

architecture regfile of regfile_32 is

type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);

signal regs : reg_array;

begin
	out_a <= regs(TO_INTEGER(unsigned(read_a)));
	out_b <= regs(TO_INTEGER(unsigned(read_b)));

process(clk,reset, din, write_en, write_address)
begin
	if(reset = '1') then
		regs <= (others => (others => '0'));
	elsif (clk ' event and clk = '1') then
		if(write_en = '1') then
			regs(TO_INTEGER(unsigned(write_address))) <= din;
		end if;
	end if;
end process;
end regfile;
