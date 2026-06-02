# ==========================================
# 时钟约束
# ==========================================
# 开发板 50MHz 时钟
set_property PACKAGE_PIN U18 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
create_clock -period 20.000 -name sys_clk -waveform {0.000 10.000} [get_ports sys_clk]

# ==========================================
# 按键约束（AX7020 开发板自带按键）
# ==========================================
# KEY1: 系统复位
set_property PACKAGE_PIN N15 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]

# KEY2: 播放/暂停控制
set_property PACKAGE_PIN N16 [get_ports key_play]
set_property IOSTANDARD LVCMOS33 [get_ports key_play]

# KEY3: 模式切换
set_property PACKAGE_PIN T17 [get_ports key_mode]
set_property IOSTANDARD LVCMOS33 [get_ports key_mode]

# ==========================================
# LED 输出约束（位于黑金 7020 矩阵键盘拓展板 J11 接口）
# ==========================================
set_property PACKAGE_PIN G15 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN H17 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN G18 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN E19 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

set_property PACKAGE_PIN D20 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]

set_property PACKAGE_PIN M18 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

set_property PACKAGE_PIN L17 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]

set_property PACKAGE_PIN H20 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]