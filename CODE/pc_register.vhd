library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity pc_register is
port(   address : in std_logic_vector(31 downto 0);
      	reset	: in std_logic;
      	clk	: in std_logic;
      	pc_out	: out std_logic_vector(31 downto 0));
end pc_register;

architecture pc_reg_arch of pc_register is

begin
	process(address, reset, clk)
	begin
		if (reset = '1') then
			pc_out <= X"00000000";

		elsif( rising_edge(clk) ) then
			pc_out <= address;
		end if;
	end process;
end pc_reg_arch;
