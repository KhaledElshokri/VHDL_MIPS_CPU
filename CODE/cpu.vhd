library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity cpu is
    port ( reset_cpu	        : in std_logic;
	   clk_cpu  	            : in std_logic; 
	   rs_out, rt_out	        : out std_logic_vector(3 downto 0):= (others => '0');-- output ports from register file
	   pc_out		            : out std_logic_vector(3 downto 0):= (others => '0');
	   overflow_cpu, zero_cpu	: out std_logic); 
end cpu;

architecture Behaviour of cpu is

-- PC register 
component pc_register
port( address   : in std_logic_vector(31 downto 0) := (others => '0');
      reset	    : in std_logic;
      clk	    : in std_logic;
      pc_out	: out std_logic_vector(31 downto 0) := (others => '0'));
end component;

-- Instruction Memory 
component i_cache
port( address       : in std_logic_vector(4 downto 0);
      instruction	: out std_logic_vector(31 downto 0));
end component;

-- Next Address 
component next_address
port(	
	rt,rs	    	: in std_logic_vector(31 downto 0);
	pc		        : in std_logic_vector(31 downto 0);
	target_address	: in std_logic_vector(25 downto 0);
	branch_type	    : in std_logic_vector(1 downto 0);
	pc_sel	    	: in std_logic_vector(1 downto 0);
	next_pc	    	: out std_logic_vector(31 downto 0));
end component;

-- Register File 
component regfile_32
port( din	        : in std_logic_vector(31 downto 0);
      reset	        : in std_logic;
      clk	        : in std_logic;
      write_en	    : in std_logic;
      read_a	    : in std_logic_vector(4 downto 0);
      read_b	    : in std_logic_vector(4 downto 0);
      write_address : in std_logic_vector(4 downto 0);
      out_a	        : out std_logic_vector(31 downto 0);
      out_b	        : out std_logic_vector(31 downto 0));
end component;

-- Sign Extend 
component sign_ext
port( 	input16	    : in std_logic_vector(15 downto 0);
	    func_slct   : in std_logic_vector(1 downto 0);
      	output32    : out std_logic_vector(31 downto 0));
end component;

-- ALU 
component alu
port(	
	x,y	        : in std_logic_vector(31 downto 0);
	add_sub     : in std_logic;
	logic_func  : in std_logic_vector(1 downto 0);
	func	    : in std_logic_vector(1 downto 0);
	output	    : out std_logic_vector(31 downto 0);
	overflow    : out std_logic;
	zero	    : out std_logic);
end component;

-- Data Cache 
component d_cache
port(	d_in	   : in std_logic_vector(31 downto 0);
	    reset	   : in std_logic;
      	clk	       : in std_logic;
	    dest_reg   : in std_logic_vector(4 downto 0);
        data_write : in std_logic;
      	d_out	   : out std_logic_vector(31 downto 0));
end component;

-- configuration
for PC          : pc_register use entity WORK.pc_register(pc_reg_arch);
for ICache      : i_cache use entity WORK.i_cache(i_arch);
for NextAddress : next_address use entity WORK.next_address(pc_address);
for R_File      : regfile_32 use entity WORK.regfile_32(regfile);
for SignExtend  : sign_ext use entity WORK.sign_ext(ext_arch);
for A_L_U       : alu use entity WORK.alu(alu_32bit);
for DCache      : d_cache use entity WORK.d_cache(d_arch);

-- internal signals
signal pc_o, next_pc_out, ic_out, dc_out, a_out, b_out, alu_out, se_out, alu_in, reg_in : std_logic_vector(31 downto 0) := X"00000000";
signal reg_addr_in : std_logic_vector(4 downto 0) := (others => '0');
signal pc_choice, branch_t, alu_func, alu_lofunc : std_logic_vector(1 downto 0) := "00";
signal alu_addsub, dc_write, reg_write, reg_dst, alu_src, reg_in_src : std_logic := '0';

-- opcode func control signal for control unit
signal opcode , func : std_logic_vector(5 downto 0) := (others => '0');
signal ctrl_sig      : std_logic_vector(13 downto 0);

