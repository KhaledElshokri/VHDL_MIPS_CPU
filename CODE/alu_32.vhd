library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity alu is
port(x, y : std_logic_vector(31 downto 0);
	add_sub : in std_logic ;
	logic_func : in std_logic_vector(1 downto 0); -- 00 = AND, 01 = OR , 10 = XOR , 11 = NOR
    func : in std_logic_vector(1 downto 0 ) ; -- 00 = lui, 01 = setless , 10 = arith , 11 = logic
   	output : out std_logic_vector(31 downto 0) ; -- Operation Output
   	overflow : out std_logic ; -- 1 when an overflow is detected
   	zero : out std_logic); -- 1 when the result of the operation is 0
end alu;

architecture alu_32bit of alu is 

-- Intermidiate signals (Connections) --
signal logic_unit_out : std_logic_vector(31 downto 0);
constant zero_concat : std_logic_vector(30 downto 0) := (others => '0');
signal adder_substract_out : std_logic_vector(31 downto 0);
signal x_less_than_y : std_logic_vector(31 downto 0);

begin
--Set Less than zero Unit--
  x_less_than_y <= x - y;

--Adder/Substract Unit--
  with add_sub select 
       adder_substract_out <= (x + y) when '0',
                              (x - y) when others;
--Logic Unit--
  with logic_func select
		logic_unit_out <= (x and y) when "00",
		                  (x or y) when "01",
			              (x xor y) when "10",
			              (x nor y) when others;

--Main Output Unit--
process(y, x_less_than_y, adder_substract_out, logic_unit_out, func)
begin
   if(func = "00") then    
      output <= y;
	  
   elsif (func = "01") then 
      output <= zero_concat & x_less_than_y(31);
	  
   elsif (func = "10") then 
      output <= adder_substract_out;
	  
   else 
      output <= logic_unit_out;
  end if;
end process;

--Overflow Unit--
process(x, y, adder_substract_out, add_sub)
begin
overflow <= '0';

  if(add_sub = '0') then
    overflow <= (x(31) and y(31) and not adder_substract_out(31)) or (not x(31) and not y(31) and adder_substract_out(31));

  else
    overflow <= (not x(31) and y(31)  and adder_substract_out(31)) or (x(31) and  not y(31) and not adder_substract_out(31));
		   
  end if;
end process;

--Zero Unit--
process(adder_substract_out)
constant zeros : std_logic_vector(31 downto 0) := (others => '0');

begin 
  if(adder_substract_out = zeros) then
    zero <= '1';
	
  else
    zero <= '0';
  end if;
end process; 
end alu_32bit;
