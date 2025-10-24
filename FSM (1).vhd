library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0); --anode outputs selecting individual 
           seg : out STD_LOGIC_VECTOR (0 to 6); -- cathode outputs for selecting LED-s in each display
           dp : out STD_LOGIC);
end FSM;

architecture Behavioral of FSM is

--Entitatea driverului transformata in componenta
component driver7seg is
    Port ( clk : in STD_LOGIC;
           Din : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (0 to 6);
           dp_in : in STD_LOGIC_VECTOR (3 downto 0);
           dp_out : out STD_LOGIC;
           rst : in STD_LOGIC);
end component driver7seg;

--declararea starilor
type states is (start, cnt_joc, cnt_scor, get_rnd, led_on, led_off, sw_on, sw_off, final);
signal current_state, next_state : states;

signal i : integer;
signal rnd: std_logic_vector (3 downto 0);
signal score : std_logic_vector (15 downto 0);
signal timer : integer range 0 to 60 := 60; -- Timer de 60 de secunde
signal timer_display : std_logic_vector(15 downto 0); -- Timpul ramas afisat pe display
signal game_over : std_logic := '0'; -- Semnal pentru finalizarea jocului

signal div : std_logic;
signal clk_div : integer range 0 to 50000000 := 0;
signal afisaj : std_logic_vector(15 downto 0);

begin

MemoriaCis: process(rst, clk)
begin
  if rst = '1' then
    current_state <= start;
  elsif rising_edge(clk) then
    current_state <= next_state;
  end if;
end process;

-- Circuit combinational
circuit : process(current_state, sw, i, game_over)
begin
    case current_state is 
        when start =>
            if game_over = '1' then
                next_state <= final; -- Daca jocul s-a terminat, trece la starea finala
            else
                next_state <= cnt_joc; -- Altfel, incepe
            end if;
        when cnt_joc => next_state <= get_rnd; -- Generare led-uri aleatorii
        when get_rnd => next_state <= led_on; -- Aprindere led
        when led_on => next_state <= sw_on; -- Verificam starea switch-ului
        when sw_on =>
            if sw(i) = '1' then
                next_state <= sw_off; -- Daca switch-ul este apasat, trece la starea de inchidere a LED-ului
            else
                next_state <= sw_on; -- Altfel, ramane in aceeasi stare
            end if;
        when sw_off =>
            if sw(i) = '0' then
                next_state <= led_off; -- Daca switch-ul este eliberat, inchidem LED-ul
            else
                next_state <= sw_off; -- Altfel, ramane in aceeasi stare
            end if;
        when led_off => next_state <= cnt_scor; -- Trecerea la starea de numarare a scorului
        when cnt_scor => next_state <= cnt_joc; -- Trecerea inapoi la inceputul jocului
        when others => next_state <= start; -- Pentru orice alta stare, revenim la nceputul jocului
    end case;
end process;

-- Proces lfsr - generam numere aleatorii
lfsr : process(rst, clk)
    variable shiftreg : std_logic_vector (15 downto 0) := x"abcd";
    variable firstbit :std_logic;
begin
    if rst = '1' then
        shiftreg := x"abcd";
    elsif rising_edge(clk) then
        firstbit := shiftreg(1) xnor shiftreg(0);
        shiftreg := firstbit & shiftreg (15 downto 1);
end if;
    rnd <= shiftreg(3 downto 0);
end process;

-- Proces generare i
generate_i : process(rst, clk)
begin
    if rst = '1' then
        i <= 0;
    elsif rising_edge(clk) then
        if current_state = get_rnd then
            i <= to_integer(unsigned(rnd));
        end if;
    end if; 
end process;

-- Generare led
generate_led : process(rst, clk)
begin
    if rst = '1' then
        led <= x"0000";
    elsif rising_edge(clk) then
        if current_state = led_on then
            led(i) <= '1';
        elsif current_state = led_off then
            led(i) <= '0';
        end if; 
    end if; 
end process;

-- Generare scor
generare_scor : process(rst,clk)
    variable thousand : integer range 0 to 9 := 0;
    variable hundred : integer range 0 to 9 := 0;
    variable ten : integer range 0 to 9 := 0;
    variable unit : integer range 0 to 9 := 0;
begin
    if rst = '1' then
        thousand := 0;
        hundred := 0;
        ten := 0;
        unit := 0;
    elsif rising_edge(clk) then
        if current_state = cnt_joc then
            if unit = 9 then
                unit := 0;
                if ten = 9 then
                    ten := 0;
                    if hundred = 9 then
                        hundred :=0;
                        if thousand = 9 then
                            thousand := 0;
                        else
                            thousand:= thousand + 1;
                        end if; 
                    else
                         hundred := hundred + 1;
                    end if; 
                else
                    ten := ten + 1;
                end if; 
            else
                 unit := unit + 1;
            end if; 
        end if;
    end if; 
    
score <= std_logic_vector(to_unsigned(thousand,4)) &
std_logic_vector(to_unsigned(hundred,4)) &
std_logic_vector(to_unsigned(ten,4)) &
std_logic_vector(to_unsigned(unit,4));

end process;

-- Divizor de frecventa pentru clk
clk_divizor : process(clk, rst)
begin
  if rst = '1' then
    clk_div <= 0;
    div <= '0';
  elsif rising_edge(clk) then
    if clk_div = 50000000 then
      div <= not div;
      clk_div <= 0;
    else
      clk_div <= clk_div + 1;
    end if;
  end if;
end process;

-- Timer joc
timer_joc : process(div, rst)
begin
  if rst = '1' then
    timer <= 60;
    game_over <= '0';
  elsif rising_edge(div) then
    if timer > 0 then
      timer <= timer - 1;
    else
      game_over <= '1';
    end if;
  end if;
end process;

-- Timer si display
timer_disp: process(timer)
  variable min_high : integer range 0 to 5;
  variable min_low : integer range 0 to 9;
  variable sec_high : integer range 0 to 5;
  variable sec_low : integer range 0 to 9;
begin
  min_high := timer / 600 mod 10;
  min_low := timer / 60 mod 10;
  sec_high := timer / 10 mod 6;
  sec_low := timer mod 10;

  timer_display <= std_logic_vector(to_unsigned(min_high, 4)) &
                   std_logic_vector(to_unsigned(min_low, 4)) &
                   std_logic_vector(to_unsigned(sec_high, 4)) &
                   std_logic_vector(to_unsigned(sec_low, 4));
end process;

-- Display cu multiplexor
display_mux : process(game_over, timer_display, score)
begin
  if game_over = '1' then
    afisaj <= score; -- Afiseaza scorul cand jocul s-a terminat
  else
    afisaj <= timer_display; -- Afiseaza timpul ramas in timpul jocului
  end if;
end process;

u7seg : driver7seg port map (clk => clk,
                             Din => afisaj,
                             an => an,
                             seg => seg,
                             dp_in => (others => '0'),
                             dp_out => dp,
                             rst => rst);

end Behavioral;