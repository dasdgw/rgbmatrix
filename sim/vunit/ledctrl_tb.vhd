-------------------------------------------------------------------------------
-- Title      : Testbench for design "ledctrl"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ledctrl_tb.vhd
-- Author     : Michael Frank  <dasdgw@helot>
-- Company    : 
-- Created    : 2020-04-03
-- Last update: 2020-04-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2020 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-04-03  1.0      dasdgw	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.rgbmatrix_pkg.all;
-------------------------------------------------------------------------------

entity ledctrl_tb is
  generic (runner_cfg : string);
end entity ledctrl_tb;

-------------------------------------------------------------------------------

architecture tb of ledctrl_tb is

  -- component generics
  constant width      : integer  := 32;
  constant depth      : integer  := 16;
  constant ADDR_WIDTH : positive := 512;

  -- component ports
--  signal clk      : std_logic;
  signal rst      : std_logic;
  signal clk_out  : std_logic;
  signal rgb1     : std_logic_vector(2 downto 0);
  signal rgb2     : std_logic_vector(2 downto 0);
  signal led_addr : std_logic_vector(2 downto 0);
  signal lat      : std_logic;
  signal oe       : std_logic;
  signal addr     : std_logic_vector(ADDR_WIDTH-2 downto 0);
  signal data     : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture tb

  -- component instantiation
  DUT: entity work.ledctrl
    generic map (
      width      => width,
      depth      => depth,
      ADDR_WIDTH => ADDR_WIDTH)
    port map (
      clk      => clk,
      rst      => rst,
      clk_out  => clk_out,
      rgb1     => rgb1,
      rgb2     => rgb2,
      led_addr => led_addr,
      lat      => lat,
      oe       => oe,
      addr     => addr,
      data     => data);

  -- clock generation
  Clk <= not Clk after 10 ns;
  rst <= '1', '0' after 100 ns;
  
  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
  test_runner_setup(runner, runner_cfg);

    while test_suite loop

      if run("test_pass") then
        wait for 1 ms;
        report "This will pass";

--      elsif run("test_fail") then
--        assert false report "It fails";

      end if;
    end loop;

    test_runner_cleanup(runner);

  end process WaveGen_Proc;

  

end architecture tb;

-------------------------------------------------------------------------------

configuration ledctrl_tb_tb_cfg of ledctrl_tb is
  for tb
  end for;
end ledctrl_tb_tb_cfg;

-------------------------------------------------------------------------------
