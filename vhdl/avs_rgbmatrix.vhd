-- Adafruit RGB LED Matrix Display Driver
-- Top Level Entity
-- 
-- Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>
-- This software is distributed under the terms of the MIT License shown below.
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

use work.rgbmatrix_pkg.all;             -- Constants & Configuration

entity avs_rgbmatrix is
  generic (
    width      : integer  := 32;
    depth      : integer  := 16;
    ADDR_WIDTH : positive := 10);
  port (
    clk   : in std_logic;
    reset : in std_logic;

    avs_s0_address     : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');  --    s0.address
    avs_s0_read        : in  std_logic                               := '0';  --      .read
    avs_s0_readdata    : out std_logic_vector(31 downto 0);  --      .readdata
    avs_s0_write       : in  std_logic                               := '0';  --      .write
    avs_s0_writedata   : in  std_logic_vector(31 downto 0)           := (others => '0');  --      .writedata
    avs_s0_waitrequest : out std_logic;                      --      .waitreque

    clk_led : in  std_logic;
    clk_out : out std_logic;
    r1      : out std_logic;
    r2      : out std_logic;
    b1      : out std_logic;
    b2      : out std_logic;
    g1      : out std_logic;
    g2      : out std_logic;
    a       : out std_logic;
    b       : out std_logic;
    c       : out std_logic;
    lat     : out std_logic;
    oe      : out std_logic
--    i2c_sdat : inout std_logic;
--    i2c_sclk : inout std_logic
    );
end avs_rgbmatrix;

architecture str of avs_rgbmatrix is
  -- Reset signals
  signal rst, rst_p, jtag_rst_out : std_logic;

--  constant ADDR_WIDTH : positive := positive(log2(real(NUM_PANELS*width*depth/2)));

-- Memory signals
  signal addr          : std_logic_vector(ADDR_WIDTH-2 downto 0);
  signal data_incoming : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal data_outgoing : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rgb           : std_logic_vector(DATA_WIDTH/6-1 downto 0);
  signal waddr         : std_logic_vector(ADDR_WIDTH-1 downto 0);
-- Flags
  signal valid1        : std_logic;
  signal valid2        : std_logic;
  signal tck           : std_logic;

begin

  -- Reset button is an "active low" input, invert it so we can treat is as
  -- "active high", then OR it with the JTAG reset command output signal.
  rst_p <= reset;

  rst <= rst_p or jtag_rst_out;

  avs_s0_waitrequest <= '0';

--  avs_s0_readdata <= "00000000000000000000000000000000";
  avs_s0_readdata <= x"C0DEAFFE";


  -- LED panel controller
  U_LEDCTRL : entity work.ledctrl
    generic map(
      width      => width,
      depth      => depth,
      ADDR_WIDTH => ADDR_WIDTH
      )
    port map (
      rst => rst_p,
      --! can't use tck here. tck seems not to be a continues clock
      clk => clk_led,

-- Connection to LED panel
      clk_out     => clk_out,
      rgb1(2)     => r1,
      rgb1(1)     => g1,
      rgb1(0)     => b1,
      rgb2(2)     => r2,
      rgb2(1)     => g2,
      rgb2(0)     => b2,
      led_addr(2) => c,
      led_addr(1) => b,
      led_addr(0) => a,
      lat         => lat,
      oe          => oe,
      -- Connection with framebuffer
      addr        => addr,
      --  data => x"FF0000FF0000"           -- too bright!
--      data => addr(0)& addr(0) & addr(0) & addr(0) & x"F00001F0000"
      data        => data_outgoing
      );
  avs : if IFACE = "avs" generate

    -- Special memory for the framebuffer
    avs_memory_1 : entity work.avs_memory
      generic map(
--      width      => width,
--      depth      => depth,
        ADDR_WIDTH => ADDR_WIDTH
        )
      port map (
        rst    => valid2,
        -- Writing side
        clk_wr => clk,
        wr     => avs_s0_write,
        waddr  => avs_s0_address,       --waddr,
        input  => avs_s0_writedata,  --rgb,                  --data_incoming,
        -- Reading side
        clk_rd => clk_led,
        addr   => addr,
        output => data_outgoing
        );

  end generate avs;




end str;
