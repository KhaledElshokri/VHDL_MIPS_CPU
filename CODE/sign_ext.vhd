library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity sign_ext is
port(input16   : in std_logic_vector(15 downto 0);
	 func_slct : in std_logic_vector(1 downto 0);
	 output32  : out std_logic_vector(31 downto 0));
end sign_ext;

architecture ext_arch of sign_ext is

begin
	process(input16, func_slct)
	begin 
		case func_slct is
			when "00"
				=> output32 <= input16(15 downto 0) & X"0000"; --lui
			when "11"
				=> output32 <= X"0000" & input16(15 downto 0); --logical
			when "01" | "10" 
				=> output32 <= (31 downto 16 => input16(15)) & input16(15 downto 0); --slti, arith
			when others =>
		end case;
	end process;
end ext_arch;
