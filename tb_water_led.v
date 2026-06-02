`timescale 1ns/1ps

module tb_water_led();

    // 信号声明
    reg sys_clk;
    reg sys_rst_n;
    reg key_play;
    reg key_mode;
    wire [7:0] led;

    // 实例化顶层模块，通过缩小计数值加快仿真的执行速度
    water_led #(
        .CLK_MAX_CNT(25'd10), // 将分频计数调小
        .DB_MAX_CNT(20'd10)   // 将消抖计数调小
    ) u_water_led (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .key_play  (key_play),
        .key_mode  (key_mode),
        .led       (led)
    );

    // 50MHz 系统时钟生成 (周期20ns)
    initial begin
        sys_clk = 0;
        forever #10 sys_clk = ~sys_clk;
    end

    // 激励信号产生
    initial begin
        // 系统初始化
        sys_rst_n = 0;
        key_play = 1;
        key_mode = 1;
        #100;
        sys_rst_n = 1; // 释放复位
        
        // 观察模式0：单向流水
        #1500;
        
        // 测试按键暂停
        key_play = 0; #500; // 按下暂停键 (持续时间大于消抖时间)
        key_play = 1; #1000;
        
        // 测试按键恢复播放
        key_play = 0; #500;
        key_play = 1; #1000;
        
        // 测试模式切换至模式1（来回跑马）
        key_mode = 0; #500;
        key_mode = 1; #3000;
        
        // 测试模式切换至模式2（聚拢散开）
        key_mode = 0; #500;
        key_mode = 1; #3000;
        
        // 仿真结束
        $stop;
    end

endmodule