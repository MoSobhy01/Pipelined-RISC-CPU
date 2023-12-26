library ieee;
use ieee.std_logic_1164.all;


ENTITY swapDetection IS
PORT( 
    clk : in std_logic;
	instruction : IN std_logic_vector(15 downto 0);
	swapStall : OUT std_logic;
    swap_ins : OUT std_logic_vector(15 downto 0)
    );
END swapDetection;

ARCHITECTURE ArchswapDetection OF swapDetection IS
    signal swap_ins1, swap_ins2: std_logic_vector(15 downto 0);
    signal state: integer := 0;

BEGIN
    swap_ins1 <= "010100" & instruction(6 downto 4) & instruction(3 downto 1) & instruction(3 downto 1) & '0';
    swap_ins2 <= "010100" & instruction(3 downto 1) & instruction(6 downto 4) & instruction(6 downto 4) & '0';
    swapStall <= '1' when (instruction(15 downto 10) xnor "010000") = "111111" and (state = 0 or state = 1) else '0';
    swap_ins <= swap_ins1 when state = 0 else swap_ins2;

    process (clk) begin
        if rising_edge(clk) and (instruction(15 downto 10) xnor "010000") = "111111" THEN 
            if state = 0 then                
                state <= 1;
            elsif state = 1 then
                state <= 2;
            else 
                state <= 0;
            end if;
        end if;
   end process;
END ArchswapDetection;
