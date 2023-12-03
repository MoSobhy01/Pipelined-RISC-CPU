library ieee;
use ieee.std_logic_1164.all;

entity Decoder is
  generic (
    INPUT_WIDTH : integer := 6;
    OUTPUT_WIDTH : integer := 10
  );
  port (
    input : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    signal1 : out std_logic;
    signal2 : out std_logic;
    signal3 : out std_logic;
    signal4 : out std_logic;
    signal5 : out std_logic;
    signal6 : out std_logic;
    signal7 : out std_logic;
    signal8 : out std_logic;
    signal9 : out std_logic;
    signal10 : out std_logic
  );
end entity Decoder;

architecture Behavioral of Decoder is
  signal temp_vector : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
begin
  process(input)
  begin
    case input is
      when "000000" =>
        temp_vector <= "1000000000";
      when "000001" =>
        temp_vector <= "0100000000";
      when "000010" =>
        temp_vector <= "0010000000";
      when "000011" =>
        temp_vector <= "0001000000";
      when "000100" =>
        temp_vector <= "0000100000";
      when "000101" =>
        temp_vector <= "0000010000";
      when "000110" =>
        temp_vector <= "0000001000";
      when "000111" =>
        temp_vector <= "0000000100";
      when "001000" =>
        temp_vector <= "0000000010";
      when "001001" =>
        temp_vector <= "0000000001";
      when others =>
        temp_vector <= "0000000000";
    end case;
  end process;

  signal1 <= temp_vector(0);
  signal2 <= temp_vector(1);
  signal3 <= temp_vector(2);
  signal4 <= temp_vector(3);
  signal5 <= temp_vector(4);
  signal6 <= temp_vector(5);
  signal7 <= temp_vector(6);
  signal8 <= temp_vector(7);
  signal9 <= temp_vector(8);
  signal10 <= temp_vector(9);
end architecture Behavioral;
