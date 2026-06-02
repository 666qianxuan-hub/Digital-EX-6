module water_led #(
    parameter CLK_MAX_CNT = 25'd24_999_999, // 0.5 sec at 50MHz
    parameter DB_MAX_CNT  = 20'd1_000_000   // 20ms at 50MHz
)(
    input  wire       sys_clk,   // 系统时钟 50MHz
    input  wire       sys_rst_n, // 系统复位，低有效
    input  wire       key_play,  // 播放/暂停按键
    input  wire       key_mode,  // 模式切换按键
    output wire [7:0] led        // 8路LED输出（低电平点亮）
);

    wire clk_1hz;
    wire key_play_db;
    wire key_mode_db;
    
    reg play_en;
    reg [1:0] mode;

    // 1Hz 时钟分频模块
    clk_div #(
        .MAX_CNT(CLK_MAX_CNT)
    ) u_clk_div (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .clk_1hz   (clk_1hz)
    );

    // 播放/暂停按键消抖模块
    key_debounce #(
        .MAX_CNT(DB_MAX_CNT)
    ) u_btn_play (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .key_in    (key_play),
        .key_out   (key_play_db)
    );

    // 模式切换按键消抖模块
    key_debounce #(
        .MAX_CNT(DB_MAX_CNT)
    ) u_btn_mode (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .key_in    (key_mode),
        .key_out   (key_mode_db)
    );

    // 启停状态控制逻辑
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            play_en <= 1'b1; // 默认状态为运行
        end else if (key_play_db) begin
            play_en <= ~play_en;
        end
    end

    // 模式切换状态逻辑
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            mode <= 2'd0;
        end else if (key_mode_db) begin
            if (mode == 2'd2)
                mode <= 2'd0;
            else
                mode <= mode + 1'b1;
        end
    end

    // LED显示控制逻辑
    led_ctrl u_led_ctrl (
        .clk_1hz   (clk_1hz),
        .sys_rst_n (sys_rst_n),
        .play_en   (play_en),
        .mode      (mode),
        .led       (led)
    );

endmodule


// ==========================================
// 1Hz 时钟分频模块
// ==========================================
module clk_div #(
    parameter MAX_CNT = 25'd24_999_999
)(
    input  wire sys_clk,
    input  wire sys_rst_n,
    output reg  clk_1hz
);
    reg [24:0] cnt;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt <= 25'd0;
            clk_1hz <= 1'b0;
        end else if (cnt >= MAX_CNT) begin
            cnt <= 25'd0;
            clk_1hz <= ~clk_1hz;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule


// ==========================================
// 按键消抖模块
// ==========================================
module key_debounce #(
    parameter MAX_CNT = 20'd1_000_000
)(
    input  wire sys_clk,
    input  wire sys_rst_n,
    input  wire key_in,
    output reg  key_out
);
    reg [19:0] cnt;
    reg key_prev;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt <= 20'd0;
            key_prev <= 1'b1;
            key_out <= 1'b0;
        end else begin
            key_prev <= key_in;
            if (key_in != key_prev) begin // 按键状态发生变化
                cnt <= 20'd0;
                key_out <= 1'b0; 
            end else if (cnt < MAX_CNT) begin // 保持状态进行计数
                cnt <= cnt + 1'b1;
                key_out <= 1'b0;
            end else if (cnt == MAX_CNT) begin // 计数达到设定值判定按下
                if (!key_in) begin
                    key_out <= 1'b1; // 仅输出一个时钟周期的高电平脉冲
                end else begin
                    key_out <= 1'b0;
                end
                cnt <= cnt + 1'b1;
            end else begin
                key_out <= 1'b0; // 其他时间输出低电平
            end
        end
    end
endmodule


// ==========================================
// LED显示控制模块
// ==========================================
module led_ctrl(
    input  wire       clk_1hz,
    input  wire       sys_rst_n,
    input  wire       play_en,
    input  wire [1:0] mode,
    output reg  [7:0] led
);
    reg [7:0] led_state;
    reg dir; // 用于双向跑马灯方向控制
    reg [3:0] step; // 用于聚拢散开动画步骤记录

    always @(posedge clk_1hz or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            led_state <= 8'b0000_0001; // 初始状态仅最低位点亮
            dir <= 1'b0;
            step <= 4'd0;
        end else if (play_en) begin
            case (mode)
                2'd0: begin // 模式0：单向循环流水
                    led_state <= {led_state[6:0], led_state[7]};
                end
                2'd1: begin // 模式1：双向来回跑马
                    if (dir == 1'b0) begin
                        if (led_state == 8'b0100_0000) begin
                            led_state <= 8'b1000_0000;
                            dir <= 1'b1;
                        end else begin
                            led_state <= led_state << 1;
                        end
                    end else begin
                        if (led_state == 8'b0000_0010) begin
                            led_state <= 8'b0000_0001;
                            dir <= 1'b0;
                        end else begin
                            led_state <= led_state >> 1;
                        end
                    end
                end
                2'd2: begin // 模式2：闪烁聚拢散开花样
                    case (step)
                        4'd0: led_state <= 8'b1000_0001;
                        4'd1: led_state <= 8'b0100_0010;
                        4'd2: led_state <= 8'b0010_0100;
                        4'd3: led_state <= 8'b0001_1000;
                        4'd4: led_state <= 8'b0010_0100;
                        4'd5: led_state <= 8'b0100_0010;
                        default: led_state <= 8'b1000_0001;
                    endcase
                    if (step >= 4'd5) step <= 4'd0;
                    else step <= step + 1'b1;
                end
                default: led_state <= 8'b0000_0001;
            endcase
        end
    end
    
    // LED 输出（扩展板LED为低电平点亮）
    always @(*) begin
        led = ~led_state;
    end
endmodule