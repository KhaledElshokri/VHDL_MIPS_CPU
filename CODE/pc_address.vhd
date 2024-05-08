library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity next_address is
port ( rt, rs: in std_logic_vector(31 downto 0);
       pc : in std_logic_vector(31 downto 0);
       target_address : in std_logic_vector(25 downto 0);
       branch_type : in std_logic_vector(1 downto 0);
       pc_sel : in std_logic_vector(1 downto 0);
       next_pc : out std_logic_vector(31 downto 0));
end next_address;

architecture pc_address of next_address is

signal pc_temp: std_logic_vector(31 downto 0);

begin

process(rt, rs, pc, pc_sel, branch_type, target_address, pc_temp)
begin

	if(pc_sel = "00") then
		next_pc <= pc_temp;
	elsif(pc_sel = "01") then
		next_pc <= "000000" & target_address(25 downto 0);
	elsif(pc_sel = "10") then
		next_pc <= rs;
	else
		next_pc <= pc;
	end if;	

	case branch_type is

		when "00" => pc_temp <= pc + X"00000001";
		when "01" =>
			if(rs = rt) then 
				pc_temp <= pc + X"00000001" + ((31 downto 16 => target_address(15)) & target_address(15 downto 0));
			else
				pc_temp <= pc + X"00000001";
			end if;
		when "10" => 
			if(rs /= rt) then 
				pc_temp <= pc + X"00000001" + ((31 downto 16 => target_address(15)) & target_address(15 downto 0));
			else
				pc_temp <= pc + X"00000001";
			end if;
		when "11" => 
			if(rs < 0) then 
				pc_temp <= pc + X"00000001" + ((31 downto 16 => target_address(15)) & target_address(15 downto 0));
			else
				pc_temp <= pc + X"00000001";		
			end if;
		when others =>
	end case;
end process;

end pc_address;
	


