begin
-- control unit
	process(ic_out, clk_cpu, reset_cpu, opcode, func, ctrl_sig)
	begin
		opcode	 <= ic_out(31 downto 26);
		func	 <= ic_out(5 downto 0);
		case opcode is
			when "000000" =>
				   if (func = "100000") then 
					ctrl_sig <= "11100000100000"; -- add
				elsif (func = "100010") then 
					ctrl_sig <= "11101000100000"; -- sub
				elsif (func = "101010") then
					ctrl_sig <= "11100000010000"; -- slt
				elsif (func = "100100") then 
					ctrl_sig <= "11101000110000"; -- and
				elsif (func = "100101") then 
					ctrl_sig <= "11100001110000"; -- or
				elsif (func = "100110") then 
					ctrl_sig <= "11100010110000"; -- xor
				elsif (func = "100111") then 
					ctrl_sig <= "11100011110000"; -- nor
				elsif (func = "001000") then 
					ctrl_sig <= "00000000000010"; -- jr
				else end if;
			when "000001" => 
				ctrl_sig <= "00000000001100"; -- bltz
			when "000010" => 
				ctrl_sig <= "00000000000001"; -- j
			when "000100" => 
				ctrl_sig <= "00000000000100"; -- beq
			when "000101" => 
				ctrl_sig <= "00000000001000"; -- bne
			when "001000" => 
				ctrl_sig <= "10110000100000"; -- addi
			when "001010" => 
				ctrl_sig <= "10110000010000"; -- slti
			when "001100" => 
				ctrl_sig <= "10110000110000"; -- andi
			when "001101" => 
				ctrl_sig <= "10110001110000"; -- ori
			when "001110" => 
				ctrl_sig <= "10110010110000"; -- xori
			when "001111" => 
				ctrl_sig <= "10110000000000"; -- lui
			when "100011" => 
				ctrl_sig <= "10010010100000"; -- lw
			when "101011" => 
				ctrl_sig <= "00010100100000"; -- sw
			when others =>
		end case;

		reg_write <= ctrl_sig(13);
		reg_dst	 <= ctrl_sig(12);
		reg_in_src <= ctrl_sig(11);
		alu_src <= ctrl_sig(10);
		alu_addsub <= ctrl_sig(9);
		dc_write <= ctrl_sig(8);
		alu_lofunc <= ctrl_sig(7 downto 6);
		alu_func <= ctrl_sig(5 downto 4);
		branch_t <= ctrl_sig(3 downto 2);
		pc_choice <= ctrl_sig(1 downto 0);
	end process; 

-- component instantiation
PC: pc_register port map(address => next_pc_out,
		                 reset => reset_cpu,
		                 clk => clk_cpu,
		                 pc_out => pc_o);

NextAddress: next_address port map(rt => b_out,
				                   rs => a_out,
				                   pc => pc_o,
				                   target_address => ic_out(25 downto 0), 
				                   branch_type => branch_t,
				                   pc_sel => pc_choice,
				                   next_pc => next_pc_out);

ICache: i_cache port map(address => pc_o(4 downto 0),
		                 instruction => ic_out);


R_File: regfile_32 port map(din => reg_in,
		                    reset => reset_cpu,
		                    clk => clk_cpu,
		                    write_en => reg_write, 
		                    read_a => ic_out(25 downto 21),
		                    read_b => ic_out(20 downto 16),
		                    write_address => reg_addr_in,
		                    out_a => a_out,
		                    out_b => b_out);

SignExtend: sign_ext port map(input16 => ic_out(15 downto 0),
			                  func_slct => alu_func,
			                  output32 => se_out);

A_L_U: alu port map(x => a_out, 
		            y => alu_in,
		            add_sub => alu_addsub,
		            logic_func => alu_lofunc, 
		            func => alu_func,
		            output => alu_out, 
		            overflow => overflow_cpu,
		            zero => zero_cpu);

DCache: d_cache port map(d_in => b_out,
		                 reset => reset_cpu,
		                 clk => clk_cpu, 
		                 dest_reg => alu_out(4 downto 0),
		                 data_write => dc_write,
		                 d_out => dc_out);

-- mutiplexers
reg_addr_in <= ic_out(20 downto 16) when (reg_dst = '0') else
	           ic_out(15 downto 11) when (reg_dst = '1');

alu_in <= se_out when (alu_src = '1') else
	      b_out when (alu_src = '0');

reg_in <= alu_out when (reg_in_src = '1') else
	      dc_out when (reg_in_src = '0');

rs_out	<= not(a_out(3 downto 0));
rt_out	<= not(b_out(3 downto 0));
pc_out	<= not(pc_o(3 downto 0));

end Behaviour;
