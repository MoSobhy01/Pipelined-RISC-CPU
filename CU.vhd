library ieee;
use ieee.std_logic_1164.all;

entity CU is
  generic (
    OUTPUT_WIDTH : integer := 14
  );
  port (
    input : in std_logic_vector(5 downto 0);
    AluOp   : out std_logic_vector(3 downto 0);
    ImmSrc   : out std_logic;
    Branch   : out std_logic;
    BranchIf0: out std_logic;
    MemRead  : out std_logic;
    MemWrite : out std_logic;
    SpOp     : out std_logic;
    protect  : out std_logic;
    free     : out std_logic;
    MemWb : out std_logic;
    RegWrite  : out std_logic
  );
end entity CU;

architecture Behavioral of CU is
  signal temp_vector : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
begin
  process(input)
  begin
    case input is
      when "000000" =>
        temp_vector <= "00000000000000";
      when "000001" =>
        temp_vector <= "10000000000001";
      when "000010" =>
        temp_vector <= "00100000000000";
      when "000011" =>
        temp_vector <= "00010000000000";
      when "000100" =>
        temp_vector <= "00001000000000";
      when "000101" =>
        temp_vector <= "00000100000000";
      when "000110" =>
        temp_vector <= "00000010000000";
      when "000111" =>
        temp_vector <= "00000001000000";
      when "001000" =>
        temp_vector <= "00000000100000";
      when "001001" =>
        temp_vector <= "00000000010000";
      when others =>
        temp_vector <= "00000000000000";
    end case;
  end process;

  AluOp    <= temp_vector(3 downto 0);
  ImmSrc    <= temp_vector(4);
  Branch    <= temp_vector(5);
  BranchIf0 <= temp_vector(6);
  MemRead   <= temp_vector(7);
  MemWrite  <= temp_vector(8);
  SpOp      <= temp_vector(9);
  protect   <= temp_vector(10);
  free      <= temp_vector(11);
  MemWb  <= temp_vector(12);
  RegWrite  <= temp_vector(13);
end architecture Behavioral;